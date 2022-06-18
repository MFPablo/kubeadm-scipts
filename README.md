v1.0
# Kubeadm Install and Config

## Deshabilitar memoria swap
```
$ sudo swapoff -a
```
Para mantenerla deshabilitada comentar la linea /swap en:
```
$ sudo nano /etc/fstab
```
## EN TODOS LOS NODOS 
### Configurar iptables para que vean el trafico bridge

```
$ lsmod | grep br_netfilter
$ sudo modprobe br_netfilter

$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

$ sudo sysctl --system
```
## Instalar Docker Engine

```
$ sudo apt update && sudo apt upgrade && sudo apt autoremove

$ sudo apt install apt-transport-https ca-certificates curl software-properties-common

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

$ sudo apt update

$ apt-cache policy docker-ce

$ sudo apt install docker-ce docker-ce-cli containerd.io

$ sudo systemctl enable docker

$ sudo systemctl status docker (Tiene que ser activo)
```
### Ejecutar docker sin sudo

```
$ sudo usermod -aG docker ${USER}

$ su - ${USER}

$ id -nG

$ sudo usermod -aG docker username

```
## Instalar kubectl, kubelet y kubeadm

```
$ sudo apt-get update

$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

$ sudo apt-get update

$ sudo apt-get install -y kubelet kubeadm kubectl 

```

Para congelar las versiones usamos:

```
$ sudo apt-mark hold kubelet kubeadm kubectl

```
## Varios

```
$ sudo apt install vim git wget neofetch
```

# Iniciando KUBEADM

- SOLO EN MASTER
```
$ sudo kubeadm init 

-- (Avanzado) --
$ kubeadm init --pod-network-cidr=10.10.0.0/16 --control-plane-endpoint=ENDPOINT
```
Una vez iniciado el master
```
$ mkdir -p $HOME/.kube

$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# Instalando CNI (weave)
```

$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
### Una vez instalado el CNI unir los workers
```
$ sudo kubeadm join <IP DEL MASTER> --cri-socket unix:///var/run/cri-dockerd.sock --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CERT>
```
## Para conocer el token
```
$ sudo kubeadm token create --print-join-command
```

## Resetear un cluster
```
$ sudo kubeadm reset -f 
```
## Agregando etiquetas a los nodos

El yaml esta configrado asi:
```
$ kubectl label nodes <NOMBRE_MASTER> rol=head

$ kubectl label nodes <NOMBRE_WORKER1> rol=worker1
```

### Para cambiar las etiquetas (Tambien cambiar en el yaml "nodeSelector")

```
$ kubectl label nodes <nombre_nodo> etiqueta=rol
```
Para eliminar una etiqueta

```
$  kubectl label nodes <nombre_nodo> <etiqueta>-
```
## Workloads en el control-plane

### TAINTS

Sacar
```
kubectl taint nodes pablo-note node-role.kubernetes.io/master-
kubectl taint nodes pablo-note node-role.kubernetes.io/control-plane-
```
Agregar
```
kubectl taint nodes pablo-note node-role.kubernetes.io/master=true:NoSchedule
kubectl taint nodes pablo-note node-role.kubernetes.io/control-plane:NoSchedule
```

# INFRA

### CASO DE 3 VMs 

- Ventajas: Mayor reliabilidad y managment del cluster.

```
** Control-plane **
2 cores
2 gb ram
10 gb disco

** HUB ** 
 4 Cores
 4 Gb ram
20 Gb disco

** NODOS **
16 Cores
40 Gb ram
40 Gb disco
```

### CASO DE 2 VMs

- Ventajas: Menos infra a asignar

```

** Control-Plane & HUB **
 4 Cores
 6 Gb ram
20 Gb disco

** NODOS **
16 Cores
40 Gb ram
30 Gb disco
```

## LINKS UTILES
```
https://www.youtube.com/watch?v=7fxuQip0Gn4
https://github.com/weaveworks/weave
https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#install
https://github.com/kodekloudhub/certified-kubernetes-administrator-course
https://github.com/deiveehan/xplore-kubernetes/blob/master/setup/custom/setup_updated.md
```
