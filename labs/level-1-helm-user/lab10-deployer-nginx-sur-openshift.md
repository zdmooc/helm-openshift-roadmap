_Titre: Lab 10: Déployer NGINX sur OpenShift_

## Objectif

Déployer une première application sur OpenShift en utilisant un chart Helm provenant d'un dépôt public (Bitnami). Créer une Route pour exposer l'application à l'extérieur du cluster.

## Contexte

Le cas d'usage le plus courant de Helm est de déployer des applications tierces (bases de données, serveurs web, etc.) qui sont déjà packagées sous forme de charts. Nous allons utiliser le chart NGINX de Bitnami, qui est une référence dans l'écosystème Helm.

## Étapes

### 1. Créer un nouveau projet

Créez un projet OpenShift dédié pour ce laboratoire :

```bash
oc new-project helm-demo
```

### 2. Ajouter le dépôt de charts Bitnami

Ajoutez le dépôt de charts de Bitnami à votre configuration Helm locale :

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### 3. Déployer le chart NGINX

Installez le chart NGINX dans le projet `helm-demo`. Nous nommons cette release `my-nginx`.

```bash
helm install my-nginx bitnami/nginx --namespace helm-demo
```

### 4. Exposer l'application avec une Route

Par défaut, le chart NGINX crée un Service de type `LoadBalancer`. Sur OpenShift, la manière idiomatique d'exposer un service est d'utiliser une **Route**. Créez une Route pour le service NGINX :

```bash
oc expose service/my-nginx --name=my-nginx-route --namespace helm-demo
```

## Vérifications

*   **Vérifiez la release Helm** :

    ```bash
    helm list --namespace helm-demo
    ```

    Vous devriez voir la release `my-nginx` avec le statut `deployed`.

*   **Vérifiez les Pods** :

    ```bash
    oc get pods --namespace helm-demo
    ```

    Vous devriez voir un Pod `my-nginx-xxxx` en cours d'exécution (`Running`).

*   **Accédez à l'application** :

    Récupérez l'URL de la Route :

    ```bash
    oc get route my-nginx-route --namespace helm-demo --template='{{.spec.host}}'
    ```

    Ouvrez cette URL dans votre navigateur. Vous devriez voir la page d'accueil de NGINX.

## Nettoyage

Pour supprimer la release et toutes les ressources associées, exécutez :

```bash
helm uninstall my-nginx --namespace helm-demo
```

Pour supprimer le projet :

```bash
oc delete project helm-demo
```
