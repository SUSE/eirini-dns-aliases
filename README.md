# eirini-dns-aliases

This is an [eirini] [extension] to allow application containers to resolve DNS
names of the [Cloud Foundry] internal components.  Once deployed, applications
can look up host names such as `credhub.service.cf.internal`.  Additionally,
`service.cf.internal` will be added to the DNS search path.

[eirini]: https://code.cloudfoundry.org/eirini#readme
[extension]: https://code.cloudfoundry.org/eirinix#readme
[Cloud Foundry]: https://cloudfoundry.org/
