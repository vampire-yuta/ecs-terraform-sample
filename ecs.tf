module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${local.project}-ecs"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.project}-ecs"
      }
    }
  }

  services = {
    app-service = {
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {
        app = {
          cpu       = 512
          memory    = 1024
          essential = true
          # image     = aws_ecr_repository.hello.repository_url
          image = aws_ecr_repository.nginx.repository_url
          secrets : [
            {
              name : "TEST",
              valueFrom : "arn:aws:secretsmanager:ap-northeast-1:195341589990:secret:test-AuLmKG:test::"
            }
          ],
          # image     = "nginx:latest"
          # port_mappings = [
          #   {
          #     name          = "app"
          #     containerPort = 3000
          #     protocol      = "tcp"
          #   }
          # ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          enable_cloudwatch_logging   = true
          create_cloudwatch_log_group = true
          memory_reservation          = 100
        }
      }

      # deployment_circuit_breaker = {
      #   enable   = true
      #   rollback = true
      # }

      assign_public_ip = false

      # subnet_ids = module.vpc.private_subnets
      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        # ingress_from_alb = {
        #   type                     = "ingress"
        #   from_port                = 80
        #   to_port                  = 80
        #   protocol                 = "tcp"
        #   description              = "Service port"
        #   source_security_group_id = module.alb.security_group_id
        # }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

resource "aws_ecr_repository" "nginx" {
  name                 = "${local.project}-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "hello" {
  name                 = "${local.project}-hello"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
