_Titre: Lab 50: GitOps avec Argo CD et Helm pour le Multi-Environnement_

## Objectif

Déployer une application sur plusieurs environnements OpenShift (dev, prod) en utilisant une approche GitOps. Nous utiliserons Argo CD pour synchroniser l'état de nos environnements avec des manifestes déclarés dans un dépôt Git.

## Contexte

Le GitOps est une pratique qui consiste à utiliser un dépôt Git comme unique source de vérité pour déclarer l'état souhaité d'une infrastructure. Argo CD est un outil de Continuous Delivery qui s'intègre à Kubernetes/OpenShift pour appliquer cet état. Combiné à Helm, il permet de gérer des déploiements complexes et multi-environnements de manière automatisée et fiable.

## Étapes

### 1. Installer l'Operator OpenShift GitOps

Dans la console web d'OpenShift, allez dans `Operators > OperatorHub` et installez l'operator **OpenShift GitOps**. Cela déploiera une instance d'Argo CD dans le namespace `openshift-gitops`.

### 2. Préparer le dépôt Git

Pour ce lab, nous allons utiliser ce même dépôt `helm-openshift-roadmap` comme source pour Argo CD. Les manifestes d'application se trouvent dans le dossier `gitops/argocd-apps/`.

### 3. Examiner les manifestes d'Application Argo CD

Ouvrez les fichiers `gitops/argocd-apps/application-myapp-dev.yaml` et `application-myapp-prod.yaml`. Ce sont des CRD (Custom Resource Definitions) de type `Application` pour Argo CD.

Notez les sections clés :

*   **`project`**: Le projet Argo CD (par défaut `default`).
*   **`source`**: Définit le dépôt Git (`repoURL`), le chemin vers le chart (`path`), et le fichier de valeurs à utiliser (`valueFiles`).
*   **`destination`**: Le cluster et le namespace OpenShift où déployer l'application.

### 4. Créer les projets cibles

Argo CD ne crée pas les namespaces par défaut. Créez-les manuellement :

```bash
oc new-project myapp-dev
oc new-project myapp-prod
```

### 5. Déployer les Applications Argo CD

Appliquez les manifestes d'Application dans le namespace où Argo CD est installé (`openshift-gitops`) :

```bash
oc apply -f gitops/argocd-apps/application-myapp-dev.yaml -n openshift-gitops
oc apply -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops
```

## Vérifications

*   **Interface Argo CD** :

    Récupérez l'URL de l'interface Argo CD :

    ```bash
    oc get route -n openshift-gitops -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].spec.host}'
    ```

    Connectez-vous avec vos identifiants OpenShift. Vous devriez voir deux applications : `myapp-dev` et `myapp-prod`.

*   **Synchronisation** :

    Initialement, les applications seront `OutOfSync`. Cliquez sur le bouton `Sync` pour chaque application pour lancer le déploiement.

*   **Vérification dans OpenShift** :

    Vérifiez que les ressources ont été créées dans les namespaces `myapp-dev` et `myapp-prod` et qu'elles correspondent aux `values` de chaque environnement.

    ```bash
    oc get all -n myapp-dev
    oc get all -n myapp-prod
    ```

## Nettoyage

Supprimez les Applications Argo CD :

```bash
oc delete -f gitops/argocd-apps/application-myapp-dev.yaml -n openshift-gitops
oc delete -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops
```

Supprimez les projets :

```bash
oc delete project myapp-dev myapp-prod
```
