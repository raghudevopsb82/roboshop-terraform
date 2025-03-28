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

# resource "null_resource" "argocd" {
#   depends_on = [null_resource.kubeconfig]
#   provisioner "local-exec" {
#     command = <<EOF
# kubectl apply -f ${path.module}/files/argocd-ns.yaml
# kubectl apply -f ${path.module}/files/argocd.yaml -n argocd
# EOF
#   }
# }

## ArgoCD Setup
resource "helm_release" "argocd" {
  depends_on = [null_resource.kubeconfig, helm_release.external-dns]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = false

  set {
    name  = "global.domain"
    value = "argocd-${var.env}.azdevopsb82.online"
  }

  values = [
    file("${path.module}/files/argo-helm.yml")
  ]
}


# resource "null_resource" "prometheus-additional-config" {
#   triggers = {
#     always = timestamp()
#   }
#   depends_on = [null_resource.kubeconfig, helm_release.prometheus]
#   provisioner "local-exec" {
#     command = <<EOT
# cat <<-EOF > ${path.module}/files/prometheus-additional-config.yaml
# prometheus:
#   prometheusSpec:
#     additionalScrapeConfigs: |
#       - job_name: 'azure-sp'
#         azure_sd_configs:
#           - tenant_id: ${data.azurerm_subscription.current.tenant_id}
#             client_id: ${data.vault_generic_secret.az.data["ARM_CLIENT_ID"]}
#             client_secret: ${data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"]}
#             subscription_id: ${data.azurerm_subscription.current.tenant_id}
#             resource_group: ${data.azurerm_resource_group.main.name}
#             port: 9100
#             refresh_interval: 30s
# EOF
# helm upgrade -i pstack -n kube-system -f ${path.module}/files/prometheus-additional-config.yaml
# EOT
#   }
# }

resource "helm_release" "prometheus" {
  depends_on = [null_resource.kubeconfig]
  name       = "pstack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"
  values = [
    #file("${path.module}/files/prom-stack.yaml"),
    templatefile("${path.module}/files/prom-stack.yaml", {
      tenant_id       = data.azurerm_subscription.current.tenant_id,
      client_id       = data.vault_generic_secret.az.data["ARM_CLIENT_ID"],
      client_secret   = data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"],
      subscription_id = data.azurerm_subscription.current.subscription_id,
      resource_group  = data.azurerm_resource_group.main.name,
      env             = var.env
    })
  ]
}

# grafaa default username / password - admin / prom-operator

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

# resource "kubernetes_secret" "external-dns" {
#   metadata {
#     name = "external-dns-azure"
#     namespace = "kube-system"
#   }
#   data = {
#       "azure.json" = base64decode(data.vault_generic_secret.az.data["EXTERNAL_DNS_SECRET_B64"])
#   }
# }

resource "null_resource" "external-dns-secret" {
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
kubectl create secret generic azure-config-file --namespace "kube-system" --from-file=${path.module}/azure.json
EOT
  }
}

resource "helm_release" "external-dns" {
  depends_on = [null_resource.kubeconfig, null_resource.external-dns-secret]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  values = [
    file("${path.module}/files/external-dns.yaml")
  ]
}


resource "helm_release" "filebeat" {
  depends_on = [null_resource.kubeconfig]
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  namespace  = "kube-system"
  values = [
    file("${path.module}/files/filebeat.yaml")
  ]
}

resource "helm_release" "cert-manager" {
  depends_on = [null_resource.kubeconfig]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "ingress-nginx"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "null_resource" "cert-manager" {
  depends_on = [null_resource.kubeconfig, helm_release.cert-manager]
  provisioner "local-exec" {
    command = <<EOT
cat <<-EOF > ${path.module}/issuer.yml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: raghudevopsb82@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
kubectl apply -f ${path.module}/issuer.yml
EOT
  }
}


