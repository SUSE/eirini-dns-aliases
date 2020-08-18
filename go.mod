module github.com/SUSE/eirini-dns-aliases

go 1.13

require (
	code.cloudfoundry.org/eirinix v0.0.0-20200813115927-6a0925613552
	github.com/Sirupsen/logrus v0.0.0-00010101000000-000000000000 // indirect
	github.com/docker/docker v1.13.1 // indirect
	github.com/docker/libnetwork v0.5.6
	github.com/golang/groupcache v0.0.0-20191227052852-215e87163ea7 // indirect
	github.com/konsorten/go-windows-terminal-sequences v1.0.2 // indirect
	github.com/prometheus/client_golang v1.3.0 // indirect
	github.com/prometheus/common v0.9.1 // indirect
	github.com/vishvananda/netns v0.0.0-20191106174202-0a2b9b5464df // indirect
	golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d // indirect
	golang.org/x/time v0.0.0-20191024005414-555d28b269f0 // indirect
	google.golang.org/appengine v1.6.5 // indirect
	k8s.io/api v0.18.6
	sigs.k8s.io/controller-runtime v0.6.2
)

replace github.com/Sirupsen/logrus => github.com/sirupsen/logrus v1.4.2
