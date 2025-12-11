# Roadmap d'Apprentissage Helm sur OpenShift

Cette roadmap est conçue pour vous guider dans l'apprentissage de Helm sur OpenShift, en partant des bases jusqu'à des concepts experts liés à GitOps et aux Operators.

## Niveau 0 – Préparation

*   **Objectifs pédagogiques** : Mettre en place un environnement de travail fonctionnel et comprendre les concepts fondamentaux d'OpenShift.
*   **Labs correspondants** : [lab00-installation-environnement.md](../labs/level-0-preparation/lab00-installation-environnement.md)
*   **Lien avec `helm-masterclass`** : Ce niveau correspond à la préparation initiale (démos 00 et 01).
*   **Résultat attendu** : Vous disposez d'un cluster OpenShift local (CRC), des outils `oc` et `helm` installés, et vous êtes familier avec les concepts de base de Kubernetes et OpenShift.

## Niveau 1 – Helm User (Commandes de base)

*   **Objectifs pédagogiques** : Déployer, gérer et supprimer des applications packagées avec Helm sur OpenShift.
*   **Labs correspondants** : 
    *   [lab10-deployer-nginx-sur-openshift.md](../labs/level-1-helm-user/lab10-deployer-nginx-sur-openshift.md)
    *   [lab11-upgrade-rollback-release.md](../labs/level-1-helm-user/lab11-upgrade-rollback-release.md)
*   **Lien avec `helm-masterclass`** : Ce niveau couvre les démos 02 à 10 de `helm-masterclass`, en les appliquant à un contexte OpenShift.
*   **Résultat attendu** : Vous êtes capable de gérer le cycle de vie d'une application Helm (release) dans un projet OpenShift.

## Niveau 2 – Template Dev (Développement de templates)

*   **Objectifs pédagogiques** : Créer et personnaliser des charts Helm en utilisant le langage de templating Go, les variables et les helpers.
*   **Labs correspondants** : 
    *   [lab20-creer-chart-myapp-ocp.md](../labs/level-2-template-dev/lab20-creer-chart-myapp-ocp.md)
    *   [lab21-route-et-securitycontext.md](../labs/level-2-template-dev/lab21-route-et-securitycontext.md)
*   **Lien avec `helm-masterclass`** : Correspond aux démos 11 à 20, en ajoutant la création de ressources spécifiques à OpenShift comme les `Routes`.
*   **Résultat attendu** : Vous pouvez développer un chart Helm simple pour une application, en incluant des spécificités OpenShift.

## Niveau 3 – Packaging & Dépendances

*   **Objectifs pédagogiques** : Gérer des applications multi-services avec des dépendances (subcharts) et configurer des environnements multiples (développement, production).
*   **Labs correspondants** : 
    *   [lab30-chart-fullstack-app-db.md](../labs/level-3-packaging-dependencies/lab30-chart-fullstack-app-db.md)
    *   [lab31-values-dev-vs-prod.md](../labs/level-3-packaging-dependencies/lab31-values-dev-vs-prod.md)
*   **Lien avec `helm-masterclass`** : Similaire aux démos 21 à 25, mais avec une application plus complexe et des fichiers de valeurs par environnement.
*   **Résultat attendu** : Vous savez structurer un chart pour une application complexe et gérer ses configurations pour différents environnements.

## Niveau 4 – Features Avancées

*   **Objectifs pédagogiques** : Utiliser les fonctionnalités avancées de Helm comme les hooks, les tests, la validation de valeurs avec JSON Schema, et la gestion de dépôts de charts.
*   **Labs correspondants** : 
    *   [lab40-hooks-tests-jsonschema.md](../labs/level-4-features-avancees/lab40-hooks-tests-jsonschema.md)
    *   [lab41-repo-helm-github-et-artifacthub.md](../labs/level-4-features-avancees/lab41-repo-helm-github-et-artifacthub.md)
*   **Lien avec `helm-masterclass`** : Correspond aux démos 26 à 30.
*   **Résultat attendu** : Vous maîtrisez les fonctionnalités avancées de Helm pour créer des charts robustes et professionnels.

## Niveau 5 – OpenShift & GitOps Expert

*   **Objectifs pédagogiques** : Intégrer Helm dans un workflow GitOps avec Argo CD et comprendre les bases de la création d'Operators basés sur Helm.
*   **Labs correspondants** : 
    *   [lab50-argo-cd-helm-multi-environnements.md](../labs/level-5-openshift-gitops-expert/lab50-argo-cd-helm-multi-environnements.md)
    *   [lab51-operator-helm-based-intro.md](../labs/level-5-openshift-gitops-expert/lab51-operator-helm-based-intro.md)
*   **Lien avec `helm-masterclass`** : Ce niveau est une extension spécifique à OpenShift qui n'est pas couverte dans `helm-masterclass`.
*   **Résultat attendu** : Vous êtes capable d'automatiser le déploiement d'applications Helm sur OpenShift en utilisant une approche GitOps et de commencer à packager vos applications en tant qu'Operators.
