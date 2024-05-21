# File auto-generated from ./bin/versions

terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "CLUSTER_NAME/terraform.tfstate"
    region = "CLUSTER_REGION"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34"
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
      version = "~> 1.2"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.18"
    }
  }
}
