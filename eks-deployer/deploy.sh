#!/bin/bash
set -e

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "❌ Error: AWS credentials not found in .env file."
    exec /bin/bash
fi

export REGION=${AWS_REGION:-"us-east-1"}
export CLUSTER=${CLUSTER_NAME:-"capstone-cluster"}

echo "🔧 Configuring AWS Authentication..."
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $REGION
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🔍 Checking EKS Cluster status..."
if eksctl get cluster --name $CLUSTER --region $REGION > /dev/null 2>&1; then
    echo "✅ Cluster '$CLUSTER' exists. Connecting..."
    aws eks update-kubeconfig --region $REGION --name $CLUSTER
else
    echo "🚀 Creating EKS Fargate cluster '$CLUSTER' in $REGION (~15 mins)..."
    eksctl create cluster --name $CLUSTER --region $REGION --fargate
fi

export VPC_ID=$(aws eks describe-cluster --name $CLUSTER --region $REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)

echo "🔐 Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER --region $REGION --approve

echo "⚖️ Installing AWS Load Balancer Controller via Helm..."
curl -s -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json || true

eksctl create iamserviceaccount \
  --cluster=$CLUSTER \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --region=$REGION || true

helm repo add eks https://aws.github.io/eks-charts || true
helm repo update eks
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID

echo "⏳ Waiting for AWS Load Balancer Controller to be ready (Fargate takes 1-3 mins)..."
kubectl rollout status deployment aws-load-balancer-controller -n kube-system --timeout=5m

echo "☸️ Applying Kubernetes manifests..."
if [ -d "/workspace/k8s-manifests" ]; then
    kubectl apply -f /workspace/k8s-manifests/

echo "☸️ Applying Kubernetes manifests..."
if [ -d "/workspace/k8s-manifests" ]; then
    kubectl apply -f /workspace/k8s-manifests/
    echo "✅ Manifests applied successfully!"
else
    echo "⚠️ Warning: /workspace/k8s-manifests not found."
fi

echo "============================================================"
echo "🎉 INFRASTRUCTURE READY! You are now in the Cluster Terminal."
echo "   - View Pods:    kubectl get pods -A"
echo "   - View Ingress: kubectl get ingress -w"
echo "   - Teardown:     destroy.sh"
echo "============================================================"

# This command hands control of the container over to your keyboard
exec /bin/bash
