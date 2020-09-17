package extension

import (
	"context"
	"errors"
	"net"
	"net/http"
	"strings"

	eirinix "code.cloudfoundry.org/eirinix"
	"github.com/docker/libnetwork/resolvconf"
	corev1 "k8s.io/api/core/v1"
	"sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

func NewExtension(nameserver, searchdomain string) *Extension {
	if len(searchdomain) == 0 {
		searchdomain = "service.cf.internal"
	}
	if len(nameserver) == 0 {
		nameserver = "1.1.1.1"
	}
	return &Extension{DNSServiceHost: nameserver, SearchDomain: searchdomain}
}

type Extension struct {
	DNSServiceHost string
	SearchDomain   string
}

func (ext *Extension) Handle(
	ctx context.Context,
	eiriniManager eirinix.Manager,
	pod *corev1.Pod,
	req admission.Request,
) admission.Response {
	if pod == nil {
		return admission.Errored(http.StatusBadRequest, errors.New("failed to decode pod"))
	}

	podCopy := pod.DeepCopy()

	podCopy.Spec.DNSPolicy = corev1.DNSNone

	rc, err := resolvconf.Get()
	if err != nil {
		return admission.Errored(http.StatusInternalServerError, err)
	}

	strOptions := resolvconf.GetOptions(rc.Content)
	options := make([]corev1.PodDNSConfigOption, 0, len(strOptions))
	for _, strOption := range strOptions {
		split := strings.SplitN(strOption, ":", 2)
		option := corev1.PodDNSConfigOption{
			Name:  split[0],
			Value: &split[1],
		}
		options = append(options, option)
	}

	searches := resolvconf.GetSearchDomains(rc.Content)
	searches = append(searches, ext.SearchDomain)

	nameservers, err := net.LookupHost(ext.DNSServiceHost)
	if err != nil {
		return admission.Errored(http.StatusInternalServerError, err)
	}

	podCopy.Spec.DNSConfig = &corev1.PodDNSConfig{
		Nameservers: nameservers,
		Options:     options,
		Searches:    searches,
	}

	return eiriniManager.PatchFromPod(req, podCopy)
}
