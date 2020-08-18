package main

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/SUSE/eirini-dns-aliases/pkg/extension"
	eirinix "code.cloudfoundry.org/eirinix"
)

func main() {
	eiriniNsEnvVar := os.Getenv("EIRINI_NAMESPACE")
	if eiriniNsEnvVar == "" {
		log.Fatal(fmt.Errorf("The EIRINI_NAMESPACE environment variable must be set"))
	}

	webhookNsEnvVar := os.Getenv("WEBHOOK_NAMESPACE")
	if webhookNsEnvVar == "" {
		log.Fatal(fmt.Errorf("The WEBHOOK_NAMESPACE environment variable must be set"))
	}

	portEnvVar := os.Getenv("PORT")
	if portEnvVar == "" {
		log.Fatal(fmt.Errorf("The PORT environment variable must be set"))
	}
	port, err := strconv.Atoi(portEnvVar)
	if err != nil {
		log.Fatal(err)
	}

	serviceNameEnvVar := os.Getenv("SERVICE_NAME")
	if serviceNameEnvVar == "" {
		log.Fatal(fmt.Errorf("The SERVICE_NAME environment variable must be set"))
	}

	operatorFingerprintEnvVar := os.Getenv("OPERATOR_FINGERPRINT")
	if operatorFingerprintEnvVar == "" {
		log.Fatal(fmt.Errorf("The OPERATOR_FINGERPRINT environment variable must be set"))
	}

	dnsServiceHostEnvVar := os.Getenv("DNS_SERVICE_HOST")
	if dnsServiceHostEnvVar == "" {
		log.Fatal(fmt.Errorf("The DNS_SERVICE_HOST environment variable must be set"))
	}

	filter := false

	ext := eirinix.NewManager(eirinix.ManagerOptions{
		Namespace:           eiriniNsEnvVar,
		Host:                "0.0.0.0",
		Port:                int32(port),
		ServiceName:         serviceNameEnvVar,
		WebhookNamespace:    webhookNsEnvVar,
		OperatorFingerprint: operatorFingerprintEnvVar,
		FilterEiriniApps:    &filter,
	})

	ext.AddExtension(&extension.Extension{DNSServiceHost: dnsServiceHostEnvVar})

	if err := ext.Start(); err != nil {
		log.Fatal(err)
	}
}
