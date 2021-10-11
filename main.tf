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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "nestjs-realworld-example-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress = [
    {
      description      = "Ingress rules"
      protocol         = -1
      self             = true
      from_port        = 0
      to_port          = 0
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
    }
  ]

  egress = [
    {
      description      = "Egress rules"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Type = "public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


resource "aws_ecs_cluster" "cluster" {
  name = "nestjs-realworld-example-cluster"
}

resource "aws_ecr_repository" "repo" {
  name                 = "nestjs-realworld-example"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "nestjs-realworld-example"
  execution_role_arn       = "arn:aws:iam::960673230763:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  container_definitions = jsonencode([
    {
      name      = "nestjs-realworld-example"
      image     = aws_ecr_repository.repo.repository_url
      cpu       = 10
      memory    = 512
      essential = true
      environment = [
        { "name" : "PORT", "value" : "3000" },
        { "name" : "TYPEORM_SYNCHRONIZE", "value" : "true" },
        { "name" : "TYPEORM_LOGGING", "value" : "true" },
        { "name" : "TYPEORM_ENTITIES", "value" : "./**/*.entity.js,./**/*.entity.ts" }
      ]
      secrets = [
        {
          "name" : "TYPEORM_CONNECTION",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_connection"
        },
        {
          "name" : "TYPEORM_HOST",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_host"
        },
        {
          "name" : "TYPEORM_USERNAME",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_username"
        },
        {
          "name" : "TYPEORM_PASSWORD",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_password"
        },
        {
          "name" : "TYPEORM_DATABASE",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_database"
        },
        {
          "name" : "TYPEORM_PORT",
          "valueFrom" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/nestjs-realworld-example-typeorm_port"
        }
      ]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "nestjs-realworld-example"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public.*.id
    security_groups  = [aws_default_security_group.default.id]
    assign_public_ip = true
  }
}
