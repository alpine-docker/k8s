FROM alpine
ENV \
 COMPOSE_VERSION=1.25.0 \
 HELM_VERSION=3.5.2 \
 KUBECTL_VERSION=1.20.4 \
 ISTIO_VERSION=1.8.4 \
 GLIBC_VER=2.31-r0

ARG AWS_IAM_AUTH_VERSION_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator"
## Alpine base ##
ENV COMPLETIONS=/usr/share/bash-completion/completions
RUN apk add --update bash bash-completion curl git jq libintl ncurses tmux ca-certificates groff less  openssl
RUN sed -i s,/bin/ash,/bin/bash, /etc/passwd

## Install a bunch of binaries
RUN curl -L -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 \
 && chmod +x /usr/local/bin/docker-compose
 # Install kubectl
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl
RUN kubectl completion bash > $COMPLETIONS/kubectl.bash
# Install HeLM
RUN curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  | tar zx -C /usr/local/bin --strip-components=1 linux-amd64/helm
RUN helm completion bash > $COMPLETIONS/helm.bash

# Install aws-iam-authenticator (latest version)
RUN curl -LO ${AWS_IAM_AUTH_VERSION_URL} && \
    mv aws-iam-authenticator /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

# Install eksctl (latest version)
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv mv /tmp/eksctl /usr/local/bin && \
    chmod +x /usr/local/bin/eksctl
# Add eks to autocompletion
RUN eksctl completion bash >> ~/.bash_completion . /etc/profile.d/bash_completion.sh . ~/.bash_completion

# Install awscli
# install glibc compatibility for alpine
RUN apk add \
        binutils \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
  ##  && complete -C '/root/aws/dist/aws_completer' aws \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

RUN export PATH=/usr/bin/:$PATH


    # Install Istio
RUN curl -L "https://istio.io/downloadIstio" | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
    cd istio-${ISTIO_VERSION} && \
    cp ./bin/istioctl /usr/local/bin/istioctl && \
    chmod +x /usr/local/bin/istioctl
# Add autocompletion for ISTIO
# RUN echo "[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"" >>~/.bashrc
# P.S collateral - is hidden command and missed from documentation
RUN cp /istio-${ISTIO_VERSION}/tools/istioctl.bash $COMPLETIONS \
| istioctl collateral completion --bash > $COMPLETIONS/istioctl.bash
    # Install kubectl cert-manager plugin
RUN curl -L -o kubectl-cert-manager.tar.gz "https://github.com/jetstack/cert-manager/releases/download/v1.0.0/kubectl-cert_manager-linux-amd64.tar.gz" && \
    tar xzf kubectl-cert-manager.tar.gz && \
    mv kubectl-cert_manager /usr/local/bin

RUN cd /tmp \
 && git clone https://github.com/ahmetb/kubectx \
 && cd kubectx \
 && mv kubectx /usr/local/bin/kctx \
 && mv kubens /usr/local/bin/kns \
 && mv completion/*.bash $COMPLETIONS \
 && cd .. \
 && rm -rf kubectx
RUN cd /tmp \
 && git clone https://github.com/jonmosco/kube-ps1 \
 && cp kube-ps1/kube-ps1.sh /etc/profile.d/ \
 && rm -rf kube-ps1
RUN kubectl config set-context kubernetes --namespace=default \
 && kubectl config use-context kubernetes
WORKDIR /root
RUN echo trap exit TERM > /etc/profile.d/trapterm.sh
RUN sed -i "s/export PS1=/#export PS1=/" /etc/profile

ENV \
 HOSTIP="0.0.0.0" \
 KUBE_PS1_PREFIX="" \
 KUBE_PS1_SUFFIX="" \
 KUBE_PS1_SYMBOL_ENABLE="false" \
 KUBE_PS1_CTX_COLOR="green" \
 KUBE_PS1_NS_COLOR="green" \
 PS1="\e[1m\e[31m[\$HOSTIP] \e[32m(\$(kube_ps1)) \e[34m\u@\h\e[35m \w\e[0m\n$ "
ENTRYPOINT ["bash", "-i"]
