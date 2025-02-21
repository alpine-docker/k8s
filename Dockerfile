FROM alpine

ARG ARCH

# Ignore to update versions here
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG HELM_VERSION=3.2.1
ARG KUBECTL_VERSION=1.17.5
ARG KUSTOMIZE_VERSION=v3.8.1
ARG KUBESEAL_VERSION=0.18.1
ARG KREW_VERSION=v0.4.4
ARG VALS_VERSION=0.28.1
ARG KUBECONFORM_VERSION=0.6.3

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
RUN case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
RUN helm plugin install https://github.com/helm-unittest/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
RUN helm plugin install https://github.com/chartmuseum/helm-push && \
    rm -rf /tmp/helm-* \
    /root/.local/share/helm/plugins/helm-push/testdata \
    /root/.cache/helm/plugins/https-github.com-chartmuseum-helm-push/testdata

# Install kubectl
RUN . /envfile && echo $ARCH && \
    curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kustomize (latest release)
RUN . /envfile && echo $ARCH && \
    curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# Install eksctl (latest version)
RUN . /envfile && echo $ARCH && \
    curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_${ARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/bin && \
    chmod +x /usr/bin/eksctl

# Install awscli v1
RUN apk add --update --no-cache pipx && \
    pipx install awscli --global --suffix=v1

# Install awscli v2
RUN apk add --update --no-cache aws-cli && \
    mv /usr/bin/aws /usr/local/bin/awsv2

# Add script to switch between aws cli v1 and v2
COPY aws_cli.sh /usr/local/bin/aws

# Install jq
RUN apk add --update --no-cache jq yq

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# Install aws-iam-authenticator (latest version)
RUN . /envfile && echo $ARCH && \
    authenticator=$(curl -fs https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | jq --raw-output '.name' | sed 's/^v//') && \
    curl -fL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${authenticator}/aws-iam-authenticator_${authenticator}_linux_${ARCH} -o /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install kubeseal
RUN . /envfile && echo $ARCH && \
    curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-${ARCH}.tar.gz -o - | tar xz -C /usr/bin/ && \
    chmod +x /usr/bin/kubeseal

# Install vals
RUN . /envfile && echo $ARCH && \
    curl -L https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${ARCH}.tar.gz -o -| tar xz -C /usr/bin/ && \
    chmod +x /usr/bin/vals

# Install krew (latest release)
RUN . /envfile && echo $ARCH && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_${ARCH}.tar.gz" && \
    tar zxvf krew-linux_${ARCH}.tar.gz && \
    ./krew-linux_${ARCH} install krew && \
    echo 'export PATH=/root/.krew/bin:$PATH' >> ~/.bashrc && \
    rm krew-linux_${ARCH}.tar.gz

# Install kubeconform
RUN . /envfile && echo $ARCH && \
    curl -L https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-${ARCH}.tar.gz -o - | tar xz -C /usr/bin/ && \
    chmod +x /usr/bin/kubeconform

WORKDIR /apps
