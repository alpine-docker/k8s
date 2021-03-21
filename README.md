[![Build Status](https://travis-ci.org/Gershon-A/k8s.svg?branch=master)](https://travis-ci.org/Gershon-A/k8s)
![Docker Image Status](https://github.com/Gershon-A/k8s/actions/workflows/docker-publish.yml/badge.svg)
# Kubernetes tools for EKS

docker build for AWS EKS, it can be used as normal kubectl tool as well.
Most autocompletion installed.

### Installed tools
 COMPOSE_VERSION=1.25.0 

 HELM_VERSION=3.5.2

 KUBECTL_VERSION=1.18.8 

 ISTIO_VERSION=1.8.3

 AWS-CLI=2.1.30 (14-03-2021)

 PYTHON=3.7.3

 GLIBC_VER=2.31-r0

 SMALLSTEP_VERSION=0.15.8
 
 KUBECTL-CERT_MANAGER=1.1.1

 kubectx = master
 
 kubens = master

 kube-ps1 = master

### For latest see: 
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (eks versions: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [helm](https://github.com/helm/helm) (latest release: https://github.com/helm/helm/releases/latest)
- [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) (latest version when run the build)
- [eksctl](https://github.com/weaveworks/eksctl) (latest version when run the build)
- [awscli](https://github.com/aws/aws-cli) (latest version when run the build)
- [smallstep/certificates] (https://github.com/smallstep/certificates) 0.15.8
- [cert-manager] (https://github.com/jetstack/cert-manager) 1.1.1
- [kubectx-and-kubens] (https://github.com/ahmetb/kubectx/blob/master/kubens) master
- [kube-ps1] (https://github.com/jonmosco/kube-ps1) master
- General tools, such as bash, curl
### Build
```
docker build -t aws-tools .
```
### Example Usage
- Start container
```
docker run --name aws-tools -t -d aws-tools
```
- Start container and mount AWS credentials
```
docker run --name aws-tools -v "$HOME/.aws/credentials":/root/.aws/credentials:ro  -t -d aws-tools
```
- Start container and pass AWS credentials as environment variable
```
export AWS_ACCESS_KEY_ID=my key
export AWS_SECRET_ACCESS_KEY=my sqcret

docker run --name aws-tools \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -t -d aws-tools  
```
- Working directely on runnng container
```
docker run --name aws-tools -t -d aws-tools
docker exec -it aws-tools bash 
```
- Get AWS version
```
docker exec -it aws-tools bash -c "aws --version"                                             
aws-cli/2.1.19 Python/3.7.3 Linux/4.19.128-microsoft-standard exe/x86_64.alpine.3 prompt/off    
```
- Add remote cluster access to container

```
export EKS_CLUSTER_NAME=[my aws EKS clustername]
docker exec -it aws-tools bash -l \
-c "rm  ~/.kube/config &&  aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region us-east-1 && kubectl get nodes"
```
### Github Repo

https://github.com/alpine-docker/k8s

### Daily Travis CI build logs

https://travis-ci.org/alpine-docker/k8s

### Docker image tags

https://hub.docker.com/r/alpine/k8s/tags/

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

This also useful when we want to start with desired tools immediately instead of installing all manually.

Also act as wrapper:
```
docker exec -it aws-tools1 bash         
[0.0.0.0] () root@6784ab43d24d ~
```
## ToDo
1. Optimize the image, reduce the size, reduce build time
2. Change components to work always with the latest version's
3. Add some automation test