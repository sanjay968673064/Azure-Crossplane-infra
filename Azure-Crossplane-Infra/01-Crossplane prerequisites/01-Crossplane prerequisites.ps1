$ErrorActionPreference = "SilentlyContinue"
$logFile = "output.txt"

"=== Installing Chocolatey ===" | Out-File $logFile

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-File $logFile -Append
    } catch {
        "Chocolatey install failed" | Out-File $logFile -Append
    }
} else {
    "Chocolatey already installed" | Out-File $logFile -Append
}

"=== Installing Helm ===" | Out-File $logFile -Append
choco install kubernetes-helm -y --no-progress | Out-File $logFile -Append

"=== Verifying Helm ===" | Out-File $logFile -Append
helm version | Out-File $logFile -Append

"=== Adding Helm Repo ===" | Out-File $logFile -Append
helm repo add crossplane-stable https://charts.crossplane.io/stable | Out-File $logFile -Append

"=== Updating Repo ===" | Out-File $logFile -Append
helm repo update | Out-File $logFile -Append

"=== Installing Crossplane ===" | Out-File $logFile -Append
helm install crossplane `
--namespace crossplane-system `
--create-namespace crossplane-stable/crossplane | Out-File $logFile -Append

"=== Pods Status ===" | Out-File $logFile -Append
kubectl get pods -n crossplane-system | Out-File $logFile -Append

Write-Host "Execution completed. Check output.txt"