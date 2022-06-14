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

## Instalar Docker Engine

```
$ sudo apt update

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
## INSTALACION CRI-DOCKER 

- Seleccionando la ultima version

```
$ VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
echo $VER
```
- Descargando el binario

```
$ wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xvf cri-dockerd-${VER}.amd64.tgz
```
- Moviendo el binario a local/bin
```
$ sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
```
- Validando instalacion exitosa

```
$ cri-dockerd --version
```
- Configurando systemd para cri-docker

```
$ wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
$ wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
$ sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
$ sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
```
- Iniciando y habilitando los servicios

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable cri-docker.service
$ sudo systemctl enable --now cri-docker.socket
```
- Confirmando que el servicio esta correindo
```
$ systemctl status cri-docker.socket
```
## Varios

```
$ sudo apt install vim git wget neofetch
```
# Iniciando KUBEADM

- Si el runtime no arranca:
```
$ docker system prune
```
- Si hay mas de dos CRI endpoints
```
$ sudo kubeadm init --cri-socket ENDPOINT
```

- Master
```
$ sudo kubeadm init --cri-socket unix:///var/run/cri-dockerd.sock
kubeadm init --pod-network-cidr=IP --control-plane-endpoint=ENDPOINT
```
Una vez iniciado el master
```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config


$ sudo kubeadm join <IP DEL MASTER> --cri-socket unix:///var/run/cri-dockerd.sock --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CERT>
```
## Para conocer el token
```
$ sudo kubeadm token create --print-join-command
```

## Resetear un cluster
```
$ sudo kubeadm reset -f --cri-socket unix:///var/run/cri-dockerd.sock
```
## Agregando etiquetas a los nodos

```
$ kubectl label nodes <nombre_nodo> etiqueta=rol
```
Para eliminar una etiqueta

```
$  kubectl label nodes <nombre_nodo> <etiqueta>-
```


# EXTRAS
## CALICO

### Instalar calico
```
$ cd ~/agilitydocs/docs/class1/kubernetes/calico

$ curl https://docs.projectcalico.org/manifests/calico.yaml -O

$ vim calico.yaml

$ kubectl apply -f calico.yaml
```
### Instalar calicoctl
```
$ curl -O -L https://github.com/projectcalico/calicoctl/releases/download/v3.15.1/calicoctl

$ chmod +x calicoctl

$ sudo mv calicoctl /usr/local/bin
```
