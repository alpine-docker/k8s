#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in Travis CI
# DOCKER_USERNAME
# DOCKER_PASSWORD
# API_TOKEN

# set -ex

build() {

  # helm latest
  helm=$(curl -s https://github.com/helm/helm/releases/latest)
  helm=$(echo $helm\" |grep -oP '(?<=tag\/v)[0-9][^"]*')
  echo $helm

  # aws-iam-authenticator latest
  iam_auth=$(curl -s https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html|grep iam-auth |grep linux|head -1)
  iam_auth_url=$(echo ${iam_auth} |grep -oP '(?<=curl -o aws-iam-authenticator )[^<]*'|head -1)
  echo ${iam_auth_url}

  echo "Found new version, building the image ${image}:${tag}"
  docker build --no-cache --build-arg KUBECTL_VERSION=${tag} --build-arg HELM_VERSION=${helm} --build-arg AWS_IAM_AUTH_VERSION_URL="${iam_auth_url}" -t ${image}:${tag} .

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

status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
echo $status
if [[ ( "${status}" =~ "not found" ) || ( ${REBUILD} == "true" ) ]]; then
   build
fi
