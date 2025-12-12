_Titre: Laboratoires Pratiques Helm sur OpenShift_

## Vue d'ensemble

Ce répertoire contient 11 laboratoires pratiques progressifs pour apprendre Helm sur OpenShift, du niveau débutant à expert. Chaque lab est conçu pour être suivi dans l'ordre et pour renforcer les concepts présentés dans la roadmap.

## Structure des laboratoires

Les laboratoires sont organisés en 6 niveaux de compétence :

```
labs/
├── level-0-preparation/          # Préparation de l'environnement
│   └── lab00-installation-environnement.md
├── level-1-helm-user/            # Utilisation de Helm (commandes de base)
│   ├── lab10-deployer-nginx-sur-openshift.md
│   └── lab11-upgrade-rollback-release.md
├── level-2-template-dev/         # Développement de templates Helm
│   ├── lab20-creer-chart-myapp-ocp.md
│   └── lab21-route-et-securitycontext.md
├── level-3-packaging-dependencies/ # Packaging et dépendances
│   ├── lab30-chart-fullstack-app-db.md
│   └── lab31-values-dev-vs-prod.md
├── level-4-features-avancees/    # Fonctionnalités avancées
│   ├── lab40-hooks-tests-jsonschema.md
│   └── lab41-repo-helm-github-et-artifacthub.md
├── level-5-openshift-gitops-expert/ # GitOps et Operators
│   ├── lab50-argo-cd-helm-multi-environnements.md
│   └── lab51-operator-helm-based-intro.md
└── solutions/                    # Solutions des laboratoires
    └── (fichiers de solutions)
```

## Guide de progression

| Niveau | Labs | Objectif | Durée | Prérequis |
|--------|------|----------|-------|-----------|
| **0** | Lab 00 | Installer OpenShift Local et les outils | 30 min | Aucun |
| **1** | Labs 10-11 | Déployer et gérer des applications Helm | 35 min | Lab 00 |
| **2** | Labs 20-21 | Créer des charts Helm simples | 55 min | Lab 11 |
| **3** | Labs 30-31 | Gérer des applications complexes | 75 min | Lab 21 |
| **4** | Labs 40-41 | Utiliser les fonctionnalités avancées | 75 min | Lab 31 |
| **5** | Labs 50-51 | Déployer avec GitOps et Operators | 95 min | Lab 41 |

**Durée totale estimée** : ~5 heures

## Format de chaque laboratoire

Chaque laboratoire suit une structure cohérente :

### 1. **Objectif**
Description claire de ce que vous allez apprendre.

### 2. **Contexte**
Explication du contexte et de la relation avec les concepts précédents.

### 3. **Étapes**
Instructions détaillées pas-à-pas à exécuter.

### 4. **Vérifications**
Commandes pour vérifier que tout fonctionne correctement.

### 5. **Nettoyage**
Commandes pour nettoyer les ressources créées.

## Lien avec les Charts

Chaque laboratoire utilise les charts disponibles dans le dossier `charts/` :

| Lab | Chart utilisé | Concepts illustrés |
|-----|---------------|--------------------|
| Lab 10 | Bitnami NGINX | Déploiement d'un chart existant |
| Lab 11 | Bitnami NGINX | Upgrade et rollback |
| Lab 20 | myapp-ocp | Création d'un chart simple |
| Lab 21 | myapp-ocp | Route et Security Context |
| Lab 30 | fullstack-ocp | Dépendances et multi-composants |
| Lab 31 | fullstack-ocp | Fichiers de valeurs par environnement |
| Lab 40 | myapp-ocp | Hooks, tests, JSON Schema |
| Lab 41 | myapp-ocp | Dépôt Helm et publication |
| Lab 50 | fullstack-ocp | Argo CD et GitOps |
| Lab 51 | myapp-ocp | Operators basés sur Helm |

## Commandes utiles

### Avant de commencer

```bash
# Vérifier la connexion au cluster
oc status

# Vérifier la version de Helm
helm version

# Vérifier la version d'OpenShift
oc version
```

### Pendant les labs

```bash
# Créer un namespace
oc new-project <nom-du-projet>

# Lister les releases Helm
helm list --namespace <namespace>

# Voir les détails d'une release
helm get values <release> --namespace <namespace>

# Voir les manifests générés
helm template <release> <chart>

# Valider un chart
helm lint <chart-path>

# Voir les Pods
oc get pods --namespace <namespace>

# Voir les logs
oc logs <pod-name> --namespace <namespace>

# Accéder à une Route
oc get route <route-name> --namespace <namespace> -o jsonpath='{.spec.host}'
```

### Après chaque lab

```bash
# Supprimer une release
helm uninstall <release> --namespace <namespace>

# Supprimer un namespace
oc delete namespace <namespace>
```

## Solutions des laboratoires

Les solutions des laboratoires sont disponibles dans le dossier `solutions/`. Consultez-les si vous êtes bloqué, mais essayez d'abord de résoudre le lab par vous-même !

**Attention** : Les solutions sont des suggestions. Il peut y avoir plusieurs façons correctes de résoudre un problème.

## Bonnes pratiques

1. **Suivez les labs dans l'ordre** : Chaque lab s'appuie sur les concepts précédents

2. **Lisez le contexte** : Comprendre le "pourquoi" avant le "comment"

3. **Exécutez les commandes** : Ne les copiez pas simplement, comprenez ce qu'elles font

4. **Vérifiez à chaque étape** : Utilisez les commandes de vérification pour confirmer

5. **Nettoyez après chaque lab** : Libérez les ressources pour les labs suivants

6. **Posez des questions** : Si vous ne comprenez pas quelque chose, consultez la documentation ou les ressources

## Dépannage

### Erreur : "Cluster not accessible"

```bash
# Vérifiez la connexion
oc login -u kubeadmin -p <password> https://api.crc.testing:6443
```

### Erreur : "Chart not found"

```bash
# Ajoutez le dépôt Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Erreur : "Pod not starting"

```bash
# Vérifiez les logs
oc describe pod <pod-name> --namespace <namespace>
oc logs <pod-name> --namespace <namespace>
```

### Erreur : "Permission denied"

```bash
# Vérifiez vos droits dans le namespace
oc auth can-i create deployments --namespace <namespace>
```

## Ressources supplémentaires

*   [Documentation Helm officielle](https://helm.sh/docs/)
*   [Documentation OpenShift](https://docs.openshift.com/)
*   [Kubernetes Documentation](https://kubernetes.io/docs/)
*   [Argo CD Documentation](https://argo-cd.readthedocs.io/)

## Support

Pour toute question ou problème :
1. Consultez la [documentation principale](../README.md)
2. Vérifiez la [roadmap d'apprentissage](../docs/roadmap-helm-openshift.md)
3. Consultez les [exemples GitOps](../gitops/examples/README-gitops-exemples.md)
4. Consultez les [charts disponibles](../charts/README.md)

## Feedback

Si vous avez des suggestions pour améliorer les labs, n'hésitez pas à ouvrir une issue ou une pull request sur le dépôt GitHub !
