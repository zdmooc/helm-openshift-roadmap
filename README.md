# Roadmap Helm pour OpenShift

Ce dépôt est un support complet pour apprendre et maîtriser **Helm 3 sur OpenShift 4.x**, du niveau débutant à expert. Il fournit une feuille de route structurée, des laboratoires pratiques, des exemples de charts "OpenShift-ready" et des manifestes GitOps avec Argo CD.

## 🎯 Objectif

L'objectif de ce projet est de fournir un parcours d'apprentissage clé en main pour les développeurs, administrateurs et ingénieurs DevOps souhaitant utiliser Helm de manière efficace dans un environnement OpenShift. Les thèmes abordés incluent :

*   Les bases de Helm (création, déploiement, gestion de releases)
*   L'adaptation de charts pour OpenShift (Routes, Security Context Constraints)
*   La gestion de configurations multi-environnements (développement, production)
*   Les concepts avancés de Helm (hooks, tests, dépendances)
*   L'intégration avec GitOps via Argo CD pour l'automatisation des déploiements
*   La création d'Operators basés sur Helm

## 📚 Relation avec `helm-masterclass`

Ce dépôt est un complément spécialisé pour OpenShift du fork [zdmooc/helm-masterclass](https://github.com/zdmooc/helm-masterclass).

*   **`helm-masterclass`** couvre les fondamentaux de Helm de manière générique, indépendamment de la plateforme Kubernetes.
*   **`helm-openshift-roadmap`** (ce dépôt) se concentre sur les spécificités et les bonnes pratiques d'utilisation de Helm dans un écosystème OpenShift, en ajoutant des concepts comme les **Routes**, les **SCC (Security Context Constraints)** et l'intégration **GitOps**.

Il est recommandé de suivre les concepts de base dans `helm-masterclass` avant de plonger dans les aspects plus avancés et spécifiques à OpenShift présentés ici.

## 🚀 Plan de lecture rapide

Pour tirer le meilleur parti de ce dépôt, nous vous suggérons de suivre les étapes suivantes :

1. **Prérequis** : Assurez-vous d'avoir l'environnement nécessaire en lisant le document [docs/prerequis.md](./docs/prerequis.md).
2. **Roadmap** : Suivez la feuille de route progressive dans [docs/roadmap-helm-openshift.md](./docs/roadmap-helm-openshift.md) pour monter en compétence.
3. **Laboratoires** : Mettez en pratique les concepts avec les laboratoires pas-à-pas disponibles dans le dossier [labs/](./labs/). Commencez par [labs/README.md](./labs/README.md) pour une vue d'ensemble.
4. **Charts** : Explorez et déployez les exemples de charts Helm optimisés pour OpenShift disponibles dans le dossier [charts/](./charts/). Consultez [charts/README.md](./charts/README.md) pour les détails.
5. **GitOps** : Automatisez vos déploiements en utilisant les manifestes Argo CD fournis dans le dossier [gitops/](./gitops/). Consultez [gitops/README.md](./gitops/README.md) pour les instructions.

## 📋 Prérequis techniques

Avant de commencer, vous devez disposer des éléments suivants :

*   Un **cluster OpenShift** (version 4.x). [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview) (anciennement CRC) est une excellente option pour un environnement de développement local.
*   L'outil en ligne de commande `oc` [installé et configuré](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html) pour accéder à votre cluster.
*   **Helm 3** [installé](https://helm.sh/docs/intro/install/) sur votre machine locale.
*   Un accès à un projet OpenShift avec des droits de développeur ou d'administrateur.

## 📁 Structure du dépôt

```
helm-openshift-roadmap/
├── README.md                           # Ce fichier
├── LICENSE                             # Licence MIT
├── .gitignore                          # Fichiers à ignorer
├── docs/                               # Documentation
│   ├── roadmap-helm-openshift.md       # Feuille de route d'apprentissage
│   ├── labs-index.md                   # Index des laboratoires
│   └── prerequis.md                    # Prérequis techniques
├── labs/                               # Laboratoires pratiques (11 labs)
│   ├── README.md                       # Guide des laboratoires
│   ├── level-0-preparation/            # Niveau 0: Préparation
│   ├── level-1-helm-user/              # Niveau 1: Utilisation de Helm
│   ├── level-2-template-dev/           # Niveau 2: Développement de templates
│   ├── level-3-packaging-dependencies/ # Niveau 3: Packaging et dépendances
│   ├── level-4-features-avancees/      # Niveau 4: Fonctionnalités avancées
│   └── level-5-openshift-gitops-expert/ # Niveau 5: GitOps et Operators
├── charts/                             # Charts Helm
│   ├── README.md                       # Guide des charts
│   ├── myapp-ocp/                      # Chart simple (application web)
│   └── fullstack-ocp/                  # Chart full-stack (frontend+backend+DB)
└── gitops/                             # GitOps et Argo CD
    ├── README.md                       # Guide GitOps
    ├── argocd-apps/                    # Applications Argo CD
    └── examples/                       # Exemples et bonnes pratiques
```

## 🎓 Contenu des laboratoires

Le dépôt contient **11 laboratoires pratiques** organisés en 6 niveaux :

| Niveau | Laboratoires | Objectif | Durée |
|--------|--------------|----------|-------|
| **0** | Lab 00 | Installation de l'environnement | 30 min |
| **1** | Labs 10-11 | Déploiement et gestion de releases Helm | 35 min |
| **2** | Labs 20-21 | Création de charts simples et spécificités OpenShift | 55 min |
| **3** | Labs 30-31 | Applications multi-services et multi-environnements | 75 min |
| **4** | Labs 40-41 | Hooks, tests, JSON Schema et dépôts Helm | 75 min |
| **5** | Labs 50-51 | GitOps avec Argo CD et Operators | 95 min |

**Durée totale estimée** : ~5 heures

## 📦 Charts Helm fournis

### 1. `myapp-ocp` - Application simple
Un chart pour une application web NGINX avec les concepts de base de Helm et les spécificités OpenShift.

**Déploiement rapide** :
```bash
helm install myapp ./charts/myapp-ocp --namespace myapp-demo --create-namespace
```

### 2. `fullstack-ocp` - Application full-stack
Un chart complet pour une application multi-composants (frontend, backend, PostgreSQL) avec configurations multi-environnements.

**Déploiement en développement** :
```bash
helm install fullstack-dev ./charts/fullstack-ocp -f ./charts/fullstack-ocp/values-dev.yaml --namespace fullstack-dev --create-namespace
```

**Déploiement en production** :
```bash
helm install fullstack-prod ./charts/fullstack-ocp -f ./charts/fullstack-ocp/values-prod.yaml --namespace fullstack-prod --create-namespace
```

## 🔄 GitOps avec Argo CD

Ce dépôt inclut des manifestes Argo CD pour déployer les applications en utilisant une approche GitOps.

**Installation rapide** :
```bash
# Installer l'Operator OpenShift GitOps (via la console web)
# Puis appliquer les manifestes :
oc apply -f gitops/argocd-apps/application-helm-roadmap.yaml -n openshift-gitops
```

Consultez [gitops/README.md](./gitops/README.md) pour les détails.

## 👤 Auteur & Mainteneur

**Zidane Djamal** - Architecte Technique & Ingénieur DevOps OpenShift
- GitHub: [@zdmooc](https://github.com/zdmooc)
- Email: zidane@zdmooc.dev

Ce dépôt a été généré et amélioré par **Manus AI** en collaboration avec Zidane Djamal.

## 📄 Licence

Ce projet est sous licence **MIT**. Consultez le fichier [LICENSE](./LICENSE) pour plus de détails.

## 🤝 Contribution

Les contributions sont bienvenues ! Si vous avez des suggestions pour améliorer ce dépôt :

1. Ouvrez une issue pour discuter des changements proposés
2. Créez une pull request avec vos améliorations
3. Assurez-vous que vos changements suivent les bonnes pratiques Helm et OpenShift

## 📞 Support

Pour toute question ou problème :

1. Consultez la [documentation principale](./README.md)
2. Vérifiez la [roadmap d'apprentissage](./docs/roadmap-helm-openshift.md)
3. Consultez les [laboratoires](./labs/README.md)
4. Consultez les [charts disponibles](./charts/README.md)
5. Consultez le [guide GitOps](./gitops/README.md)

## 🔗 Ressources utiles

*   [Documentation Helm officielle](https://helm.sh/docs/)
*   [Documentation OpenShift](https://docs.openshift.com/)
*   [Kubernetes Documentation](https://kubernetes.io/docs/)
*   [Argo CD Documentation](https://argo-cd.readthedocs.io/)
*   [OpenShift GitOps](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)

---

**Commencez par le [Lab 00](./labs/level-0-preparation/lab00-installation-environnement.md) pour configurer votre environnement !** 🚀
