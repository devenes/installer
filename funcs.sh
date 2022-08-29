GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
DOCKER_COMPOSE_VERSION="2.10.2"
TERRAFORM_VERSION="1.2.8"
PACKER_VERSION="1.8.3"
KIND_VERSION="0.11.1"
CRICTL_VERSION="v1.24.2"
CRI_LATEST_VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
VAGRANT_VERSION="2.2.19"

function install_ansible() {
  echo -e "${YELLOW}[+] Installing Ansible...${NC}"
  sudo apt -y remove needrestart
  sudo apt update -y
  sudo apt install software-properties-common -y
  sudo apt-add-repository -y --update ppa:ansible/ansible
  sudo apt install ansible -y
}

function install_docker() {
  echo -e "${YELLOW}[+] Installing Docker...${NC}"
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
  sudo apt-get install -y docker-ce
  sudo usermod -aG docker $USER
  sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo systemctl start docker
  sudo systemctl enable docker
}

function install_cri-dockerd() {
  echo -e "${YELLOW}[+] Installing CRI-Dockerd...${NC}"
  sudo apt update
  sudo apt install -y git wget curl

  if [ $(dpkg --print-architecture) = "amd64" ]; then
      wget https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_LATEST_VER}/cri-dockerd-${CRI_LATEST_VER}.amd64.tgz
      tar xvf cri-dockerd-${CRI_LATEST_VER}.amd64.tgz    
      sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
      rm -rf cri-dockerd-${CRI_LATEST_VER}.amd64.tgz cri-dockerd
  elif [ $(dpkg --print-architecture) = "arm64" ]; then   
      wget https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_LATEST_VER}/cri-dockerd-${CRI_LATEST_VER}.arm64.tgz
      tar xvf cri-dockerd-${CRI_LATEST_VER}.arm64.tgz
      sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
      rm -rf cri-dockerd-${CRI_LATEST_VER}.arm64.tgz cri-dockerd
  else
      echo "Unsupported architecture"
      exit 1
  fi

  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
  sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
  sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
  sudo systemctl daemon-reload
  sudo systemctl enable cri-docker.service
  sudo systemctl enable --now cri-docker.socket
  # wget https://storage.googleapis.com/golang/getgo/installer_linux
  # chmod +x ./installer_linux
  # ./installer_linux
  # # source ~/.bash_profile
  # sudo source root/.bash_profile
  # git clone https://github.com/Mirantis/cri-dockerd.git
  # cd cri-dockerd
  # mkdir bin
  # go build -o bin/cri-dockerd
  # mkdir -p /usr/local/bin
  # sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
  # sudo cp -a packaging/systemd/* /etc/systemd/system
  # sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
  # sudo systemctl daemon-reload
  # sudo systemctl enable cri-docker.service
  # sudo systemctl enable --now cri-docker.socket
  # sudo systemctl status cri-docker.socket | grep Active
  [ ! -e ./cri-dockerd* ] || sudo rm -f -d ./cri-dockerd*
}

function install_kubectl() {
  echo -e "${YELLOW}[+] Installing Kubectl...${NC}"
  sudo apt-get update -y
  sudo apt-get install -y apt-transport-https ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo apt-get update -y
  sudo apt-get install -y kubectl
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

function install_helm() {
  echo -e "${YELLOW}[+] Installing Helm...${NC}"
  curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
  sudo apt-get install apt-transport-https --yes
  echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update --yes
  sudo apt-get install helm --yes
}

function install_terraform() {
  echo -e "${YELLOW}[+] Installing Terraform...${NC}"
  sudo apt-get install -y unzip
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
}

function install_packer() {
  echo -e "${YELLOW}[+] Installing Packer...${NC}"
  sudo apt-get install -y unzip
  wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
  unzip packer_${PACKER_VERSION}_linux_amd64.zip
  sudo mv packer /usr/local/bin/
  rm packer_${PACKER_VERSION}_linux_amd64.zip
}

function install_kind() {
  echo -e "${YELLOW}[+] Installing Kind...${NC}"
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/
}

function install_kubectx() {
  echo -e "${YELLOW}[+] Installing Kubectx...${NC}"
  curl -Lo ./kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
  chmod +x ./kubectx
  sudo mv ./kubectx /usr/local/bin/
}

function install_kubens() {
  echo -e "${YELLOW}[+] Installing Kubens...${NC}"
  curl -Lo ./kubens https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
  chmod +x ./kubens
  sudo mv ./kubens /usr/local/bin/
}

function install_minikube() {
  echo -e "${YELLOW}[+] Installing Minikube...${NC}"
  sudo apt-get install -y conntrack
  sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  sudo dpkg -i minikube_latest_amd64.deb
  rm -f minikube_latest_amd64.deb
}

function install_crictl() {
  echo -e "${YELLOW}[+] Installing Crictl...${NC}"
  wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
  sudo tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
  rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz
}

function install_vagrant() {
  echo -e "${YELLOW}[+] Installing Vagrant...${NC}"
  sudo apt-get install -y virtualbox
  wget https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb
  sudo dpkg -i vagrant_${VAGRANT_VERSION}_x86_64.deb
  rm vagrant_${VAGRANT_VERSION}_x86_64.deb
}

function install_td-agent() {
  echo -e "${YELLOW}[+] Installing td-agent...${NC}"
  wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
  sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
  sudo curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
  sudo apt --fix-broken install
  sudo apt upgrade -y
  sudo systemctl start td-agent.service
  [ ! -e ./libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb ] || rm -f ./libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
  [ ! -e ./td-agent-* ] || rm -f ./td-agent-*
}

function install_crane() {
  echo -e "${YELLOW}[+] Installing Crane...${NC}"
  wget https://github.com/tsuru/crane/releases/download/1.0.0/crane-1.0.0-linux_amd64.tar.gz
  tar -xvzf crane-1.0.0-linux_amd64.tar.gz
  sudo mv crane /usr/local/bin/
  rm crane-1.0.0-linux_amd64.tar.gz
}

function install_argocd() {
  echo -e "${YELLOW}[+] Installing ArgoCD...${NC}"
  wget https://github.com/argoproj/argo-cd/releases/download/v2.2.5/argocd-linux-amd64 -O argocd
  chmod +x argocd
  sudo mv argocd /usr/local/bin/
}
