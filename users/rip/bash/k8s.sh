#!/usr/bin/env bash

function sk(){
    KUBECONFIG=$(pwd)/.kube/config
    export KUBECONFIG
}
alias k='kubectl'
alias kdp="k describe pod"
alias kgt="kubectl -n kube-system describe secret kubernetes-dashboard-token | awk '/^token:/ {print $2}'"
alias kpfm='kubectl port-forward $(kubectl get pods -n ingress-nginx -o name -l app=auth-ingress-nginx | head -n 1) 8443:443 -n ingress-nginx'
alias kgpm='kubectl run --generator=run-pod/v1 --rm -i --tty testpod --image alpine:latest -n monitoring -- sh'