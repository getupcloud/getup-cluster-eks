terraform {
  required_version = "~> 1.7.0"

  #  backend "s3" {
  #    bucket = "customer-terraform-eks"
  #    key    = "production/terraform.tfstate"
  #    region = "sa-east-1"
  #  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~>1.2"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.18"
    }
  }
}
