
# Create a resource group
resource "azurerm_resource_group" "crudapp" {
  name     = "crudapp"
  location = "East US"

}
# create acr Container registery
resource "azurerm_container_registry" "acr" {
  name                = "crudappcontainerRegistry"
  location            = azurerm_resource_group.crudapp.location
  resource_group_name = azurerm_resource_group.crudapp.name
  sku                 = "Premium"
  admin_enabled       = false
}
# create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "crudappaks"
  location            = azurerm_resource_group.crudapp.location
  resource_group_name = azurerm_resource_group.crudapp.name
  dns_prefix          = "crudapp"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
# create role assignment for aks acr pull
resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}