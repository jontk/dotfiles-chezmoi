#!/usr/bin/env bash
# Kubernetes (kubectl) aliases and functions

# Core kubectl aliases
alias k='kubectl'
alias kaf='kubectl apply -f'
alias keti='kubectl exec -ti'
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'
alias kcgc='kubectl config get-contexts'

# Get commands
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpall='kubectl get pods --all-namespaces'
alias kgd='kubectl get deployment'
alias kgs='kubectl get service'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kging='kubectl get ingress'
alias kgcm='kubectl get configmap'
alias kgsec='kubectl get secret'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgsa='kubectl get serviceaccount'
alias kgrs='kubectl get replicaset'
alias kgds='kubectl get daemonset'
alias kgsts='kubectl get statefulset'
alias kgj='kubectl get job'
alias kgcj='kubectl get cronjob'

# Describe commands
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kdn='kubectl describe node'
alias kdns='kubectl describe namespace'
alias kding='kubectl describe ingress'
alias kdcm='kubectl describe configmap'
alias kdsec='kubectl describe secret'

# Delete commands
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete service'
# kdelns replaced with function for safety (see below)
alias kdeling='kubectl delete ingress'
alias kdelcm='kubectl delete configmap'
alias kdelsec='kubectl delete secret'

# Safe namespace deletion with confirmation
kdelns() {
    local namespace="$1"
    if [[ -z "$namespace" ]]; then
        echo "Usage: kdelns <namespace>"
        return 1
    fi

    echo "WARNING: This will delete namespace '$namespace' and ALL resources in it!"
    kubectl get all -n "$namespace" 2>/dev/null
    read -p "Are you sure you want to delete namespace '$namespace'? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace "$namespace"
    else
        echo "Cancelled."
    fi
}

# Edit commands
alias ke='kubectl edit'
alias kep='kubectl edit pod'
alias ked='kubectl edit deployment'
alias kes='kubectl edit service'
alias kecm='kubectl edit configmap'
alias kesec='kubectl edit secret'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klt='kubectl logs --tail'
alias klp='kubectl logs -p'

# Namespace management (kns defined as function below)
alias kcns='kubectl create namespace'

# Port forwarding
alias kpf='kubectl port-forward'

# Apply/Create (kaf defined above)
alias ka='kubectl apply'
alias kca='kubectl create'
alias kcaf='kubectl create -f'

# Rollout
alias kru='kubectl rollout undo'
alias krh='kubectl rollout history'
alias krs='kubectl rollout status'
alias krr='kubectl rollout restart'

# Scale
alias ksc='kubectl scale'

# Exec
alias kex='kubectl exec'
alias kexi='kubectl exec -it'

# Top (metrics)
alias ktop='kubectl top'
alias ktopp='kubectl top pod'
alias ktopn='kubectl top node'

# Functions for common operations

# Get pod logs by partial name
klog() {
    local pod_pattern="$1"
    local namespace="${2:---all-namespaces}"
    
    if [[ -z "$pod_pattern" ]]; then
        echo "Usage: klog <pod-pattern> [namespace]"
        return 1
    fi
    
    if [[ "$namespace" == "--all-namespaces" || "$namespace" == "-A" ]]; then
        local match
        match=$(kubectl get pods --all-namespaces | awk -v pat="$pod_pattern" '$0 ~ pat {print $1, $2; exit}')
        if [[ -n "$match" ]]; then
            local ns pod
            ns=$(echo "$match" | awk '{print $1}')
            pod=$(echo "$match" | awk '{print $2}')
            kubectl logs -f -n "$ns" "$pod"
        else
            echo "No pod found matching pattern: $pod_pattern"
            return 1
        fi
    else
        local pod
        pod=$(kubectl get pods -n "$namespace" | awk -v pat="$pod_pattern" '$0 ~ pat {print $1; exit}')
        if [[ -n "$pod" ]]; then
            kubectl logs -f -n "$namespace" "$pod"
        else
            echo "No pod found matching pattern: $pod_pattern"
            return 1
        fi
    fi
}

# Execute shell in pod by partial name
ksh() {
    local pod_pattern="$1"
    local namespace="${2:-default}"
    local shell="${3:-/bin/bash}"
    
    if [[ -z "$pod_pattern" ]]; then
        echo "Usage: ksh <pod-pattern> [namespace] [shell]"
        return 1
    fi
    
    local pod
    pod=$(kubectl get pods -n "$namespace" | grep "$pod_pattern" | head -1 | awk '{print $1}')
    if [[ -n "$pod" ]]; then
        kubectl exec -it "$pod" -n "$namespace" -- "$shell" || kubectl exec -it "$pod" -n "$namespace" -- /bin/sh
    else
        echo "No pod found matching pattern: $pod_pattern"
        return 1
    fi
}

# Get events sorted by timestamp
kevents() {
    local namespace="${1:-default}"
    kubectl get events --sort-by='.lastTimestamp' -n "$namespace"
}

