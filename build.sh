#!/usr/bin/env bash

# Prerequisite
# Make sure you set secret enviroment variables in CI
# DOCKER_USERNAME
# DOCKER_PASSWORD

# set -ex

set -e

install_jq() {
  # jq 1.6
  DEBIAN_FRONTEND=noninteractive
  #sudo apt-get update && sudo apt-get -q -y install jq
  curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq
  sudo mv jq /usr/bin/jq
  sudo chmod +x /usr/bin/jq
}

build() {
  # helm latest, hold the release candidates
  helm=$(curl -s https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name | select([startswith("v"), (contains("-rc") | not)] | all)' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "helm version is $helm"

  # kustomize latest
  kustomize_release=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | jq -r '.[].tag_name | select(contains("kustomize"))' \
    | sort -rV | head -n 1)
  kustomize_version=$(basename ${kustomize_release})
  echo "kustomize version is $kustomize_version"

  # kubeseal latest
  kubeseal_version=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases | jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "kubeseal version is $kubeseal_version"

  # krew latest
  krew_version=$(curl -s https://api.github.com/repos/kubernetes-sigs/krew/releases | jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "krew version is $krew_version"

  # vals latest
  vals_version=$(curl -s https://api.github.com/repos/helmfile/vals/releases | jq -r '.[].tag_name | select(startswith("v"))' \
    | sort -rV | head -n 1 |sed 's/v//')
  echo "vals version is $vals_version"

  docker build --no-cache \
    --build-arg KUBECTL_VERSION=${tag} \
    --build-arg HELM_VERSION=${helm} \
    --build-arg KUSTOMIZE_VERSION=${kustomize_version} \
    --build-arg KUBESEAL_VERSION=${kubeseal_version} \
    --build-arg KREW_VERSION=${krew_version} \
    --build-arg VALS_VERSION=${vals_version} \
    -t ${image}:${tag} .

  # run test
  echo "Detected Helm3+"
  version=$(docker run --rm ${image}:${tag} helm version)
  # version.BuildInfo{Version:"v3.6.3", GitCommit:"d506314abfb5d21419df8c7e7e68012379db2354", GitTreeState:"clean", GoVersion:"go1.16.5"}

  version=$(echo ${version}| awk -F \" '{print $2}')
  if [ "${version}" == "v${helm}" ]; then
    echo "matched"
  else
    echo "unmatched"
    exit
  fi

  if [[ "$CIRCLE_BRANCH" == "master" ]]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker buildx create --use
    docker buildx build --no-cache --push \
      --platform=linux/amd64,linux/arm64 \
      --build-arg KUBECTL_VERSION=${tag} \
      --build-arg HELM_VERSION=${helm} \
      --build-arg KUSTOMIZE_VERSION=${kustomize_version} \
      --build-arg KUBESEAL_VERSION=${kubeseal_version} \
      --build-arg KREW_VERSION=${krew_version} \
      --build-arg VALS_VERSION=${vals_version} \
      -t ${image}:${tag} .
  fi
}

image="alpine/k8s"

install_jq

# Get the list of all releases tags, excludes alpha, beta, rc tags
releases=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases | jq -r '.[].tag_name | select(test("alpha|beta|rc") | not)')

# Loop through the releases and extract the minor version number
for release in $releases; do
  minor_version=$(echo $release | awk -F'.' '{print $1"."$2}')
  
  # Check if the minor version is already in the array of minor versions
  if [[ ! " ${minor_versions[@]} " =~ " ${minor_version} " ]]; then
    minor_versions+=($minor_version)
  fi
done

# Sort the unique minor versions in reverse order
sorted_minor_versions=($(echo "${minor_versions[@]}" | tr ' ' '\n' | sort -rV))

# Loop through the first 4 unique minor versions and get the latest version for each
for i in $(seq 0 3); do
  minor_version="${sorted_minor_versions[$i]}"
  latest_version=$(echo "$releases" | grep "^$minor_version\." | sort -rV | head -1 | sed 's/v//')
  latest_versions+=($latest_version)
done

echo "Found k8s latest versions: ${latest_versions[*]}"

for tag in "${latest_versions[@]}"; do
  echo ${tag}
  status=$(curl -sL https://hub.docker.com/v2/repositories/${image}/tags/${tag})
  echo $status
  if [[ ( "${status}" =~ "not found" ) ||( ${REBUILD} == "true" ) ]]; then
     echo "build image for ${tag}"
     build
  fi
done
