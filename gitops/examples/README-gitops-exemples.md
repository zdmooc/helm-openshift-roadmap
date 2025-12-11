_Titre: Exemples GitOps avec Argo CD_

## Introduction

Ce répertoire contient des exemples de manifestes **Application Argo CD** qui montrent comment déployer des charts Helm sur OpenShift en utilisant une approche GitOps.

## Qu'est-ce qu'une Application Argo CD ?

Une **Application** est une ressource Kubernetes personnalisée (CRD) fournie par Argo CD. Elle définit :

*   La source d'une application (un dépôt Git, un chart Helm, un manifeste Kustomize, etc.).
*   La destination (le cluster Kubernetes et le namespace cible).
*   La politique de synchronisation (comment Argo CD doit synchroniser l'état réel avec l'état souhaité).

## Structure d'une Application Argo CD

Voici un exemple simplifié :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/zdmooc/helm-openshift-roadmap
    targetRevision: HEAD
    path: charts/myapp-ocp
    helm:
      values: |
        replicaCount: 1
        # ... autres valeurs ...
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Champs clés

*   **`source.repoURL`** : L'URL du dépôt Git contenant le code source.
*   **`source.path`** : Le chemin vers le chart Helm dans le dépôt.
*   **`source.helm.values`** : Les valeurs à passer au chart Helm.
*   **`destination.namespace`** : Le namespace OpenShift où déployer l'application.
*   **`syncPolicy`** : Définit comment Argo CD gère la synchronisation (automatique, manuelle, etc.).

## Créer une Application Argo CD

### Étape 1 : Installer Argo CD

L'Operator OpenShift GitOps installe automatiquement une instance d'Argo CD dans le namespace `openshift-gitops`.

### Étape 2 : Créer le manifeste de l'Application

Créez un fichier YAML contenant la ressource `Application`. Vous pouvez utiliser les exemples fournis dans ce répertoire comme point de départ.

### Étape 3 : Appliquer le manifeste

Appliquez le manifeste avec `oc apply` :

```bash
oc apply -f application-myapp-dev.yaml -n openshift-gitops
```

### Étape 4 : Vérifier dans l'interface Argo CD

Accédez à l'interface web d'Argo CD et vérifiez que votre application apparaît. Vous pouvez cliquer sur le bouton **Sync** pour lancer la synchronisation.

## Exemples fournis

### `application-myapp-dev.yaml`

Déploie le chart `myapp-ocp` dans un environnement de développement avec des ressources minimales.

### `application-myapp-prod.yaml`

Déploie le chart `myapp-ocp` dans un environnement de production avec plus de réplicas et des ressources augmentées.

## Bonnes pratiques

*   **Utilisez des branches Git** : Pointez vos Applications vers des branches spécifiques (ex: `main` pour la prod, `develop` pour la dev) plutôt que `HEAD`.
*   **Gérez les secrets** : Ne commitez jamais de secrets en clair dans Git. Utilisez des outils comme Sealed Secrets ou External Secrets.
*   **Testez d'abord en dev** : Testez vos modifications dans un environnement de développement avant de les appliquer en production.
*   **Utilisez des namespaces distincts** : Séparez les environnements avec des namespaces différents.
*   **Activez l'auto-sync** : Activez la synchronisation automatique pour que Argo CD applique automatiquement les changements du Git.

## Dépannage

*   **L'Application est `OutOfSync`** : Cela signifie que l'état du cluster ne correspond pas à celui déclaré dans Git. Cliquez sur **Sync** pour synchroniser.
*   **Les Pods ne démarrent pas** : Vérifiez les logs des Pods avec `oc logs`. Assurez-vous que les images Docker sont accessibles et que les ressources sont suffisantes.
*   **Erreur de dépôt Git** : Vérifiez que l'URL du dépôt est correcte et que Argo CD a accès au dépôt (authentification SSH ou HTTPS).
