resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
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
kubectl apply -f /opt/vault-token.yml
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

resource helm_release exteranal_dns {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  values = [
    templatefile("${path.module}/external-dns.yml", {
      azure_subscription_id  = data.azurerm_subscription.current.subscription_id
      azure_tenant_id        = data.azurerm_subscription.current.tenant_id
      external_dns_client_id = azurerm_kubernetes_cluster.main.kubelet_identity.client_id
      azure_resource_group   = data.azurerm_resource_group.main.name
    })
  ]
}

