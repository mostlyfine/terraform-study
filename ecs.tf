resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task-def"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container-definitions.json")
}

resource "aws_ecs_service" "example" {
  name                              = "example-service"
  cluster                           = aws_ecs_cluster.example.arn
  task_definition                   = aws_ecs_task_definition.example.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.app_sg.security_group_id]
    subnets = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example-app"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }

  depends_on = [
    aws_lb.example
  ]
}

module "app_sg" {
  source      = "./security_group"
  name        = "app_sg"
  vpc_id      = aws_vpc.example.id
  port        = 3000
  cidr_blocks = [aws_vpc.example.cidr_block]
}

data "aws_iam_policy_document" "example" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }
}

module "execution_role" {
  source     = "./iam_role"
  name       = "example-execute-role"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.example.json
}
