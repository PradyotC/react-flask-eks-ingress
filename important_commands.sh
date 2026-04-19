#start the docker container
docker run --rm -it \
  --env-file .env \
  -v $(pwd)/k8s-manifests:/workspace/k8s-manifests \
  pradyotc/eks-deployer:latest

#test the links
curl -v http://k8s-default-capstone-81f42579c4-1898413698.us-east-1.elb.amazonaws.com/
curl -v http://k8s-default-capstone-81f42579c4-1898413698.us-east-1.elb.amazonaws.com/dashboard
curl -v http://k8s-default-capstone-81f42579c4-1898413698.us-east-1.elb.amazonaws.com/api/v1/health
