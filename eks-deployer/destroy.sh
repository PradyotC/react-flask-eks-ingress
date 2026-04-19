#!/bin/bash

export REGION=${AWS_REGION:-"us-east-1"}
export CLUSTER=${CLUSTER_NAME:-"capstone-cluster"}

echo "⚠️ WARNING: You are about to permanently destroy $CLUSTER."
read -p "Are you sure? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 0
fi

echo "🗑️ 1/4: Deleting Kubernetes resources (Ingress, Deployments, Services)..."
if [ -d "/workspace/k8s-manifests" ]; then
    kubectl delete -f /workspace/k8s-manifests/ --ignore-not-found=true
fi

echo "🗑️ 2/4: Deleting AWS Load Balancer Controller Helm chart..."
helm uninstall aws-load-balancer-controller -n kube-system || true

echo "🗑️ 3/4: Deleting IAM Service Account..."
eksctl delete iamserviceaccount --cluster=$CLUSTER --namespace=kube-system --name=aws-load-balancer-controller --region=$REGION || true

echo "🔥 4/4: Deleting EKS Cluster (This takes ~15 minutes)..."
eksctl delete cluster --name $CLUSTER --region $REGION

echo "✅ Teardown complete. You can safely type 'exit' to leave this container."
