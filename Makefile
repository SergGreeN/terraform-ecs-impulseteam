.PHONY: init plan apply destroy build docker-login docker-push clone-repo

DOCKER_IMAGE_NAME=warp
DOCKER_TAG=latest
AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY=$(AWS_ACCOUNT_ID).dkr.ecr.us-west-2.amazonaws.com/$(DOCKER_IMAGE_NAME)
ECR_REPOSITORY_NGINX=$(AWS_ACCOUNT_ID).dkr.ecr.us-west-2.amazonaws.com/nginx
REPO_URL=https://github.com/sebo-b/warp.git

# Clone repository
clone-repo:
	git clone $(REPO_URL) ./src/warp

# Clear folder
clear:	
	rm -rf ./src/warp

# Init terraform
init:
	cd terraform && terraform init

# Plan terraform
plan:
	cd terraform && terraform plan

# Apply terraform
apply:
	cd terraform && terraform apply -auto-approve

# Destroy terraform
destroy: clear
	cd terraform && terraform destroy

# Build docker image
build: clone-repo
	docker build --platform linux/amd64 -t $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) ./src/warp

# Build docker image nginx
build-nginx:	
	docker build --platform linux/amd64 -t nginx:$(DOCKER_TAG) ./nginx

# Login to AWS ECR
docker-login:
	aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $(ECR_REPOSITORY)

# Push docker image to ECR
docker-push: docker-login
	docker tag $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) $(ECR_REPOSITORY):$(DOCKER_TAG)
	docker push $(ECR_REPOSITORY):$(DOCKER_TAG)

# Push docker image to ECR
docker-push-nginx: docker-login
	docker tag nginx:$(DOCKER_TAG) $(ECR_REPOSITORY_NGINX):$(DOCKER_TAG)
	docker push $(ECR_REPOSITORY_NGINX):$(DOCKER_TAG)

# Full deploy
deploy: init plan apply build build-nginx docker-push docker-push-nginx

nginx: build-nginx docker-push-nginx