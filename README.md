# Usage

## SUMMARY OF STEPS TO BE DONE (AUTOMATED by TF)

- Bring up the cluster
- Install the csi-driver-nfs
- Create and apply a Kubernetes Storage Class (sc) that uses the `nfs.csi.k8s.io` CSI driver.
- Create a new PersistentVolumeClaim (pvc) using the nfs-csi storage class. This is as simple as specifying `storageClassName: nfs-csi` in the PVC definition
    - Verify it with: `kubectl describe pvc my-pvc`
     ```
      Type     Reason                 Age                    From                                                          Message
      ----     ------                 ----                   ----                                                          -------
      Normal   ExternalProvisioning   4m10s (x2 over 4m10s)  persistentvolume-controller                                   Waiting for a volume to be created either by the external provisioner 'nfs.csi.k8s.io' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
      Normal   Provisioning           4m10s                  nfs.csi.k8s.io_minikube_a046549b-e2f2-489e-a5f3-752a91490c3b  External provisioner is provisioning volume for claim "default/my-pvc"
      Normal   ProvisioningSucceeded  4m10s                  nfs.csi.k8s.io_minikube_a046549b-e2f2-489e-a5f3-752a91490c3b  Successfully provisioned volume pvc-f199c164-725b-46a4-97c0-1dc69190518d

     ```

## TASK UP
To bring up the cluster:
```
task up
```

Example:
```
❯ task up
task: [init] terraform init -upgrade

Initializing the backend...
Upgrading modules...
Downloading git::https://github.com/kramfs/tf-minikube-cluster.git for minikube_cluster...
- minikube_cluster in .terraform/modules/minikube_cluster

Initializing provider plugins...
- Finding latest version of hashicorp/helm...
- Finding latest version of hashicorp/kubernetes...
- Finding scott-the-programmer/minikube versions matching "~> 0.3"...
- Installing hashicorp/kubernetes v2.26.0...
- Installed hashicorp/kubernetes v2.26.0 (signed by HashiCorp)
- Installing scott-the-programmer/minikube v0.3.10...
- Installed scott-the-programmer/minikube v0.3.10 (self-signed, key ID 336AB9C62499A32D)
- Installing hashicorp/helm v2.12.1...
- Installed hashicorp/helm v2.12.1 (signed by HashiCorp)

....

Terraform has been successfully initialized!

```

## APPLICATION WORKFLOW

To deploy the app:
```
task deploy-app
```
To remove the app:
```
task destroy-app
```


## TASK CLEANUP
To destroy and clean up the cluster:
```
task cleanup
```

Example:

```
❯ task cleanup
task: [destroy] terraform destroy $TF_AUTO
module.minikube_cluster.minikube_cluster.docker: Refreshing state... [id=minikube]
helm_release.argocd: Refreshing state... [id=argocd]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # helm_release.argocd will be destroyed
  - resource "helm_release" "argocd" {
  ...
  }

  # module.minikube_cluster.minikube_cluster.docker will be destroyed
  - resource "minikube_cluster" "docker" {
  ...
  }

Plan: 0 to add, 0 to change, 2 to destroy.

                                                                                             .
.
.

Destroy complete! Resources: 2 destroyed.
task: [cleanup] find . -name '*terraform*' -print | xargs rm -Rf
```

Typing `task` will show up the available options
