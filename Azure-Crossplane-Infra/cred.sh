# Create the secret from your Azure service principal JSON file
kubectl create secret generic azure-secret --from-file=creds=./azure-credentials.json --namespace crossplane-system