GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if ! [ -x "$(command -v ansible)" ]; then
  echo -e "${RED}Ansible is not installed.${NC}" >&2
else 
  echo -e "${GREEN}Ansible is installed.${NC}"
  ansible=$(ansible --version | grep "core" | head -1)
  echo -e "${GREEN}Ansible version: $ansible${NC}"
fi

if ! [ -x "$(command -v docker)" ]; then
  echo -e "${RED}Docker is not installed.${NC}" >&2
else 
  echo -e "${GREEN}Docker is installed.${NC}"
  docker=$(docker --version)
  echo -e "${GREEN}Docker version: $docker${NC}"
fi

if ! [ -x "$(command -v cri-dockerd --version)" ]; then
  echo -e "${RED}CRI-Dockerd is not installed.${NC}" >&2
else 
  # echo -e "${GREEN}CRI-Dockerd is installed. CRI-Dockerd version:"
  printf "${GREEN}CRI-Dockerd is installed. CRI-Dockerd version: "
  echo "$(cri-dockerd --version)"
  # cridockerd=$(sudo cri-dockerd --version)
  # echo "${GREEN}CRI-Dockerd version: $cridockerd${NC}"
fi

if [ "$(dpkg-query -W -f='${Status}' kubectl 2>/dev/null | grep -c "ok installed")" -eq 0 ]; then
  echo -e "${RED}Kubectl is not installed.${NC}" >&2
else
  echo -e "${GREEN}Kubectl is installed.${NC}"
  kubectl=$(kubectl version --client --short)
  echo -e "${GREEN}Kubectl version: $kubectl${NC}"
fi

if ! [ -x "$(command -v helm)" ]; then
  echo -e "${RED}Helm is not installed.${NC}" >&2
else
  echo -e "${GREEN}Helm is installed.${NC}"
  helm=$(helm version --short)
  echo -e "${GREEN}Helm version: $helm${NC}"
fi

if ! [ -x "$(command -v terraform)" ]; then
  echo -e "${RED}Terraform is not installed.${NC}" >&2
else
  echo -e "${GREEN}Terraform is installed.${NC}"
  terraform=$(terraform version | head -1)
  echo -e "${GREEN}Terraform version: $terraform${NC}"
fi

if ! [ -x "$(command -v packer)" ]; then
  echo -e "${RED}Packer is not installed.${NC}" >&2
else
  echo -e "${GREEN}Packer is installed.${NC}"
  packer=$(packer version)
  echo -e "${GREEN}Packer version: $packer${NC}"
fi

if ! [ -x "$(command -v kind)" ]; then
  echo -e "${RED}Kind is not installed.${NC}" >&2
else
  echo -e "${GREEN}Kind is installed.${NC}"
  kind=$(kind version)
  echo -e "${GREEN}Kind version: $kind${NC}"
fi

if ! [ -x "$(command -v kubectx)" ]; then
  echo -e "${RED}Kubectx is not installed.${NC}" >&2
else
  echo -e "${GREEN}Kubectx is installed.${NC}"
#   kubectx has not version flag  
#   kubectx=$(kubectx --version)
#   echo -e "${GREEN}Kubectx version: $kubectx${NC}"
fi

if ! [ -x "$(command -v kubens)" ]; then
  echo -e "${RED}Kubens is not installed.${NC}" >&2
else
#   kubens has not version flag  
#   kubens=$(kubens --version)
#   echo -e "${GREEN}Kubens version: $kubens${NC}"
  echo -e "${GREEN}Kubens is installed.${NC}"
fi

if ! [ -x "$(command -v minikube)" ]; then
  echo -e "${RED}Minikube is not installed.${NC}" >&2
else 
  echo -e "${GREEN}Minikube is installed.${NC}"
  minikube=$(minikube version)
  echo -e "${GREEN}Minikube version: $minikube${NC}\n"
  echo -e "${GREEN}$(minikube status)"
fi

if ! [ -x "$(command -v crictl)" ]; then
  echo -e "${RED}Crictl is not installed.${NC}" >&2
else 
  echo -e "${GREEN}Crictl is installed.${NC}"
  crictl=$(crictl --version)
  echo -e "${GREEN}Crictl version: $crictl${NC}"
fi

if ! [ -x "$(command -v vagrant)" ]; then
  echo -e "${RED}Vagrant is not installed.${NC}" >&2
else 
  echo -e "${GREEN}Vagrant is installed.${NC}"
  vagrant=$(vagrant --version)
  echo -e "${GREEN}Vagrant version: $vagrant${NC}"
fi

if ! [ -x "$(command -v td-agent --version)" ]; then
  echo -e "${RED}td-agent is not installed.${NC}" >&2
else 
  echo -e "${GREEN}td-agent is installed.${NC}"
  td_agent=$(td-agent --version)
  echo -e "${GREEN}td-agent version: $td_agent${NC}"
fi

if ! [ -x "$(command -v crane)" ]; then
  echo -e "${RED}Crane is not installed.${NC}" >&2
else
  echo -e "${GREEN}Crane is installed.${NC}"
  crane=$(crane version)
  echo -e "${GREEN}Crane version: $crane${NC}"
fi

if ! [ -x "$(command -v argocd)" ]; then
  echo -e "${RED}ArgoCD is not installed.${NC}" >&2
else
  echo -e "${GREEN}ArgoCD is installed.${NC}"
  argocd=$(argocd version | head -1 | awk '{print $2}')
  echo -e "${GREEN}ArgoCD version: $argocd${NC}"
fi
