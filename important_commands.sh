#start the docker container
docker run --rm -it \
  --env-file .env \
  -v $(pwd)/k8s-manifests:/workspace/k8s-manifests \
  pradyotc/eks-deployer:latest

kubectl get ingress capstone-ingress

#test the links
curl -v http://k8s-default-capstone-81f42579c4-1854062926.us-east-1.elb.amazonaws.com/
curl -v http://k8s-default-capstone-81f42579c4-1854062926.us-east-1.elb.amazonaws.com/dashboard
curl -v http://k8s-default-capstone-81f42579c4-1854062926.us-east-1.elb.amazonaws.com/api/v1/health

bash /usr/local/bin/destroy.sh
