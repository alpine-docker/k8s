# Kubernetes tools for EKS

kubernetes images with necessary tools for AWS EKS, it can be used as normal kubectl tool as well.

### Preface

[AWS EKS](https://aws.amazon.com/eks) maintains [special kubernetes versions](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) to its managed service. This repo and its built images are used to simplify the way on how easily you can deploy applicaitons with it

Currently (on 28th May 2021), the support kubernetes versions are

```
1.20.4
1.19.8
1.18.16
1.17.17
1.16.15
```

If you need support new versions, after AWS EKS released, please raise PR to update the versions in [.travis.yml](.travis.yml)

### Installed tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (eks versions: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) (latest release: https://github.com/kubernetes-sigs/kustomize/releases/latest)
- [helm](https://github.com/helm/helm) (latest release: https://github.com/helm/helm/releases/latest)
- [helm-diff](https://github.com/databus23/helm-diff) (latest commit)
- [helm-unittest](https://github.com/quintush/helm-unittest) (latest commit)
- [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) (latest version when run the build)
- [eksctl](https://github.com/weaveworks/eksctl) (latest version when run the build)
- [awscli v1](https://github.com/aws/aws-cli) (latest version when run the build)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets) (latest version when run the build)
- General tools, such as bash, curl

### Github Repo

https://github.com/alpine-docker/k8s

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/k8s

### Docker image tags

https://hub.docker.com/r/alpine/k8s/tags/

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# kubectl versions

You should check in file [.travis.yml](.travis.yml), it lists the kubectl version and used as image tags.

# Involve with developing and testing

If you want to build these images by yourself, please follow below commands.

```
export tag=1.13.12

bash ./build.sh
```
Then you need adjust the tag to other kubernetes version and run the build script again.
