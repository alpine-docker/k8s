#!/usr/bin/env bash

set -euxo pipefail

# Tests that the necessary binaries are present and do not throw errors

test_all() {
  test_helm
  test_aws
  test_k8s
  test_user_unpriviledged
}

test_aws() {
  # Tests AWS CLI, EKSCTL
  echo "[*] Testing AWS components..."
  aws help > /dev/null
  eksctl --help > /dev/null
}

test_helm() {
  # Tests helm, helm-diff, helm-unittest, helm-push
  echo "[*] Testing Helm components..."
  helm --help > /dev/null
  helm diff --help > /dev/null
  helm cm-push --help > /dev/null
  helm unittest --help > /dev/null
}

test_k8s() {
  # Tests Kubectl, Kustomize, Kubeseal
  echo "[*] Testing Kubernetes components..."
  kubectl --help > /dev/null
  kustomize --help > /dev/null
  kubeseal --version > /dev/null
}

test_user_unpriviledged() {
  # Tests that user is not root
  echo "[*] Testing User..."
  if [ $UID = 0 ]; then echo "[!] Running as root. Failing..."; exit 1; fi
}

test_all
