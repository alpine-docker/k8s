FROM alpine:edge

# variable "VERSION" must be passed as docker environment variables during the image build
# docker build --no-cache --build-arg VERSION=2.12.0 -t alpine/helm:2.12.0 .

ARG HELM_VERSION=3.12.3
ARG KUBECTL_VERSION=1.26.12
ARG AWS_IAM_AUTH_VERSION=0.6.12
ARG CRANE_VERSION=0.11.0

ENV AWS_DEFAULT_REGION=eu-west-1

# Install basic tools
RUN apk add --update --no-cache git curl ca-certificates bash aws-cli

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git && \
    rm -rf linux-amd64

# Install kubectl (same version of aws esk)
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install aws-iam-authenticator (latest version)
RUN curl -LO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTH_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 && \
    mv aws-iam-authenticator_${AWS_IAM_AUTH_VERSION}_linux_amd64 /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

# Install crane
RUN mkdir crane && \
    curl -L https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz | tar xvz -C crane && \
    mv crane/crane /usr/bin/crane && \
    rm -rf crane

WORKDIR /apps
