v1.0
# kubeadm-scipts

## Deshabilitar memoria swap

```
$ sudo swapoff -a
```
- Para mantenerla deshabilitada comentar la linea /swap en:
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

- Para congelar las versiones usamos:

```

$ sudo apt-mark hold kubelet kubeadm kubectl

```

### Instalación de varios

```
$ sudo apt install vim git wget neofetch
```
# Iniciando KUBEADM

- Si el runtime no arranca:
```
$ docker system prune
```
```
- Si hay mas de dos CRI endpoints
```
$ sudo kubeadm init --cri-socket ENDPOINT
```


- Master
```
$ sudo kubeadm init
kubeadm init --pod-network-cidr=IP --control-plane-endpoint=ENDPOINT
```


# EXTRAS

## CRI-DOCKER INSTALACION

``` bash
https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/#:~:text=Install%20cri%2Ddockerd%20from%20source&text=Confirm%20installation%20by%20checking%20version%20of%20Go.&text=Run%20the%20commands%20below%20to,dockerd%20on%20a%20Linux%20system.

```

## Agregando etiquetas a los nodos

```
$ kubectl label nodes nombre_nodo etiqueta=rol
```