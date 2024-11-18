git pull ; 
terraform init 
terraform plan 
sleep 10 
terraform apply -auto-approve

# Installing Metrics Server 
aws eks update-kubeconfig --name mysrikanth
kubectl get nodes
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create ns argocd && true
kubectl apply -f https://raw.githubusercontent.com/B58-CloudDevOps/learn-kubernetes/refs/heads/main/arogCD/argo.yaml -n argocd 