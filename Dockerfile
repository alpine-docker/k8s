FROM alpine

# Ignore to update versions here
# docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg KUSTOMIZE_VERSION=${kustomize_version} -t ${image}:${tag} .
ARG HELM_VERSION=3.2.1
ARG KUBECTL_VERSION=1.17.5
ARG KUSTOMIZE_VERSION=v3.8.1
ARG KUBESEAL_VERSION=v0.15.0
ARG AWS_CLI_VERSION=2.1.39

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL ${BASE_URL}/${TAR_FILE} | tar -xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

# add helm-diff
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
RUN helm plugin install https://github.com/quintush/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
RUN helm plugin install https://github.com/chartmuseum/helm-push && rm -rf /tmp/helm-*

# Install kubectl (same version of aws esk)
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kustomize (latest release)
RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

# Install eksctl (latest version)
RUN curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/bin && \
    chmod +x /usr/bin/eksctl

# Install awscli v1 
RUN apk add --update --no-cache python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    curl -sL "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscliv1.zip" && \
    unzip awscliv1.zip && \
    ./awscli-bundle/install -i /usr/local/aws-cli-v1 -b /usr/local/bin/awsv1 && \
    chmod +x /usr/local/bin/awsv1 && \
    rm -rf awscliv1.zip awscli-bundle

# Install awscli v2
RUN apk add --update --no-cache gcompat groff && \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install -i /usr/local/aws-cli-v2 -b /usr/local/bin && \
    chmod +x /usr/local/bin/aws && \
    mv /usr/local/bin/aws /usr/local/bin/awsv2 && \
    rm -rf awscliv2.zip aws

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
# Install aws-iam-authenticator
RUN authenticator=$(awsv1 --no-sign-request s3 ls s3://amazon-eks --recursive |grep aws-iam-authenticator$|grep amd64 |awk '{print $NF}' |sort -V|tail -1) && \
    awsv1 --no-sign-request s3 cp s3://amazon-eks/${authenticator} /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

# Install jq
RUN apk add --update --no-cache jq

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install kubeseal
RUN curl -sL https://github.com/bitnami-labs/sealed-secrets/releases/download/${KUBESEAL_VERSION}/kubeseal-linux-amd64 -o kubeseal && \
    mv kubeseal /usr/bin/kubeseal && \
    chmod +x /usr/bin/kubeseal

COPY entrypoint.sh entrypoint.sh

WORKDIR /apps

ENTRYPOINT ["/entrypoint.sh"]
