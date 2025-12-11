# Roadmap Helm pour OpenShift

Ce dépôt est un support complet pour apprendre et maîtriser **Helm 3 sur OpenShift 4.x**, du niveau débutant à expert. Il fournit une feuille de route structurée, des laboratoires pratiques, des exemples de charts "OpenShift-ready" et des manifestes GitOps avec Argo CD.

## Objectif

L'objectif de ce projet est de fournir un parcours d'apprentissage clé en main pour les développeurs, administrateurs et ingénieurs DevOps souhaitant utiliser Helm de manière efficace dans un environnement OpenShift. Les thèmes abordés incluent :

*   Les bases de Helm (création, déploiement, gestion de releases).
*   L'adaptation de charts pour OpenShift (Routes, Security Context Constraints).
*   La gestion de configurations multi-environnements (développement, production).
*   Les concepts avancés de Helm (hooks, tests, dépendances).
*   L'intégration avec GitOps via Argo CD pour l'automatisation des déploiements.

## Relation avec `helm-masterclass`

Ce dépôt est un complément spécialisé pour OpenShift du fork [zdmooc/helm-masterclass](https://github.com/zdmooc/helm-masterclass). 

*   **`helm-masterclass`** couvre les fondamentaux de Helm de manière générique, indépendamment de la plateforme Kubernetes.
*   **`helm-openshift-roadmap`** (ce dépôt) se concentre sur les spécificités et les bonnes pratiques d'utilisation de Helm dans un écosystème OpenShift, en ajoutant des concepts comme les **Routes**, les **SCC (Security Context Constraints)** et l'intégration **GitOps**.

Il est recommandé de suivre les concepts de base dans `helm-masterclass` avant de plonger dans les aspects plus avancés et spécifiques à OpenShift présentés ici.

## Plan de lecture

Pour tirer le meilleur parti de ce dépôt, nous vous suggérons de suivre les étapes suivantes :

1.  **Prérequis** : Assurez-vous d'avoir l'environnement nécessaire en lisant le document [docs/prerequis.md](./docs/prerequis.md).
2.  **Roadmap** : Suivez la feuille de route progressive dans [docs/roadmap-helm-openshift.md](./docs/roadmap-helm-openshift.md) pour monter en compétence.
3.  **Laboratoires** : Mettez en pratique les concepts avec les laboratoires pas-à-pas disponibles dans le dossier [labs/](./labs/).
4.  **Charts** : Explorez et déployez les exemples de charts Helm optimisés pour OpenShift disponibles dans le dossier [charts/](./charts/).
5.  **GitOps** : Automatisez vos déploiements en utilisant les manifestes Argo CD fournis dans le dossier [gitops/](./gitops/).

## Prérequis techniques

Avant de commencer, vous devez disposer des éléments suivants :

*   Un **cluster OpenShift** (version 4.x). [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) (anciennement CRC) est une excellente option pour un environnement de développement local.
*   L'outil en ligne de commande `oc` [installé et configuré](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html) pour accéder à votre cluster.
*   **Helm 3** [installé](https://helm.sh/docs/intro/install/) sur votre machine locale.
*   Un accès à un projet OpenShift avec des droits de développeur ou d'administrateur.

---

*Ce dépôt a été généré par Manus, un agent IA autonome.*
