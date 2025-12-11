_Titre: Lab 31: Gérer les Configurations par Environnement (Dev vs. Prod)_ 

## Objectif

Utiliser des fichiers de valeurs (`values.yaml`) distincts pour gérer les configurations spécifiques à chaque environnement, comme le développement et la production.

## Contexte

Une application n'est pas déployée de la même manière en développement, en pré-production et en production. Les ressources (CPU/mémoire), le nombre de réplicas, les noms d'hôtes et d'autres paramètres varient. Helm facilite la gestion de ces différences grâce à la possibilité de fournir des fichiers de valeurs spécifiques lors de l'installation ou de la mise à jour.

Le chart `fullstack-ocp` contient déjà des fichiers `values-dev.yaml` et `values-prod.yaml` à cet effet.

## Étapes

### 1. Préparer les projets

Créez des namespaces distincts pour simuler les environnements de développement et de production :

```bash
oc new-project fullstack-dev
oc new-project fullstack-prod
```

### 2. Examiner les fichiers de valeurs

Ouvrez et comparez les fichiers `charts/fullstack-ocp/values-dev.yaml` et `charts/fullstack-ocp/values-prod.yaml`. Vous devriez noter des différences sur :

*   `replicaCount` (plus élevé en production).
*   `resources` (limites CPU/mémoire plus hautes en production).
*   La configuration du HPA (Horizontal Pod Autoscaler), activé uniquement en production.

### 3. Déployer en environnement de développement

Installez le chart dans le namespace `fullstack-dev` en utilisant le fichier `values-dev.yaml` avec l'option `-f` ou `--values`.

```bash
helm install fullstack-dev-release charts/fullstack-ocp -f charts/fullstack-ocp/values-dev.yaml --namespace fullstack-dev
```

### 4. Déployer en environnement de production

Faites de même pour l'environnement de production :

```bash
helm install fullstack-prod-release charts/fullstack-ocp -f charts/fullstack-ocp/values-prod.yaml --namespace fullstack-prod
```

## Vérifications

*   **En environnement de développement** :

    Vérifiez le nombre de réplicas du frontend. Il devrait correspondre à la valeur dans `values-dev.yaml`.

    ```bash
    oc get deployment -n fullstack-dev
    ```

*   **En environnement de production** :

    Vérifiez que le nombre de réplicas est plus élevé et qu'un objet `HorizontalPodAutoscaler` a été créé.

    ```bash
    oc get deployment,hpa -n fullstack-prod
    ```

## Nettoyage

```bash
helm uninstall fullstack-dev-release -n fullstack-dev
helm uninstall fullstack-prod-release -n fullstack-prod
oc delete project fullstack-dev fullstack-prod
```
