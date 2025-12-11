_Titre: Lab 51: Introduction aux Operators basés sur Helm_

## Objectif

Comprendre le concept des Operators Kubernetes et apprendre à packager un chart Helm existant en tant qu'Operator simple en utilisant le **Operator SDK**.

## Contexte

Un **Operator** est une méthode pour packager, déployer et gérer une application Kubernetes. Il étend l'API de Kubernetes avec des `Custom Resources` (CR) pour automatiser le cycle de vie d'une application au-delà de ce que Helm seul peut faire (ex: mises à jour complexes, backups, redimensionnement). Le Operator SDK est un outil qui facilite la création d'Operators, y compris à partir d'un chart Helm existant.

## Étapes

### 1. Installer le Operator SDK

Suivez le [guide d'installation officiel](https://sdk.operatorframework.io/docs/installation/) pour installer la CLI `operator-sdk`.

### 2. Créer un nouveau projet d'Operator

Créez un répertoire pour votre projet d'Operator et initialisez un nouveau projet de type Helm :

```bash
mkdir myapp-operator
cd myapp-operator
operator-sdk init --plugins=helm --domain=example.com --group=apps --version=v1alpha1 --kind=MyApp
```

Cette commande crée un squelette de projet pour un Operator qui gérera une nouvelle ressource `MyApp`.

### 3. Intégrer le chart Helm

Le SDK a créé un chart Helm par défaut dans `helm-charts/myapp`. Nous allons le remplacer par notre chart `myapp-ocp`.

*   Supprimez le contenu de `helm-charts/myapp`.
*   Copiez le contenu de votre chart `myapp-ocp` (de `../../charts/myapp-ocp`) dans ce répertoire `helm-charts/myapp`.

### 4. Déployer l'Operator sur le cluster

L'Operator SDK fournit des commandes pour construire l'image de l'Operator et le déployer sur votre cluster OpenShift.

*   **Installer les CRDs** (Custom Resource Definitions) de l'Operator :

    ```bash
    make install
    ```

*   **Déployer l'Operator** dans un namespace :

    ```bash
    oc new-project myapp-operator-test
    make deploy IMG=<image-registry>/<user>/myapp-operator:v0.0.1
    ```
    *Note: Vous devez pousser l'image de l'Operator vers un registre d'images accessible par votre cluster (ex: `quay.io`, `docker.io`). Pour un test local avec CRC, vous pouvez utiliser le registre interne d'OpenShift.*

### 5. Déployer une instance de l'application via l'Operator

Maintenant que l'Operator est en cours d'exécution, vous pouvez créer une ressource `MyApp` (notre CR). L'Operator détectera cette ressource et déploiera le chart Helm en conséquence.

Examinez et modifiez le fichier `config/samples/apps_v1alpha1_myapp.yaml`. Il vous permet de spécifier les `values` à passer au chart Helm.

Appliquez ce manifeste :

```bash
oc apply -f config/samples/apps_v1alpha1_myapp.yaml -n myapp-operator-test
```

## Vérifications

*   **Vérifiez que l'Operator est en cours d'exécution** :

    ```bash
    oc get pods -n myapp-operator-test -l control-plane=controller-manager
    ```

*   **Vérifiez que la ressource `MyApp` a été créée** :

    ```bash
    oc get myapp -n myapp-operator-test
    ```

*   **Vérifiez que le chart Helm a été déployé** :

    L'Operator aurait dû créer une release Helm. Vérifiez que les ressources de `myapp-ocp` (Deployment, Service, Route) existent dans le namespace.

    ```bash
    oc get all,route -n myapp-operator-test
    ```

## Nettoyage

```bash
oc delete -f config/samples/apps_v1alpha1_myapp.yaml -n myapp-operator-test
make undeploy
oc delete project myapp-operator-test
```
