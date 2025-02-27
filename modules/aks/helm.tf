resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
az login --service-principal --username ${data.vault_generic_secret.az.data["ARM_CLIENT_ID"]} --password ${data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"]} --tenant ${data.vault_generic_secret.az.data["ARM_TENANT_ID"]} --subscription ${data.vault_generic_secret.az.data["ARM_SUBSCRIPTION_ID"]}
az aks get-credentials --resource-group ${data.azurerm_resource_group.main.name} --name main --overwrite-existing
EOF
  }
}


resource "helm_release" "external-secrets" {
  depends_on = [null_resource.kubeconfig]
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
}

resource "null_resource" "external-secrets" {
  depends_on = [helm_release.external-secrets]
  provisioner "local-exec" {
    command = <<EOF
kubectl create secret generic vault-token --from-literal=token=${var.vault_token}
kubectl apply -f ${path.module}/files/secretstore.yaml
EOF
  }
}

resource "null_resource" "argocd" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f ${path.module}/files/argocd-ns.yaml
kubectl apply -f ${path.module}/files/argocd.yaml -n argocd
EOF
  }
}


