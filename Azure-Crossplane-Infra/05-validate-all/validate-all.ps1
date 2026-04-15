# validate-all.ps1

$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outputFile = "crossplane-validation-$date.txt"

function Log {
    param([string]$msg)
    $msg | Tee-Object -FilePath $outputFile -Append
}

function Section {
    param([string]$title)
    Log ""
    Log "============================================================"
    Log "  $title"
    Log "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Log "============================================================"
}

Log "CROSSPLANE AZURE VALIDATION REPORT"
Log "Generated : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Log "Machine   : $env:COMPUTERNAME"
Log "User      : $env:USERNAME"

# ── Minikube ──────────────────────────────────────────────────────
Section "MINIKUBE STATUS"
Log "--- minikube status ---"
minikube status 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Cluster Info ──────────────────────────────────────────────────
Section "CLUSTER INFO"
Log "--- kubectl cluster-info ---"
kubectl cluster-info 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl get nodes ---"
kubectl get nodes 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Crossplane System ─────────────────────────────────────────────
Section "CROSSPLANE SYSTEM PODS"
Log "--- kubectl get pods -n crossplane-system ---"
kubectl get pods -n crossplane-system 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl get all -n crossplane-system ---"
kubectl get all -n crossplane-system 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Providers ─────────────────────────────────────────────────────
Section "PROVIDERS"
Log "--- kubectl get providers ---"
kubectl get providers 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe provider provider-azure-network ---"
kubectl describe provider provider-azure-network 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe provider provider-azure-containerservice ---"
kubectl describe provider provider-azure-containerservice 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── ProviderConfig ────────────────────────────────────────────────
Section "PROVIDERCONFIG"
Log "--- kubectl get providerconfig ---"
kubectl get providerconfig 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe providerconfig default ---"
kubectl describe providerconfig default 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Secret ────────────────────────────────────────────────────────
Section "AZURE SECRET"
Log "--- kubectl get secret azure-secret -n crossplane-system ---"
kubectl get secret azure-secret -n crossplane-system 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Resource Group ────────────────────────────────────────────────
Section "RESOURCE GROUP"
Log "--- kubectl get resourcegroup ---"
kubectl get resourcegroup 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe resourcegroup docs-quickstart-rg ---"
kubectl describe resourcegroup docs-quickstart-rg 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Virtual Network ───────────────────────────────────────────────
Section "VIRTUAL NETWORK"
Log "--- kubectl get virtualnetwork ---"
kubectl get virtualnetwork 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe virtualnetwork crossplane-quickstart-network ---"
kubectl describe virtualnetwork crossplane-quickstart-network 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Subnet ────────────────────────────────────────────────────────
Section "SUBNET"
Log "--- kubectl get subnet ---"
kubectl get subnet 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe subnet crossplane-quickstart-subnet ---"
kubectl describe subnet crossplane-quickstart-subnet 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── AKS Cluster ───────────────────────────────────────────────────
Section "AKS KUBERNETES CLUSTER"
Log "--- kubectl get kubernetescluster ---"
kubectl get kubernetescluster 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "--- kubectl describe kubernetescluster crossplane-quickstart-aks ---"
kubectl describe kubernetescluster crossplane-quickstart-aks 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Provider Logs ─────────────────────────────────────────────────
Section "PROVIDER LOGS - NETWORK (last 50 lines)"
$networkPod = kubectl get pods -n crossplane-system -o name 2>&1 | Select-String "provider-azure-network"
if ($networkPod) {
    kubectl logs -n crossplane-system $networkPod --tail=50 2>&1 | Tee-Object -FilePath $outputFile -Append
} else {
    Log "provider-azure-network pod not found"
}

Section "PROVIDER LOGS - CONTAINERSERVICE (last 50 lines)"
$aksPod = kubectl get pods -n crossplane-system -o name 2>&1 | Select-String "containerservice"
if ($aksPod) {
    kubectl logs -n crossplane-system $aksPod --tail=50 2>&1 | Tee-Object -FilePath $outputFile -Append
} else {
    Log "provider-azure-containerservice pod not found"
}

# ── Events ────────────────────────────────────────────────────────
Section "ALL KUBERNETES EVENTS (warnings only)"
kubectl get events --all-namespaces --field-selector type=Warning 2>&1 | Tee-Object -FilePath $outputFile -Append

# ── Summary ───────────────────────────────────────────────────────
Section "QUICK SUMMARY - ALL CROSSPLANE RESOURCES"
Log "--- kubectl get resourcegroup,virtualnetwork,subnet,kubernetescluster ---"
kubectl get resourcegroup,virtualnetwork,subnet,kubernetescluster 2>&1 | Tee-Object -FilePath $outputFile -Append

Log ""
Log "============================================================"
Log "  VALIDATION COMPLETE"
Log "  Output saved to: $outputFile"
Log "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Log "============================================================"

Write-Host ""
Write-Host "Output saved to: $outputFile" -ForegroundColor Green