resource "aws_ecr_repository" "app" {
  name                 = "warp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "warp"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

resource "aws_ecr_repository" "nginx" {
  name                 = "nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "nginx"
  }
}