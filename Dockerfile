ARG base=""
FROM "${base}"

ARG binary_path=""
COPY "${binary_path}" "/usr/local/bin/eirini-dns-aliases"
ENTRYPOINT ["/usr/local/bin/eirini-dns-aliases"]
