############################
# STEP 1 build executable binary
############################
# golang alpine 1.12
FROM golang@sha256:8cc1c0f534c0fef088f8fe09edc404f6ff4f729745b85deae5510bfd4c157fb2 as builder

ARG goos=linux

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates && update-ca-certificates

# Create appuser
RUN adduser -D -g '' appuser

WORKDIR $GOPATH/src/github.com/vothanhkiet/health-check
COPY ./src .

# Fetch dependencies.
RUN go get -d -v

# Build the binary
RUN CGO_ENABLED=0 GOOS=$goos go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/health-check .
RUN apk add upx --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN upx /go/bin/health-check

# ############################
# # STEP 2 build a small image
# ############################
# FROM scratch
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=builder /etc/passwd /etc/passwd
# USER appuser
# # Copy our static executable.
# COPY --from=builder /go/bin/health-check health-check
# EXPOSE 8080
# # Run the hello binary.
# ENTRYPOINT ["./health-check"]
# # Sample usage
# HEALTHCHECK --interval=5s --timeout=2s --start-period=1s --retries=2 CMD ["/healthcheck", "-tcp", "127.0.0.1:80"]