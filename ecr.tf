resource "aws_ecr_repository" "example" {
  name = "example-repository"
}

resource "aws_ecr_lifecycle_policy" "example" {
  repository = aws_ecr_repository.example.name
  policy     = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 10 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}
