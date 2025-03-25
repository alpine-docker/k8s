FROM alpine/k8s:1.31.6

ARG CRANE_VERSION=0.11.0

ENV AWS_DEFAULT_REGION=eu-west-1

# Install basic tools
RUN apk add --update --no-cache git curl ca-certificates bash aws-cli

# Install crane
RUN mkdir crane && \
    curl -L https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz | tar xvz -C crane && \
    mv crane/crane /usr/bin/crane && \
    rm -rf crane

# Install helm S3 plugin
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git

WORKDIR /apps
