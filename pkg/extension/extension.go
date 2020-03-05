package extension

import (
	"context"
	"errors"
	"net"
	"net/http"
	"strings"

	eirinix "github.com/SUSE/eirinix"
	"github.com/docker/libnetwork/resolvconf"
	corev1 "k8s.io/api/core/v1"
	"sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

type Extension struct {
	DNSServiceHost string
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
		split := strings.Split(strOption, ":")
		option := corev1.PodDNSConfigOption{
			Name:  split[0],
			Value: &split[1],
		}
		options = append(options, option)
	}

	searches := resolvconf.GetSearchDomains(rc.Content)
	searches = append(searches, "service.cf.internal")

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
