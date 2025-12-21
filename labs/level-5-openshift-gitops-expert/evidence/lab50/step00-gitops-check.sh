#!/usr/bin/env bash
set -u

echo "=== DATE ==="
date
echo

echo "=== WHOAMI / PROJECT ==="
oc whoami || true
oc project -q || true
echo

echo "=== NAMESPACES (gitops) ==="
oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true
echo

echo "=== CRDs (argoproj/argocd) ==="
oc get crd | egrep -i 'argoproj|argocd|applications\.argoproj|appprojects\.argoproj|applicationsets\.argoproj' || true
echo

echo "=== OLM: packagemanifests (gitops) ==="
oc get packagemanifests -n openshift-marketplace | egrep -i 'gitops|openshift-gitops|argo' || true
echo

echo "=== packagemanifest openshift-gitops-operator (channels) ==="
oc get packagemanifest openshift-gitops-operator -n openshift-marketplace \
  -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}' 2>/dev/null || echo "NOT FOUND"
echo

echo "=== openshift-gitops namespace content ==="
oc get all -n openshift-gitops 2>/dev/null || echo "ns openshift-gitops: not found or empty"
echo

echo "=== argocd CRs (instances) ==="
oc get argocd -A 2>/dev/null || echo "argocd CRD missing or no instances"
echo

echo "=== routes openshift-gitops ==="
oc get route -n openshift-gitops 2>/dev/null || echo "no routes"
