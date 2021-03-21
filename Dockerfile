FROM ubuntu:18.04

ENV \
 COMPOSE_VERSION=1.25.0 \
 HELM_VERSION=3.5.2 \
 KUBECTL_VERSION=1.20.4 \
 ISTIO_VERSION=1.8.3 \
 GLIBC_VER=2.31-r0 \
 SMALLSTEP_VERSION=0.15.10 \
 KUBECTL_CERT_MANAGER=1.1.1

USER root
WORKDIR /root

# Alpine Linux default shell for root is '/bin/ash'
# Change this to '/bin/bash' so that  '/etc/bashrc'
# can be loaded when entering the running container
# RUN sed -i 's,/bin/ash,/bin/bash,g' /etc/passwd

# Must set this value for the bash shell to source 
# the '/etc/bashrc' file.
# See: https://stackoverflow.com/q/29021704
# ENV BASH_ENV /etc/bashrc

ARG AWS_IAM_AUTH_VERSION_URL="https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator"
## Alpine base ##
ENV COMPLETIONS=/usr/share/bash-completion/completions
RUN apt-get update && apt-get install vim bash bash-completion curl git jq tmux ca-certificates groff less  openssl unzip wget -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/


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
    mv /tmp/eksctl /usr/local/bin && \
    chmod +x /usr/local/bin/eksctl
# Add eks to autocompletion
RUN eksctl completion bash >> ~/.bash_completion . /etc/profile.d/bash_completion.sh . ~/.bash_completion

# Install SMALL STEP cli 
RUN curl -L -o step-ca_linux.tar.gz "https://github.com/smallstep/certificates/releases/download/v${SMALLSTEP_VERSION}/step-ca_linux_${SMALLSTEP_VERSION}_amd64.tar.gz" && \
    tar -xf step-ca_linux.tar.gz && \
    mv step-ca_${SMALLSTEP_VERSION}/bin/step-ca  /usr/local/bin && \
    chmod +x /usr/local/bin/step-ca && \
    rm step-ca_linux.tar.gz && rm -fr step-ca_${SMALLSTEP_VERSION}

# Install awscli
# latest version of the AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
   ./aws/install && \
   rm awscliv2.zip && rm -fr ./aws
# Add autocompletion for aws-cli
RUN echo 'complete -C '/usr/local/bin/aws_completer' aws' >> /etc/profile

# Install Istio
RUN curl -L "https://istio.io/downloadIstio" | ISTIO_VERSION=${ISTIO_VERSION} sh - && \
    cd istio-${ISTIO_VERSION} && \
    cp ./bin/istioctl /usr/local/bin/istioctl && \
    chmod +x /usr/local/bin/istioctl
# Add autocompletion for ISTIO
RUN echo 'source ~/istio-${ISTIO_VERSION}/tools/istioctl.bash' >> /etc/profile

# Install kubectl cert-manager plugin
RUN curl -L -o kubectl-cert-manager.tar.gz "https://github.com/jetstack/cert-manager/releases/download/v$KUBECTL_CERT_MANAGER/kubectl-cert_manager-linux-amd64.tar.gz" && \
    tar -xf kubectl-cert-manager.tar.gz && \
    mv kubectl-cert_manager /usr/local/bin && \
    rm kubectl-cert-manager.tar.gz

# Kubens \ Kubectx

RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
RUN chmod +x kubectx kubens

RUN mv kubens kubectx /usr/local/bin
RUN kubectl config set-context kubernetes --namespace=default \
 && kubectl config use-context kubernetes
 # Add Autompletion
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.bash
RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.bash
RUN cat kubectx.bash >> /etc/profile 
RUN cat kubens.bash >> /etc/profile  

# kube-ps1: Kubernetes prompt for bash and zsh
RUN cd /tmp \
 && git clone https://github.com/jonmosco/kube-ps1 \
 && cp kube-ps1/kube-ps1.sh /etc/profile.d/ \
 && chmod +x /etc/profile.d/kube-ps1.sh \
 && rm -rf kube-ps1

RUN echo 'source /etc/profile.d/kube-ps1.sh' >> /etc/profile 


RUN echo 'set colored-stats on' >> /etc/profile
RUN echo 'PS1="\e[1m\e[31m[\$HOSTIP] \e[32m(\$(kube_ps1)) \e[34m\u@\h\e[35m \w\e[0m\n$ "' >> /etc/profile


ENV \
 HOSTIP="0.0.0.0" \
 KUBE_PS1_PREFIX="" \
 KUBE_PS1_SUFFIX="" \
 KUBE_PS1_SYMBOL_ENABLE="false" \
 KUBE_PS1_CTX_COLOR="green" \
 KUBE_PS1_NS_COLOR="green" \
 PS1="\e[1m\e[31m[\$HOSTIP] \e[32m(\$(kube_ps1)) \e[34m\u@\h\e[35m \w\e[0m\n$ "



#ENTRYPOINT ["bash", "-i"]
RUN echo '\
        . /etc/profile ; \
   ' >> /root/.profile

# Set default context 
#RUN kubectl config set-context kubernetes --namespace=default \
# && kubectl config use-context kubernetes


CMD [ "bash", "-l"]
