# File auto-generated from ./bin/make-versions

terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    bucket = "-- DEFINE BUCKET NAME HERE --"
    key    = "-- DEFINE KEY PREFIX HERE --/terraform.tfstate"
    region = "-- DEFINE BUCKET _REGION HERE --"
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
      source  = "alekc/kubectl"
      version = "~> 2.0"
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
