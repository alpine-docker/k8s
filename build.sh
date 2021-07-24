#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# set -ex

set -e

build() {

  # helm latest
  helm=$(curl -s https://github.com/helm/helm/releases)
  helm=$(echo $helm\" |grep -oP '(?<=tag\/v)[0-9][^"]*'|grep -v \-|sort -Vr|head -1)
  echo "helm version is $helm"

  # jq
  DEBIAN_FRONTEND=noninteractive
  sudo apt-get update && sudo apt-get -q -y install jq

  # kustomize latest
  kustomize_release=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | /usr/bin/jq -r '.[].tag_name | select(contains("kustomize"))' \
    | sort -rV | head -n 1)
  kustomize_version=$(basename ${kustomize_release})
  echo "kustomize version is $kustomize_version"

  # kubeseal latest
  kubeseal_version=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases | /usr/bin/jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1)
  echo "kubeseal version is $kubeseal_version"

  docker build --no-cache \
    --build-arg KUBECTL_VERSION=${tag} \
    --build-arg HELM_VERSION=${helm} \
    --build-arg KUSTOMIZE_VERSION=${kustomize_version} \
    --build-arg KUBESEAL_VERSION=${kubeseal_version} \
    -t ${image}:${tag} .

  # run test
  version=$(docker run -ti --rm ${image}:${tag} helm version --client)
  echo $version
  # Client: &version.Version{SemVer:"v2.9.0-rc2", GitCommit:"08db2d0181f4ce394513c32ba1aee7ffc6bc3326", GitTreeState:"clean"}
  if [[ "${version}" == *"Error: unknown flag: --client"* ]]; then
    echo "Detected Helm3+"
    version=$(docker run -ti --rm ${image}:${tag} helm version)
    #version.BuildInfo{Version:"v3.0.0-beta.2", GitCommit:"26c7338408f8db593f93cd7c963ad56f67f662d4", GitTreeState:"clean", GoVersion:"go1.12.9"}
  fi
  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${helm}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

if [[ "$TRAVIS_BRANCH" == "master" && "$TRAVIS_PULL_REQUEST" == false ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push ${image}:${tag}
  fi
}

image="alpine/k8s"

curl -s https://raw.githubusercontent.com/awsdocs/amazon-eks-user-guide/master/doc_source/kubernetes-versions.md |egrep -A 10 "The following Kubernetes versions"|awk '/^+/{gsub("\\\\", ""); print $NF}' |while read tag
do
  echo ${tag}
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ ( "${status}" =~ "not found" ) || ( ${REBUILD} == "true" ) ]]; then
     build
  fi
done
