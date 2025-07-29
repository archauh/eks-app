# 🌱 Flask App Deployment on AWS EKS with CI/CD

This project shows how to:
- Containerize a Python Flask app with Docker
- Push the image to Amazon ECR
- Deploy it to Amazon EKS (Kubernetes)
- Use NGINX Ingress Controller to expose the app
- Automate the build & deployment using GitHub Actions CI/CD

---

## ✅ Prerequisites
- AWS account
- IAM user with ECR & EKS permissions
- AWS CLI configured
- eksctl & kubectl installed
- Docker installed
- Helm installed
- GitHub repository

---

## 🚀 Step-by-Step Deployment

1️⃣ Create EKS Cluster

Using eksctl:
```bash
eksctl create cluster \
  --name my-eks-cluster \
  --region ap-south-1 \
  --nodes 2 \
  --node-type t3.medium

2️⃣ Update kubeconfig
aws eks update-kubeconfig --name my-eks-cluster --region ap-south-1

3️⃣ Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

Check ELB:
kubectl get svc -n ingress-nginx

4️⃣ Prepare your application
Files in this repo:

app.py – Flask application

Dockerfile – Build instructions

deployment.yml – Kubernetes Deployment

service.yml – Kubernetes Service

ingress.yml – Ingress resource

requirement.txt – Python dependencies


5️⃣ Build Docker image & push to ECR
Create ECR repository:
aws ecr create-repository --repository-name eks-app --region ap-south-1

Authenticate & push:
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-app:latest .
docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/eks-app:latest

6️⃣ Deploy to EKS manually (first time)

kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f ingress.yml

7️⃣ Setup CI/CD with GitHub Actions
Create .github/workflows/deploy.yml:

name: Build & Deploy to EKS

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-south-1

    - name: Login to Amazon ECR
      uses: aws-actions/amazon-ecr-login@v2

    - name: Build & push Docker image
      env:
        ECR_REGISTRY: <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com
        ECR_REPOSITORY: eks-app
        IMAGE_TAG: latest
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

    - name: Update kubeconfig
      run: aws eks update-kubeconfig --name my-eks-cluster --region ap-south-1

    - name: Restart deployment
      run: kubectl rollout restart deployment eks-app

8️⃣ Add GitHub secrets
In your GitHub repo → Settings → Secrets → Actions → New repository secret:

| Name                     | Value           |
| ------------------------ | --------------- |
| AWS\_ACCESS\_KEY\_ID     | (from IAM user) |
| AWS\_SECRET\_ACCESS\_KEY | (from IAM user) |

✅ Now your CI/CD is ready!
Every push to main branch:

Build Docker image

Push to ECR

Restart deployment on EKS

Your app updates automatically 🚀

🧠 Useful commands

| Action            | Command                                                               |
| ----------------- | --------------------------------------------------------------------- |
| View pods         | `kubectl get pods`                                                    |
| View services     | `kubectl get svc`                                                     |
| View ingress      | `kubectl get ingress`                                                 |
| View logs         | `kubectl logs <pod-name>`                                             |
| Update kubeconfig | `aws eks update-kubeconfig --name my-eks-cluster --region ap-south-1` |

🙌 Done!
You have:

Built & containerized your app

Deployed to EKS

Exposed with ingress

Automated with GitHub Actions


