#!/bin/bash

IMAGE_TAG="${CIRCLE_SHA1:0:7}"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REPOSITORY_URL"

docker push "$REPOSITORY_URL/$REPOSITORY_NAME:${IMAGE_TAG}"

MANIFEST=$(aws ecr batch-get-image --region "$AWS_REGION" --repository-name "$REPOSITORY_NAME" --image-ids imageTag="$IMAGE_TAG" --query 'images[].imageManifest' --output text)

# Check if the image with tags "latest" and "$IMAGE_TAG" already exists
if aws ecr describe-images --region "$AWS_REGION" --repository-name "$REPOSITORY_NAME" --image-ids imageTag="latest" imageTag="$IMAGE_TAG" --query 'imageDetails' --output json | jq --arg IMAGE_TAG "$IMAGE_TAG" '.[] | select(.imageTags | contains(["latest", $IMAGE_TAG]))'; then
  echo "Image with tags 'latest' and '$IMAGE_TAG' already exists in the registry."
else
  aws ecr put-image --region "$AWS_REGION" --repository-name "$REPOSITORY_NAME" --image-tag "latest" --image-manifest "$MANIFEST"
fi
