git pull ; 
terraform init 
terraform plan 
sleep 10 
terraform apply -auto-approve

# Installing Metrics Server 
aws eks update-kubeconfig --name b58-eks
kubectl get nodes
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml