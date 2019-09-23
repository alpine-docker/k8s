# iubernetes tools for EKS

docker build for AWS EKS, it can be used as normal kubectl tool as well

### Installed tools

- kubectl (eks versions)
- aws-iam-authenticator (latest version when run the build)
- helm (latest release: https://github.com/helm/helm/releases/latest)
- eskctl (latest version when run the build)
- awscli (latest version when run the build)

## NOTES

The latest docker tag is the latest eks verison (https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

### Github Repo

https://github.com/alpine-docker/k8s

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/k8s

### Docker image tags

https://hub.docker.com/r/alpine/k8s/tags/

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment
