resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

locals {
  warp_database = "postgresql://${var.db_user}:${var.db_password}@${aws_db_instance.main.address}:5432/postgres"
}

resource "aws_ecs_task_definition" "app" {
  family    = "app"
  cpu       = 512
  memory    = 1024
  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      memory    = 512
      cpu       = 256
      essential = true
      logConfiguration = {
              logDriver =  "awslogs"
              options = {
                awslogs-group = "/ecs/app"
                awslogs-region = var.region
                awslogs-stream-prefix = "ecs"
              }
          },
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        {
          name  = "WARP_SECRET_KEY"
          value = var.warp_secret_key
        },
        {
          name  = "WARP_DATABASE"
          value = local.warp_database
        },
        {
          name  = "WARP_LANGUAGE_FILE"
          value = var.warp_language_file
        },
        # {
        #   name  = "WARP_DATABASE_INIT_SCRIPT"
        #   value = var.warp_database_init_script
        # }
      ]
    },
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.nginx.repository_url}:latest"
      memory    = 512
      cpu       = 256
      essential = true
      logConfiguration = {
              logDriver =  "awslogs"
              options = {
                awslogs-group = "/ecs/app"
                awslogs-region = var.region
                awslogs-stream-prefix = "ecs"
              }
          },
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.app
  ]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/app"
  retention_in_days = 3

  tags = {
    Name = "app"
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "app-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}