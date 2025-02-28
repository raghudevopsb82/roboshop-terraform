resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
az login --service-principal --username ${data.vault_generic_secret.az.data["ARM_CLIENT_ID"]} --password ${data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"]} --tenant ${data.vault_generic_secret.az.data["ARM_TENANT_ID"]}
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

resource "helm_release" "prometheus" {
  depends_on = [null_resource.kubeconfig]
  name       = "pstack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"
}

# This chart is not working - https://github.com/kubernetes/ingress-nginx/issues/10863
# resource "helm_release" "nginx-ingress" {
#   depends_on = [null_resource.kubeconfig]
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "kube-system"
# }

resource "null_resource" "nginx-ingress" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
 kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
EOF
  }
}



resource "kubernetes_secret" "external-dns" {
  metadata {
    name = "external-dns-azure"
    namespace = "kube-system"
  }
  data = {
    "tenantId" = data.vault_generic_secret.az.data["ARM_TENANT_ID"]
    "subscriptionId" = var.subscription_id
    "resourceGroup"=  data.azurerm_resource_group.main.name
    "aadClientId" = data.vault_generic_secret.az.data["ARM_CLIENT_ID"]
    "aadClientSecret" = data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"]
  }
}

# resource "helm_release" "external-dns" {
#   depends_on = [null_resource.kubeconfig]
#   name       = "external-dns"
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   namespace  = "kube-system"
#
#   set {
#       name  = "provider.name"
#       value = "azure"
#     }
# }


