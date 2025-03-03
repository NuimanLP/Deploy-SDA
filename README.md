# Deploying React Application to Google Cloud

This guide provides step-by-step instructions on how to deploy your React application to Google Cloud using Google Kubernetes Engine (GKE) with Nginx for load balancing between two frontend instances.

## Prerequisites

- Google Cloud Platform account
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed
- [Docker](https://docs.docker.com/get-docker/) installed
- A React application with a production build in the `build` directory

## Step 1: Prepare Your Google Cloud Project

1. Create a new Google Cloud project or select an existing one:

```bash
# Create a new project (optional)
gcloud projects create YOUR_PROJECT_ID --name="Your Project Name"

# Set the active project
gcloud config set project YOUR_PROJECT_ID
```

2. Enable the required APIs:

```bash
gcloud services enable container.googleapis.com containerregistry.googleapis.com
```

## Step 2: Create GKE Cluster

Create a Kubernetes cluster in Google Kubernetes Engine:

```bash
gcloud container clusters create react-app-cluster \
  --zone us-central1-a \
  --num-nodes=2 \
  --machine-type=e2-medium
```

## Step 3: Build and Push Docker Image

1. Build the Docker image using the provided Dockerfile:

```bash
# Build the image locally
docker build -t gcr.io/YOUR_PROJECT_ID/react-frontend:v1 .
```

2. Configure Docker to use Google Container Registry:

```bash
gcloud auth configure-docker
```

3. Push the image to Google Container Registry:

```bash
docker push gcr.io/YOUR_PROJECT_ID/react-frontend:v1
```

## Step 4: Update Kubernetes Configuration Files

1. Edit the `k8s-deployment.yaml` file to use your specific image:

```yaml
# Update the image line in k8s-deployment.yaml
image: gcr.io/YOUR_PROJECT_ID/react-frontend:v1
```

## Step 5: Deploy to GKE

1. Get authentication credentials for the cluster:

```bash
gcloud container clusters get-credentials react-app-cluster --zone us-central1-a
```

2. Apply the Kubernetes configuration files:

```bash
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
```

3. Verify the deployment:

```bash
# Check the deployment status
kubectl get deployments

# Check the pods
kubectl get pods

# Check the service
kubectl get services
```

## Step 6: Access Your Application

After the deployment is complete and the service is running, you can access your application using the external IP provided by the LoadBalancer service:

```bash
kubectl get services
```

Look for the external IP address under the `EXTERNAL-IP` column for your service. You can access your application by navigating to this IP address in a web browser.

## Understanding the Architecture

This deployment creates:

- Two replicas of your React application running on Nginx
- A Kubernetes LoadBalancer service that distributes traffic between the two replicas
- Each pod runs a Docker container with your React build files served by Nginx

## Troubleshooting

If you encounter issues:

1. Check the logs for your pods:

```bash
kubectl get pods
kubectl logs POD_NAME
```

2. Describe the services and deployments:

```bash
kubectl describe service react-frontend-service
kubectl describe deployment react-frontend
```

## Scaling the Application

To scale the number of frontend replicas:

```bash
kubectl scale deployment react-frontend --replicas=3
```

## Updating the Application

To update your application with a new version:

1. Build and push a new version of the Docker image:

```bash
docker build -t gcr.io/YOUR_PROJECT_ID/react-frontend:v2 .
docker push gcr.io/YOUR_PROJECT_ID/react-frontend:v2
```

2. Update the deployment to use the new image:

```bash
kubectl set image deployment/react-frontend react-frontend=gcr.io/YOUR_PROJECT_ID/react-frontend:v2
```

## Cleaning Up

To avoid incurring charges, delete the resources when they're no longer needed:

```bash
# Delete the service
kubectl delete service react-frontend-service

# Delete the deployment
kubectl delete deployment react-frontend

# Delete the GKE cluster
gcloud container clusters delete react-app-cluster --zone us-central1-a
```

