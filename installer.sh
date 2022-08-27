GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
TERRAFORM_VERSION="1.2.8"

function install_ansible() {
  echo -e "${YELLOW}Installing Ansible...${NC}"
  sudo apt update --yes
  sudo apt install software-properties-common -yes
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt install ansible --yes
}

if ! [ -x "$(command -v ansible)" ]; then
  echo -e "${RED}Ansible is not installed${NC}" >&2
  install_ansible  
else 
  echo -e "${GREEN}Ansible is installed.${NC}"
  ansible=$(ansible --version)
  echo -e "${GREEN}Ansible version: $ansible${NC}"
fi

function install_docker() {
  echo -e "${YELLOW}Installing Docker...${NC}"
    sudo apt-get update --yes
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo apt-get update --yes
    sudo apt-get install -y docker-ce
    sudo usermod -aG docker $USER
    sudo curl -L "https://github.com/docker/compose/releases/download/2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
}

if ! [ -x "$(command -v docker)" ]; then
  echo -e "${RED}Docker is not installed${NC}" >&2
  install_docker
else 
  echo -e "${GREEN}Docker is installed.${NC}"
  docker=$(docker --version)
  echo -e "${GREEN}Docker version: $docker${NC}"
fi

function install_kubectl() {
  echo -e "${YELLOW}Installing Kubectl...${NC}"
  sudo apt-get update --yes
  sudo apt-get install -y apt-transport-https ca-certificates curl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo apt-get update --yes
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

if ! [ -x "$(command -v kubectl)" ]; then
  echo -e "${RED}Kubectl is not installed${NC}" >&2
  install_kubectl
else 
  echo -e "${GREEN}Kubectl is installed.${NC}"
  kubectl=$(kubectl version --client --short)
  echo -e "${GREEN}Kubectl version: $kubectl${NC}"
fi

function install_helm() {
  echo -e "${YELLOW}Installing Helm...${NC}"
  curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
  sudo apt-get install apt-transport-https --yes
  echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update --yes
  sudo apt-get install helm --yes
}

if ! [ -x "$(command -v helm)" ]; then
  echo -e "${RED}Helm is not installed${NC}" >&2
  install_helm
else 
  echo -e "${GREEN}Helm is installed.${NC}"
  helm=$(helm version --short)
  echo -e "${GREEN}Helm version: $helm${NC}"
fi

function install_terraform() {
  echo -e "${YELLOW}Installing Terraform...${NC}"
  sudo apt-get install -y unzip
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
}

if ! [ -x "$(command -v terraform)" ]; then
  echo -e "${RED}Terraform is not installed${NC}" >&2
  install_terraform
else 
  echo -e "${GREEN}Terraform is installed.${NC}"
  terraform=$(terraform version)
  echo -e "${GREEN}Terraform version: $terraform${NC}"
fi
