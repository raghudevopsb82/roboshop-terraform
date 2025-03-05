resource "grafana_folder" "test" {
  title = "My Folder"
  uid   = "my-folder-uid"
}

resource "grafana_dashboard" "test" {
  folder = grafana_folder.test.uid
  config_json = jsonencode({
    "title" : "My Dashboard",
    "uid" : "my-dashboard-uid"
  })
}

terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}
