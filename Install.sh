#!/bin/sh

function sys_update(){
	apt update && 
	apt upgrade && 
	apt autoremove &&
	apt install vim git wget neofetch
}

function deshabilitar_swap (){
    echo Deshabilitando swap...
    swapoff -a
    sed -i '/^\/swapfile/d' /etc/fstab
}

function iptables_config(){
    echo Configurando iptables...
    lsmod | grep br_netfilter
    sudo modprobe br_netfilter

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf br_netfilter
EOF

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
EOF

    sysctl --system
}

function docker_install(){
	echo Instalando Docker engine y runtime...
	apt update && apt upgrade
	sudo apt install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	apt update
	apt-cache policy docker-ce
	apt install docker-ce docker-ce-cli containerd.io
	systemctl enable docker
	systemctl status docker
	usermod -aG docker ${USER}
	su - ${USER}
	id -nG
	usermod -aG docker username
}

function kubernetes_install(){
	echo Instalando kubectl...
	apt-get update
	curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubelet kubeadm kubectl 
	systemctl status kubelet
	apt-mark hold kubelet kubeadm kubectl
}

function kubeadm_init(){
  kubeadm init 
  mkdir -p $HOME/.kube 
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
}

function cni_install (){
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
}

function master_worker(){
  echo "***********************"
  echo "*  MASTER O WORKER?   *"
  echo "***********************"	   
  read entrada

  if [[ $entrada = "master" ]];
  then
    clear
    echo "****************************************"
    echo "*   Iniciando instalacion en MASTER.   *"
    echo "****************************************"	 
    kubeadm_init
    cni_install
  else
	  exit
  fi  

}

function main() {
  echo Iniciando instalacion...
  sys_update
  deshabilitar_swap
  iptables_config
  docker_install
  kubernetes_install
  master_worker

}

main
