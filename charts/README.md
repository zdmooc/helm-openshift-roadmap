_Titre: Charts Helm pour OpenShift_

## Vue d'ensemble

Ce répertoire contient les charts Helm utilisés dans la roadmap d'apprentissage Helm pour OpenShift. Chaque chart est conçu pour illustrer des concepts spécifiques et être déployable sur un cluster OpenShift.

## Charts disponibles

### 1. `myapp-ocp` - Application simple

**Niveau** : Débutant à Intermédiaire

**Description** : Un chart simple pour une application web NGINX avec les concepts de base de Helm.

**Contient** :
*   Deployment avec gestion des ressources
*   Service ClusterIP
*   Route OpenShift
*   ConfigMap
*   Validation JSON Schema des valeurs
*   Security Context pour OpenShift

**Cas d'usage** : Apprendre les bases de Helm, les templates, les valeurs et les spécificités OpenShift.

**Déploiement rapide** :

```bash
helm install myapp ./myapp-ocp --namespace myapp-demo --create-namespace
```

**Documentation** : Voir [Lab 20](../labs/level-2-template-dev/lab20-creer-chart-myapp-ocp.md) et [Lab 21](../labs/level-2-template-dev/lab21-route-et-securitycontext.md)

---

### 2. `fullstack-ocp` - Application full-stack

**Niveau** : Intermédiaire à Avancé

**Description** : Un chart complet pour une application multi-composants (frontend, backend, base de données) avec configurations multi-environnements.

**Contient** :
*   Frontend (NGINX) avec Deployment, Service et Route
*   Backend (Python) avec Deployment et Service
*   Database (PostgreSQL) via StatefulSet ou dépendance Bitnami
*   Fichiers de valeurs distincts pour dev et prod
*   HPA (Horizontal Pod Autoscaler) pour la production
*   NetworkPolicy pour la sécurité réseau
*   PodDisruptionBudget pour la résilience

**Cas d'usage** : Apprendre à gérer des applications complexes, les dépendances, les multi-environnements et les concepts avancés de Helm.

**Déploiement en développement** :

```bash
helm install fullstack-dev ./fullstack-ocp \
  -f ./fullstack-ocp/values-dev.yaml \
  --namespace fullstack-dev \
  --create-namespace
```

**Déploiement en production** :

```bash
helm install fullstack-prod ./fullstack-ocp \
  -f ./fullstack-ocp/values-prod.yaml \
  --namespace fullstack-prod \
  --create-namespace
```

**Documentation** : Voir [Lab 30](../labs/level-3-packaging-dependencies/lab30-chart-fullstack-app-db.md) et [Lab 31](../labs/level-3-packaging-dependencies/lab31-values-dev-vs-prod.md)

---

## Commandes courantes

### Linter un chart

```bash
helm lint ./myapp-ocp
helm lint ./fullstack-ocp
```

### Valider les templates

```bash
helm template myapp ./myapp-ocp
helm template fullstack ./fullstack-ocp -f ./fullstack-ocp/values-dev.yaml
```

### Installer un chart

```bash
helm install <release-name> <chart-path> --namespace <namespace> --create-namespace
```

### Mettre à jour une release

```bash
helm upgrade <release-name> <chart-path> -f <values-file>
```

### Voir l'historique des releases

```bash
helm history <release-name> --namespace <namespace>
```

### Revenir à une version précédente

```bash
helm rollback <release-name> <revision> --namespace <namespace>
```

### Supprimer une release

```bash
helm uninstall <release-name> --namespace <namespace>
```

## Structure d'un chart

Chaque chart suit la structure standard de Helm :

```
chart-name/
├── Chart.yaml              # Métadonnées du chart
├── values.yaml             # Valeurs par défaut
├── values-dev.yaml         # Valeurs pour développement
├── values-prod.yaml        # Valeurs pour production
├── values.schema.json      # Schéma de validation
├── README.md               # Documentation du chart
├── templates/
│   ├── _helpers.tpl        # Fonctions de template réutilisables
│   ├── deployment.yaml     # Deployment Kubernetes
│   ├── service.yaml        # Service Kubernetes
│   ├── route.yaml          # Route OpenShift
│   ├── configmap.yaml      # ConfigMap
│   ├── hpa.yaml            # Horizontal Pod Autoscaler
│   ├── networkpolicy.yaml  # NetworkPolicy
│   └── pdb.yaml            # PodDisruptionBudget
└── charts/                 # Dépendances (subcharts)
```

## Bonnes pratiques

1. **Validez toujours vos charts** avant de les déployer :

   ```bash
   helm lint <chart-path>
   helm template <release> <chart-path> | oc apply --dry-run=client -f -
   ```

2. **Utilisez des fichiers de valeurs distincts** pour chaque environnement (dev, prod).

3. **Documentez vos charts** avec un README clair et des commentaires dans les templates.

4. **Versionnez vos charts** correctement dans `Chart.yaml`.

5. **Testez vos charts** avant de les publier ou de les utiliser en production.

6. **Utilisez des namespaces** pour isoler les déploiements.

## Intégration avec GitOps

Ces charts sont utilisés dans les manifestes Argo CD disponibles dans le dossier `gitops/`. Consultez [gitops/README-gitops-exemples.md](../gitops/examples/README-gitops-exemples.md) pour plus d'informations.

## Support

Pour toute question ou problème, consultez :
*   La [documentation principale](../README.md)
*   Les [laboratoires pratiques](../labs/)
*   La [roadmap d'apprentissage](../docs/roadmap-helm-openshift.md)
