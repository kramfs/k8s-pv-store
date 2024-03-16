minikube = {
  cluster_name       = "minikube"
  driver             = "docker" # Options: docker, podman, kvm2, qemu, hyperkit, hyperv, ssh
  kubernetes_version = "v1.28.3"  # See available options: "minikube config defaults kubernetes-version" or refer to: https://kubernetes.io/releases/
  container_runtime  = "containerd" # Options: docker, containerd, cri-o
  nodes              = "2"
}

# METALLB
# REF: https://artifacthub.io/packages/helm/metallb/metallb
metallb = {
  install           = true
  name              = "metallb-system"
  namespace         = "metallb-system"
  create_namespace  = true

  repository        = "https://metallb.github.io/metallb"
  chart             = "metallb"
  #version          = "4.9.1" # Chart version
  serviceMonitor_enabled = false
}


# CSI-DRIVER-NFS
# REF: https://github.com/kubernetes-csi/csi-driver-nfs/tree/master/charts
csi-driver-nfs = {
  install           = true
  name              = "csi-driver-nfs"
  namespace         = "csi-driver-nfs"
  create_namespace  = true

  repository        = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart             = "csi-driver-nfs"
  #version          = "4.6.0"           # Chart version
  #serviceMonitor_enabled = false
  nfs-storageclass-name      = "nfs-csi-custom"
}


# WORDPRESS
# REF: https://artifacthub.io/packages/helm/bitnami/wordpress
wordpress = {
  install           = true
  name              = "wordpress"
  namespace         = "wordpress"
  create_namespace  = true

  repository        = "oci://registry-1.docker.io/bitnamicharts"
  chart             = "wordpress"
  #version          = "4.6.0"           # Chart version
  memcached_enabled = true
}