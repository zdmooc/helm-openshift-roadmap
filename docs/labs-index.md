Titre: Index des Laboratoires

Ce tableau répertorie tous les laboratoires pratiques disponibles dans ce dépôt. Il est recommandé de les suivre dans l'ordre pour une expérience d'apprentissage progressive.

| Niveau | Laboratoire | Objectif | Durée Estimée | Pré-requis |
| :--- | :--- | :--- | :--- | :--- |
| 0 | [Installation de l'environnement](../labs/level-0-preparation/lab00-installation-environnement.md) | Mettre en place OpenShift Local (CRC) et les outils CLI. | 30 min | Aucun |
| 1 | [Déployer NGINX sur OpenShift](../labs/level-1-helm-user/lab10-deployer-nginx-sur-openshift.md) | Déployer un premier chart Helm depuis un dépôt public. | 15 min | Lab 0 |
| 1 | [Upgrade & Rollback](../labs/level-1-helm-user/lab11-upgrade-rollback-release.md) | Mettre à jour et revenir à une version précédente d'une release. | 20 min | Lab 10 |
| 2 | [Créer un chart `myapp-ocp`](../labs/level-2-template-dev/lab20-creer-chart-myapp-ocp.md) | Créer un chart Helm simple pour une application web. | 30 min | Lab 11 |
| 2 | [Route et Contexte de Sécurité](../labs/level-2-template-dev/lab21-route-et-securitycontext.md) | Ajouter une Route OpenShift et configurer le contexte de sécurité. | 25 min | Lab 20 |
| 3 | [Chart Full-Stack (App+DB)](../labs/level-3-packaging-dependencies/lab30-chart-fullstack-app-db.md) | Gérer une application multi-composants avec des dépendances. | 45 min | Lab 21 |
| 3 | [Values pour Dev vs. Prod](../labs/level-3-packaging-dependencies/lab31-values-dev-vs-prod.md) | Utiliser des fichiers `values.yaml` distincts par environnement. | 30 min | Lab 30 |
| 4 | [Hooks, Tests et JSON Schema](../labs/level-4-features-avancees/lab40-hooks-tests-jsonschema.md) | Utiliser les hooks, les tests et la validation de valeurs. | 40 min | Lab 31 |
| 4 | [Dépôt Helm sur GitHub](../labs/level-4-features-avancees/lab41-repo-helm-github-et-artifacthub.md) | Publier un chart sur un dépôt Helm hébergé sur GitHub Pages. | 35 min | Lab 40 |
| 5 | [Argo CD et Multi-environnements](../labs/level-5-openshift-gitops-expert/lab50-argo-cd-helm-multi-environnements.md) | Déployer des charts Helm via une approche GitOps avec Argo CD. | 50 min | Lab 31 |
| 5 | [Introduction aux Operators Helm-based](../labs/level-5-openshift-gitops-expert/lab51-operator-helm-based-intro.md) | Comprendre comment packager un chart en tant qu'Operator simple. | 45 min | Lab 20 |
