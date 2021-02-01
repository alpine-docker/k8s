# Kubernetes tools for EKS

docker build for AWS EKS, it can be used as normal kubectl tool as well

### Installed tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (eks versions: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) (latest release: https://github.com/kubernetes-sigs/kustomize/releases/latest)
- [helm](https://github.com/helm/helm) (latest release: https://github.com/helm/helm/releases/latest)
- [helm-diff](https://github.com/databus23/helm-diff) (latest commit)
- [helm-unittest](https://github.com/quintush/helm-unittest) (latest commit)
- [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) (latest version when run the build)
- [eksctl](https://github.com/weaveworks/eksctl) (latest version when run the build)
- [awscli v1](https://github.com/aws/aws-cli) (latest version when run the build) - See notes below
- [awscli v2](https://github.com/aws/aws-cli) (latest version when run the build) - See notes below
- General tools, such as bash, curl

### Github Repo

https://github.com/alpine-docker/k8s

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/k8s

### Docker image tags

https://hub.docker.com/r/alpine/k8s/tags/

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# Latest vesion

You should check in file [.travis.yml](.travis.yml), it lists the image tags.

# Involve with developing and testing

If you want to build these images by yourself, please follow below commands.

```
export tag=1.13.12

bash ./build.sh
```
Then you need adjust the tag to other kubernetes version and run the build script again.

# Notes to set aws cli version when run the container

```
$ docker run -ti --rm -e awscli=v2 alpine/k8s:1.18.2 aws --version
aws-cli/2.1.22 Python/3.7.3 Linux/4.19.121-linuxkit exe/x86_64.alpine.3 prompt/off

$ docker run -ti --rm -e awscli=v1 alpine/k8s:1.18.2 aws --version
aws-cli/1.18.223 Python/3.8.7 Linux/4.19.121-linuxkit botocore/1.19.63

$ docker run -ti --rm alpine/k8s:1.18.2 aws --version
aws-cli/1.18.223 Python/3.8.7 Linux/4.19.121-linuxkit botocore/1.19.63
```
