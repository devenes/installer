#!/bin/bash
source ./funcs.sh

packages=(
    ansible
    docker
    cri-dockerd
    kubectl
    helm
    terraform
    packer
    kind
    kubectx
    kubens
    minikube
    crictl
    vagrant
    td-agent
    crane
    argocd
)

function check_command {
  if ! [ -x "$(command -v $1)" ]; then
      echo -e "${RED}[-] $1 is not installed.${NC}" >&2
      install_"$1"
        if ! [ -x "$(command -v $1)" ]; then
          echo -e "${RED}[-] $1 could not be installed.${NC}" >&2
        else
          echo -e "${GREEN}[+] $1 is installed.${NC}"
        fi
  else
     echo -e "${GREEN}[+] $1 is installed.${NC}"
  fi
}

for package in "${packages[@]}"; do
  check_command "$package"
done
