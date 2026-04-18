#!/bin/bash
set -e

# 1. Validate Input
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "❌ Error: AWS credentials not found. Pass them as environment variables."
    exit 1
fi

REGION=${AWS_REGION:-"us-east-1"}
CLUSTER=${CLUSTER_NAME:-"capstone-cluster"}

echo "🔧 Configuring AWS CLI..."
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $REGION

echo "🔍 Checking if EKS cluster '$CLUSTER' exists..."
if eksctl get cluster --name $CLUSTER --region $REGION > /dev/null 2>&1; then
    echo "✅ Cluster '$CLUSTER' already exists. Updating kubeconfig..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER
else
    echo "🚀 Creating EKS Fargate cluster '$CLUSTER' in $REGION."
    echo "⏳ This will take 15-20 minutes. Do not close the terminal..."
    eksctl create cluster --name $CLUSTER --region $REGION --fargate
fi

echo "🔐 Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER --region $REGION --approve

echo "☸️ Applying Kubernetes manifests..."
if [ -d "/workspace/k8s-manifests" ]; then
    kubectl apply -f /workspace/k8s-manifests/
    echo "✅ Manifests applied successfully!"

    echo "🌐 Fetching Ingress URL..."
    kubectl get ingress split-router-ingress
else
    echo "⚠️ No k8s-manifests directory found in /workspace. Skipping deployment."
fi

echo "🎉 Run complete!"