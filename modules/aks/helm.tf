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

resource "null_resource" "dns-role-assignment" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
DNS_ID=$(az network dns zone show --name "azdevopsb82.online" --resource-group "${data.azurerm_resource_group.main.name}" --query "id" --output tsv)
az role assignment create --role "DNS Zone Contributor" --assignee "${azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id}" --scope "${DNS_ID}"
EOF
  }
}



resource "null_resource" "azure-json" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOT
cat <<-EOF > ${path.module}/azure.json
{
  "tenantId": "${data.azurerm_subscription.current.tenant_id}",
  "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
  "resourceGroup": "${data.azurerm_resource_group.main.name}",
  "useManagedIdentityExtension": true,
  "userAssignedIdentityID": "${azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id}"
}
EOF
kubectl create secret generic azure-config-file --namespace "default" --from-file=${path.module}/azure.json
EOT
  }
}


resource "helm_release" exteranal_dns {
  depends_on = [null_resource.azure-json, null_resource.dns-role-assignment]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  values     = [file("${path.module}/external-dns.yml")]
}

