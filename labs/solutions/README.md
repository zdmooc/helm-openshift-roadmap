# Solutions des Laboratoires

## Vue d'ensemble

Ce dossier contient les solutions et les réponses aux laboratoires pratiques. Utilisez-les comme référence si vous êtes bloqué, mais essayez d'abord de résoudre les labs par vous-même !

## Important

**Attention** : Les solutions proposées ici sont des suggestions. Il peut y avoir plusieurs façons correctes de résoudre un problème. L'important est de comprendre les concepts et les principes sous-jacents.

## Solutions par niveau

### Niveau 0 - Préparation

**Lab 00: Installation de l'environnement**

Commandes clés :
```bash
# Vérifier la version d'OpenShift
oc version

# Vérifier les nœuds
oc get nodes

# Vérifier la version de Helm
helm version
```

### Niveau 1 - Helm User

**Lab 10: Déployer NGINX sur OpenShift**

```bash
# Créer un projet
oc new-project helm-demo

# Ajouter le dépôt Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

# Installer NGINX
helm install my-nginx bitnami/nginx --namespace helm-demo

# Créer une Route
oc expose service/my-nginx --name=my-nginx-route --namespace helm-demo

# Vérifier
helm list --namespace helm-demo
oc get route my-nginx-route --namespace helm-demo
```

**Lab 11: Upgrade et Rollback**

```bash
# Mettre à jour avec plus de replicas
helm upgrade my-nginx bitnami/nginx --namespace helm-demo --set replicaCount=2

# Vérifier l'historique
helm history my-nginx --namespace helm-demo

# Revenir à la version précédente
helm rollback my-nginx 1 --namespace helm-demo
```

## Support

Si vous avez des questions sur les solutions :
1. Consultez la documentation officielle
2. Vérifiez les logs avec `oc logs` ou `helm get values`
3. Posez une question sur le dépôt GitHub
