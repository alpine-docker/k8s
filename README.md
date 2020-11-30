[![Build Status](https://travis-ci.org/Gershon-A/k8s.svg?branch=master)](https://travis-ci.org/Gershon-A/k8s)
# Kubernetes tools for EKS

docker build for AWS EKS, it can be used as normal kubectl tool as well

### Installed tools
 COMPOSE_VERSION=1.25.0 
 HELM_VERSION=3.3.4 
 KUBECTL_VERSION=1.18.8 
 ISTIO_VERSION=1.7.4 
 AWS-CLI=2.1.1 
 PYTHON=3.7.3
 GLIBC_VER=2.31-r0
 
### For latest see: 
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (eks versions: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [helm](https://github.com/helm/helm) (latest release: https://github.com/helm/helm/releases/latest)
- [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) (latest version when run the build)
- [eksctl](https://github.com/weaveworks/eksctl) (latest version when run the build)
- [awscli](https://github.com/aws/aws-cli) (latest version when run the build)
- General tools, such as bash, curl

### Github Repo

https://github.com/alpine-docker/k8s

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/k8s

### Docker image tags

https://hub.docker.com/r/alpine/k8s/tags/

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment
