# terraform/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Para um trabalho escolar, pode-se usar state local, 
  # mas em produção usaria um backend remoto.
}

provider "azurerm" {
  features {}
}

variable "image_tag" {
  description = "Tag da imagem Docker a ser deployada"
  type        = string
  default     = "latest"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-strapi-a3-satc"
  location = "East US"
}

resource "azurerm_container_group" "strapi" {
  name                = "strapi-container"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "strapi-satc-a3-${random_string.suffix.result}" # DNS único
  os_type             = "Linux"

  container {
    name   = "strapi"
    image  = "SEU_USUARIO_DOCKERHUB/strapi-a3:${var.image_tag}" # Substitua SEU_USUARIO_DOCKERHUB
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 1337
      protocol = "TCP"
    }
    
    # Variáveis de ambiente necessárias para o Strapi Production
    environment_variables = {
      NODE_ENV = "production"
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

container {
      name   = "strapi"
      image  = "thiagomeller/strapi-a3:${var.image_tag}"
      cpu    = "1"
      memory = "1.5"

      ports {
        port     = 1337
        protocol = "TCP"
      }
      
      # ATUALIZE ESTE BLOCO COM AS CHAVES
      environment_variables = {
        NODE_ENV            = "production"
        APP_KEYS            = "chaveSeguraA,chaveSeguraB" # Em prod, use strings longas e aleatórias
        API_TOKEN_SALT      = "saltGeradoAleatoriamente"
        ADMIN_JWT_SECRET    = "segredoAdminDificil"
        TRANSFER_TOKEN_SALT = "outroSaltDificil"
        JWT_SECRET          = "segredoJWTDificil"
        DATABASE_CLIENT     = "sqlite" # Garante que use o SQLite conforme o requisito
      }
    }
