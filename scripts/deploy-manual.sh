#!/bin/bash
set -e

AWS_PROFILE=devops
AWS_REGION=ap-southeast-1
AWS_ACCOUNT=905418233489
ECR_REGISTRY="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_REPO="${ECR_REGISTRY}/tindaph-backend"
STOREFRONT_REPO="${ECR_REGISTRY}/tindaph-storefront"
ECS_CLUSTER=tindaph-ecs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE \
  | docker login --username AWS --password-stdin $ECR_REGISTRY

echo ""
echo "==> Building backend image..."
docker build \
  -t "${BACKEND_REPO}:latest" \
  -f "${ROOT_DIR}/Dockerfile.prod" \
  "$ROOT_DIR"

echo ""
echo "==> Pushing backend image..."
docker push "${BACKEND_REPO}:latest"

echo ""
echo "==> Building storefront image..."
docker build \
  -t "${STOREFRONT_REPO}:latest" \
  -f "${ROOT_DIR}/storefront/Dockerfile.prod" \
  "${ROOT_DIR}/storefront"

echo ""
echo "==> Pushing storefront image..."
docker push "${STOREFRONT_REPO}:latest"

echo ""
echo "==> Forcing new ECS deployments..."
aws ecs update-service \
  --cluster $ECS_CLUSTER \
  --service tindaph-backend \
  --force-new-deployment \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  --output text --query 'service.serviceName'

aws ecs update-service \
  --cluster $ECS_CLUSTER \
  --service tindaph-storefront \
  --force-new-deployment \
  --profile $AWS_PROFILE \
  --region $AWS_REGION \
  --output text --query 'service.serviceName'

echo ""
echo "==> Waiting for services to stabilize (this may take ~5 minutes)..."
aws ecs wait services-stable \
  --cluster $ECS_CLUSTER \
  --services tindaph-backend tindaph-storefront \
  --profile $AWS_PROFILE \
  --region $AWS_REGION

echo ""
echo "✅ Deployment complete!"
echo "   Storefront: https://tindaph.app"
echo "   API:        https://api.tindaph.app"
echo "   Admin:      https://admin.tindaph.app"
