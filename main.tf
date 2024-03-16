##############
## MINIKUBE ##
##############

module "minikube_cluster" {
  source              = "github.com/kramfs/tf-minikube-cluster"
  cluster_name        = lookup(var.minikube, "cluster_name", "minikube")
  driver              = lookup(var.minikube, "driver", "docker")                 # # Options: docker, podman, kvm2, qemu, hyperkit, hyperv, ssh
  kubernetes_version  = lookup(var.minikube, "kubernetes_version", null)         # See options: "minikube config defaults kubernetes-version" or refer to: https://kubernetes.io/releases/
  container_runtime   = lookup(var.minikube, "container_runtime", "containerd")  # Default: containerd. Options: docker, containerd, cri-o
  nodes               = lookup(var.minikube, "nodes", null)
}


################
## KUBERNETES ##
################

provider "kubernetes" {
  #config_path = "~/.kube/config"
  host = module.minikube_cluster.minikube_cluster_host

  client_certificate     = module.minikube_cluster.minikube_cluster_client_certificate
  client_key             = module.minikube_cluster.minikube_cluster_client_key
  cluster_ca_certificate = module.minikube_cluster.minikube_cluster_ca_certificate
}


##################
## HELM SECTION ##
##################

## HELM PROVIDER ##
provider "helm" {
  kubernetes {
    host = module.minikube_cluster.minikube_cluster_host
    client_certificate     = module.minikube_cluster.minikube_cluster_client_certificate
    client_key             = module.minikube_cluster.minikube_cluster_client_key
    cluster_ca_certificate = module.minikube_cluster.minikube_cluster_ca_certificate
  }
}


## HELM RELEASE ##

# METALLB
# REF: https://artifacthub.io/packages/helm/metallb/metallb
resource "helm_release" "metallb" {
  count             = var.metallb.install ? 1 : 0
  name              = var.metallb.name
  namespace         = var.metallb.namespace
  create_namespace  = var.metallb.create_namespace

  repository = var.metallb.repository
  chart      = var.metallb.chart
  version    = lookup(var.metallb, "version", null) # Chart version

  #values = [
  #  templatefile("./helm_values/metallb-system.yaml", {
  #    serviceMonitor_enabled = lookup(var.metallb, "serviceMonitor_enabled", false) # Check if servicemonitor will be enabled
  #  })
  #]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/helm_values/metallb-system-config.yaml"
  }

  #depends_on = [ helm_release.prometheus-stack ]
  #timeout = 600         # In seconds
}

# CSI-DRIVER-NFS
# REF: https://github.com/kubernetes-csi/csi-driver-nfs/tree/master/charts
resource "local_file" "sc-nfs" {
  content = templatefile("${path.module}/deploy/nfs/sc-nfs.yaml", {
    #nfs-storageclass-name = var.csi-driver-nfs.nfs-storageclass-name
    #nfs-storageclass-name = ${ nfs-storageclass-name != null ? nfs-storageclass-name : "nfs-csi" }
    nfs-storageclass-name = "${coalesce(var.csi-driver-nfs.nfs-storageclass-name, "nfs-csi")}"
  })
  filename = "${path.module}/deploy/nfs/sc-nfs-generated.yaml"
}

resource "helm_release" "csi-driver-nfs" {
  count             = var.csi-driver-nfs.install ? 1 : 0
  name              = var.csi-driver-nfs.name
  namespace         = var.csi-driver-nfs.namespace
  create_namespace  = var.csi-driver-nfs.create_namespace

  repository = var.csi-driver-nfs.repository
  chart      = var.csi-driver-nfs.chart
  version    = lookup(var.csi-driver-nfs, "version", null) # Chart version

  #values = [
  #  templatefile("./helm_values/csi-driver-nfs-system.yaml", {
  #    serviceMonitor_enabled = lookup(var.csi-driver-nfs, "serviceMonitor_enabled", false) # Check if servicemonitor will be enabled
  #  })
  #]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deploy/nfs/sc-nfs-generated.yaml"
  }

  depends_on = [ local_file.sc-nfs ]
}


## WORDPRESS
# REF: https://artifacthub.io/packages/helm/bitnami/wordpress

resource "random_string" "wp-password" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "helm_release" "wordpress" {
  count             = var.wordpress.install ? 1 : 0
  name              = var.wordpress.name
  namespace         = var.wordpress.namespace
  create_namespace  = var.wordpress.create_namespace

  repository = var.wordpress.repository
  chart      = var.wordpress.chart
  version    = lookup(var.wordpress, "version", null) # Chart version

  values = [
    templatefile("./helm_values/wordpress.yaml", {
      #serviceMonitor_enabled = lookup(var.wordpress, "serviceMonitor_enabled", false) # Check if servicemonitor will be enabled
      wp-password = random_string.wp-password.result
      memcached_enabled = lookup(var.wordpress, "memcached_enabled", false) # Check if memcached will be enabled
      storageClass = lookup(var.csi-driver-nfs, "nfs-storageclass-name", "nfs-csi")
    })
  ]

  depends_on = [ helm_release.csi-driver-nfs ]
}