package extension_test

import (
	"context"
	"encoding/json"
	"strings"

	eirinixcatalog "code.cloudfoundry.org/eirinix/testing"
	. "github.com/SUSE/eirini-dns-aliases/pkg/extension"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	admissionv1beta1 "k8s.io/api/admission/v1beta1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

func jsonifyPatches(resp admission.Response) []string {
	var r []string
	for _, patch := range resp.Patches {
		r = append(r, patch.Json())
	}
	return r
}

func decodePatches(resp admission.Response) string {
	return strings.Join(jsonifyPatches(resp), "")
}

const (
	noDnsPolicyPatch = `{"op":"add","path":"/spec/dnsPolicy","value":"None"}`
)

var _ = Describe("Eirini extension", func() {
	eirinixcat := eirinixcatalog.NewCatalog()
	extension := NewExtension("", "")
	eiriniManager := eirinixcat.SimpleManager()
	request := admission.Request{}
	pod := &corev1.Pod{}

	JustBeforeEach(func() {
		extension = NewExtension("", "")
		eirinixcat = eirinixcatalog.NewCatalog()
		eiriniManager = eirinixcat.SimpleManager()

		raw, err := json.Marshal(pod)
		Expect(err).ToNot(HaveOccurred())

		request = admission.Request{AdmissionRequest: admissionv1beta1.AdmissionRequest{Object: runtime.RawExtension{Raw: raw}}}
	})

	Describe("eirini-dns-aliases", func() {
		Context("when handling a Eirini runtime app", func() {
			BeforeEach(func() {
				pod = &corev1.Pod{
					Spec: corev1.PodSpec{
						Containers: []corev1.Container{
							{
								Name: "opi",
							},
						},
					},
				}
			})

			It("Does patch the dns policy", func() {
				patches := jsonifyPatches(extension.Handle(context.Background(), eiriniManager, pod, request))
				Expect(patches).To(ContainElement(MatchJSON(noDnsPolicyPatch)))

				settings := struct {
					Nameservers []string `json:"nameservers"`
				}{
					Nameservers: []string{"1.1.1.1"},
				}
				patch := struct {
					Op    string      `json:"op"`
					Path  string      `json:"path"`
					Value interface{} `json:"value"`
				}{
					Op:    "add",
					Path:  "/spec/dnsConfig",
					Value: settings,
				}
				dataPatch, err := json.Marshal(patch)
				Expect(err).ToNot(HaveOccurred())
				Expect(patches).To(ContainElement(MatchJSON(dataPatch)))
				Expect(len(patches)).To(Equal(2))
			})
		})
	})
})
