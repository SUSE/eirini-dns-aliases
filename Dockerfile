ARG build_base="golang:1"
ARG base="scratch"

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
ENV CGO_ENABLED=0
RUN go build -ldflags="-s -w -X main.appVersion=${version}" -o output/eirini-dns-aliases
RUN mkdir /tmp/empty-directory

FROM "${base}"

COPY --from=builder "/go/src/github.com/SUSE/eirini-dns-aliases/output/eirini-dns-aliases" "/usr/local/bin/"
# The COPY will create an empty directory
COPY --from=builder /tmp/empty-directory /tmp
ENTRYPOINT ["/usr/local/bin/eirini-dns-aliases"]
