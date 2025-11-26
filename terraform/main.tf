# terraform/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "image_tag" {
  description = "Tag da imagem Docker a ser deployada"
  type        = string
  default     = "latest"
}

# 1. Cria o Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-strapi-a3-satc"
  location = "East US"
}

# 2. Cria o Grupo de Containers (ACI)
resource "azurerm_container_group" "strapi" {
  name                = "strapi-container"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "strapi-satc-a3-${random_string.suffix.result}"
  os_type             = "Linux"

  # O bloco container TEM QUE ESTAR AQUI DENTRO
  container {
    name   = "strapi"
    image  = "thiagomeller/strapi-a3:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 1337
      protocol = "TCP"
    }
    
    # Variáveis de ambiente para Produção (Azure)
    environment_variables = {
      NODE_ENV            = "production"
      DATABASE_CLIENT     = "sqlite"
      APP_KEYS            = "chaveSeguraA,chaveSeguraB"
      API_TOKEN_SALT      = "saltGeradoAleatoriamente"
      ADMIN_JWT_SECRET    = "segredoAdminDificil"
      TRANSFER_TOKEN_SALT = "outroSaltDificil"
      JWT_SECRET          = "segredoJWTDificil"
    }
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

output "app_url" {
  value = "http://${azurerm_container_group.strapi.fqdn}:1337"
}