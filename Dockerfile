ARG build_base="golang:1"
ARG base="opensuse/leap:15.2"

FROM "${build_base}" AS builder
ARG GO111MODULE=auto
ARG version=""

WORKDIR /go/src/github.com/SUSE/eirini-dns-aliases
# Copy go.mod / go.sum first, so we can avoid re-downloading dependencies during
# development.
COPY go.mod go.sum ./
RUN if test "${GO111MODULE}" != off ; then go mod download ; fi
COPY . ./
RUN echo "Building eirini-dns-aliases ${version}"
RUN go build -ldflags="-s -w" -o output/eirini-dns-aliases

FROM "${base}"

COPY --from=builder "/go/src/github.com/SUSE/eirini-dns-aliases/output/eirini-dns-aliases" "/usr/local/bin/"
ENTRYPOINT ["/usr/local/bin/eirini-dns-aliases"]
