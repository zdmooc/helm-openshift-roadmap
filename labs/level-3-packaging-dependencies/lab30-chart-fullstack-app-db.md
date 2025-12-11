_Titre: Lab 30: Chart Full-Stack (App+DB) avec Dépendances_ 

## Objectif

Gérer une application multi-composants (frontend, backend, base de données) en utilisant les dépendances de charts (subcharts). Apprendre à activer ou désactiver des composants via les `values`.

## Contexte

Les applications réelles sont rarement monolithiques. Elles se composent souvent de plusieurs services qui doivent être déployés et gérés ensemble. Helm permet de gérer cette complexité en utilisant des **dépendances** (ou **subcharts**). Un chart parent peut ainsi déclarer des dépendances vers d'autres charts (par exemple, un chart pour le frontend et un autre pour la base de données).

Nous allons utiliser le chart `fullstack-ocp` qui est déjà structuré pour cet exercice.

## Étapes

### 1. Préparer le projet

```bash
oc new-project fullstack-dev
```

### 2. Explorer le chart `fullstack-ocp`

Regardez la structure du chart dans `charts/fullstack-ocp`. Le `Chart.yaml` devrait contenir une section `dependencies` qui liste les charts enfants (par exemple, un chart PostgreSQL).

Le `values.yaml` permet d'activer/désactiver ces dépendances :

```yaml
# charts/fullstack-ocp/values.yaml

frontend:
  enabled: true
  # ...

backend:
  enabled: true
  # ...

database:
  enabled: true
  # ...
```

Les templates dans `charts/fullstack-ocp/templates/` utilisent des conditions `if` pour ne générer les ressources que si le composant correspondant est activé.

### 3. Mettre à jour les dépendances

Avant d'installer un chart avec des dépendances, vous devez les télécharger localement dans le dossier `charts/` du chart parent.

```bash
cd charts/fullstack-ocp
helm dependency update
cd ../..
```

### 4. Déployer l'application complète

Installez le chart avec tous les composants activés par défaut :

```bash
helm install fullstack charts/fullstack-ocp --namespace fullstack-dev
```

### 5. Déployer sans la base de données

Supposons que nous souhaitions utiliser une base de données externe. Nous pouvons désactiver la dépendance de la base de données lors de l'installation :

```bash
helm install fullstack-nodb charts/fullstack-ocp --namespace fullstack-dev \
  --set database.enabled=false
```

## Vérifications

*   **Après le déploiement complet** :

    Listez tous les objets dans le namespace. Vous devriez voir les Deployments pour le frontend et le backend, ainsi qu'un StatefulSet pour la base de données.

    ```bash
    oc get all,statefulset --namespace fullstack-dev
    ```

*   **Après le déploiement sans DB** :

    Vérifiez que le StatefulSet de la base de données n'a pas été créé pour la release `fullstack-nodb`.

## Nettoyage

```bash
helm uninstall fullstack --namespace fullstack-dev
helm uninstall fullstack-nodb --namespace fullstack-dev
oc delete project fullstack-dev
```