# Watch pods
kwatch() {
    local namespace="${1:-default}"
    watch -n 2 "kubectl get pods -n $namespace"
}

# Get all resources in a namespace
kall() {
    local namespace="${1:-default}"
    kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "$namespace"
}

# Delete all pods in error state (with confirmation)
kdelpe() {
    local namespace="${1:-default}"

    local error_pods
    error_pods=$(kubectl get pods -n "$namespace" 2>/dev/null | grep -E 'Error|CrashLoopBackOff|ImagePullBackOff' | awk '{print $1}')

    if [[ -z "$error_pods" ]]; then
        echo "No pods in error state found in namespace '$namespace'"
        return 0
    fi

    echo "Pods in error state in namespace '$namespace':"
    echo "$error_pods"
    echo
    read -p "Delete these pods? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$error_pods" | xargs -r kubectl delete pod -n "$namespace"
    else
        echo "Cancelled."
    fi
}

# Preview pods that would be deleted (dry-run)
kdelpedry() {
    local namespace="${1:-default}"
    echo "Pods in error state in namespace '$namespace' (dry-run):"
    kubectl get pods -n "$namespace" | grep -E 'Error|CrashLoopBackOff|ImagePullBackOff'
}

# Get pod resource usage
kres() {
    local namespace="${1:-default}"
    kubectl top pods -n "$namespace" --containers
}

# Decode secret
ksecret() {
    local secret="$1"
    local namespace="${2:-default}"
    local key="${3}"
    
    if [[ -z "$secret" ]]; then
        echo "Usage: ksecret <secret-name> [namespace] [key]"
        return 1
    fi
    
    if [[ -n "$key" ]]; then
        kubectl get secret "$secret" -n "$namespace" -o jsonpath="{.data.$key}" | base64 -d
    else
        kubectl get secret "$secret" -n "$namespace" -o json | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
    fi
}

# Quick deployment restart
krestart() {
    local deployment="$1"
    local namespace="${2:-default}"
    
    if [[ -z "$deployment" ]]; then
        echo "Usage: krestart <deployment> [namespace]"
        return 1
    fi
    
    kubectl rollout restart deployment/"$deployment" -n "$namespace"
    kubectl rollout status deployment/"$deployment" -n "$namespace"
}

# Get container images for all pods
kimages() {
    local namespace="${1:---all-namespaces}"
    kubectl get pods "$namespace" -o jsonpath="{range .items[*]}{'\n'}{.metadata.namespace}{'\t'}{.metadata.name}{'\t'}{range .spec.containers[*]}{.image}{', '}{end}{end}" | sort | column -t
}

# Port forward with automatic pod selection
kpforward() {
    local service_or_pattern="$1"
    local local_port="$2"
    local remote_port="${3:-$local_port}"
    local namespace="${4:-default}"
    
    if [[ -z "$service_or_pattern" ]] || [[ -z "$local_port" ]]; then
        echo "Usage: kpforward <service-or-pod-pattern> <local-port> [remote-port] [namespace]"
        return 1
    fi
    
    # Try as service first
    if kubectl get service "$service_or_pattern" -n "$namespace" &>/dev/null; then
        kubectl port-forward -n "$namespace" "service/$service_or_pattern" "$local_port:$remote_port"
    else
        # Try as pod pattern
        local pod
        pod=$(kubectl get pods -n "$namespace" | grep "$service_or_pattern" | head -1 | awk '{print $1}')
        if [[ -n "$pod" ]]; then
            kubectl port-forward -n "$namespace" "$pod" "$local_port:$remote_port"
        else
            echo "No service or pod found matching: $service_or_pattern"
            return 1
        fi
    fi
}

# Context switching helper
kctx() {
    local context="$1"
    
    if [[ -z "$context" ]]; then
        kubectl config get-contexts
    else
        kubectl config use-context "$context"
    fi
}

# Namespace switching helper
kns() {
    local namespace="$1"
    
    if [[ -z "$namespace" ]]; then
        kubectl get namespaces
    else
        kubectl config set-context --current --namespace="$namespace"
        echo "Switched to namespace: $namespace"
    fi
}

# Get YAML for resource
kyaml() {
    local resource="$1"
    local name="$2"
    local namespace="${3:-default}"
    
    if [[ -z "$resource" ]] || [[ -z "$name" ]]; then
        echo "Usage: kyaml <resource-type> <resource-name> [namespace]"
        return 1
    fi
    
    kubectl get "$resource" "$name" -n "$namespace" -o yaml
}

# Cleanup completed jobs
kcleanup() {
    local namespace="${1:-default}"
    kubectl delete jobs -n "$namespace" --field-selector status.successful=1
}

# Debug pod - create a debug pod with useful tools
kdebug() {
    local namespace="${1:-default}"
    local image="${2:-nicolaka/netshoot}"
    
    kubectl run debug-${RANDOM} --rm -it --image="$image" -n "$namespace" --restart=Never -- /bin/bash
}
