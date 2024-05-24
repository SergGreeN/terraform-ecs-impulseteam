# Terraform ECS Deployment

This repository contains Terraform scripts and a Makefile to deploy the provided application in AWS ECS.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker installed

## Usage

Export the required variables:

```sh
    export TF_VAR_db_password="your_password"
```

```sh
    export TF_VAR_warp_secret_key="your_secret_key"
```

1. Clone the repository:

    ```sh
    git clone https://github.com/SergGreeN/terraform-ecs-impulseteam.git
    ```

2. Initialize Terraform:

    ```sh
    make init
    ```

3. Build the Docker image for warp:

    ```sh
    make build
    ```

4. Build the Docker image for nginx:

    ```sh
    make build-nginx
    ```

5. Initialize Terraform, Deploy the infrastructure and build and push images to ECR:

    ```sh
    make deploy
    ```

6. To destroy the infrastructure:

    ```sh
    make destroy
    ```

## Notes

- The RDS instance is not publicly accessible.
- Ensure to replace placeholders with actual values if needed.
