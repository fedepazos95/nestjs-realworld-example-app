terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 0.14"

  backend "remote" {
    organization = "fedepazos"

    workspaces {
      name = "nestjs-realworld-example-app"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecr_repository" "ecr" {
  name                 = "nestjs-realworld-example-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "service"
  container_definitions = jsonencode([
    {
      name        = "nestjs-realworld-example-app"
      image       = aws_ecr_repository.ecr.repository_url
      cpu         = 1
      memory      = 512
      essential   = true
      networkMode = "awsvpc"
      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr.repository_url
}
