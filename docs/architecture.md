_Titre: Architecture Helm-OpenShift-GitOps_

## Vue d'ensemble générale

Ce document décrit l'architecture globale du dépôt `helm-openshift-roadmap` et comment les différents composants interagissent.

## Architecture en couches

```
┌─────────────────────────────────────────────────────────────────┐
│                     COUCHE PRÉSENTATION                          │
│  Frontend (NGINX) - Routes OpenShift - Accès utilisateur        │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                     COUCHE APPLICATION                           │
│  Backend (Python) - API - Logique métier                        │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                     COUCHE DONNÉES                               │
│  PostgreSQL - Persistence - Transactions                        │
└─────────────────────────────────────────────────────────────────┘
```

## Architecture du dépôt

```
GitHub Repository (helm-openshift-roadmap)
│
├── charts/
│   ├── myapp-ocp/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── route.yaml
│   │       └── configmap.yaml
│   │
│   └── fullstack-ocp/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
│           ├── frontend-deployment.yaml
│           ├── backend-deployment.yaml
│           ├── db-statefulset.yaml
│           ├── services.yaml
│           ├── route-frontend.yaml
│           ├── hpa.yaml
│           ├── networkpolicy.yaml
│           └── pdb.yaml
│
├── gitops/
│   ├── argocd-apps/
│   │   ├── application-myapp-dev.yaml
│   │   ├── application-myapp-prod.yaml
│   │   ├── application-fullstack-dev.yaml
│   │   ├── application-fullstack-prod.yaml
│   │   └── application-helm-roadmap.yaml (App-of-Apps)
│   │
│   └── examples/
│       └── README-gitops-exemples.md
│
├── labs/
│   ├── level-0-preparation/
│   ├── level-1-helm-user/
│   ├── level-2-template-dev/
│   ├── level-3-packaging-dependencies/
│   ├── level-4-features-avancees/
│   └── level-5-openshift-gitops-expert/
│
└── docs/
    ├── roadmap-helm-openshift.md
    ├── labs-index.md
    ├── prerequis.md
    ├── ci-cd-example.md
    └── architecture.md
```

## Flux de déploiement GitOps

```
1. Developer commits code
        ↓
2. GitHub Actions (CI Pipeline)
   - Build Docker image
   - Push to registry
   - Lint Helm chart
   - Run tests
        ↓
3. Commit to main branch
        ↓
4. Argo CD detects change
        ↓
5. Argo CD syncs Application
        ↓
6. Helm deploys to OpenShift
        ↓
7. Application running in cluster
```

## Interaction des composants

### Helm

**Rôle** : Package manager pour Kubernetes/OpenShift

```
Chart (code) + Values (config) → Helm Template Engine → Kubernetes Manifests
```

**Utilisé pour** :
*   Packaging des applications
*   Gestion des configurations
*   Déploiement et mise à jour
*   Rollback

### OpenShift

**Rôle** : Plateforme Kubernetes avec extensions

```
Kubernetes Resources + OpenShift Extensions
  - Deployments, Services, StatefulSets
  - Routes (au lieu d'Ingress)
  - Security Context Constraints (SCC)
  - Projects (namespaces enrichis)
```

### Argo CD

**Rôle** : Continuous Delivery déclarative

```
Git Repository (source of truth) → Argo CD → OpenShift Cluster (desired state)
```

**Utilisé pour** :
*   Synchronisation déclarative
*   GitOps workflow
*   Multi-environnements
*   Promotion dev → prod

## Environnements

### Développement

```
┌────────────────────────────────────┐
│     Namespace: fullstack-dev       │
├────────────────────────────────────┤
│ Frontend: 1 replica                │
│ Backend: 1 replica                 │
│ Database: StatefulSet (1 replica)  │
│ Resources: Minimales               │
│ HPA: Désactivé                     │
│ NetworkPolicy: Désactivée          │
└────────────────────────────────────┘
```

### Production

```
┌────────────────────────────────────┐
│     Namespace: fullstack-prod      │
├────────────────────────────────────┤
│ Frontend: 3 replicas               │
│ Backend: 3 replicas                │
│ Database: PostgreSQL Bitnami       │
│ Resources: Élevées                 │
│ HPA: Activé (2-5 replicas)         │
│ NetworkPolicy: Activée             │
│ PDB: Activé (min 1 Pod)            │
└────────────────────────────────────┘
```

## Flux de données

```
User Request
    ↓
Route OpenShift (frontend.apps.crc.testing)
    ↓
Service Frontend (ClusterIP)
    ↓
Frontend Pod (NGINX)
    ↓
Backend Service (ClusterIP)
    ↓
Backend Pods (Python)
    ↓
Database Service (Headless)
    ↓
PostgreSQL Pod (StatefulSet)
    ↓
Persistent Volume
```

## Sécurité

### Security Context Constraints (SCC)

```
OpenShift SCC
    ├── restricted (par défaut)
    │   ├── runAsUser: non-root
    │   ├── fsGroup: défini
    │   └── capabilities: limitées
    │
    └── restricted-v2 (recommandé)
        ├── runAsUser: 1001
        ├── fsGroup: 1001
        └── seccomp: runtime/default
```

### NetworkPolicy

```
┌─────────────────────────────────────┐
│        Frontend Pod                 │
│  (Ingress: Internet)                │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│        Backend Pod                  │
│  (Ingress: Frontend only)           │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│        Database Pod                 │
│  (Ingress: Backend only)            │
└─────────────────────────────────────┘
```

## Scalabilité

### Horizontal Pod Autoscaler (HPA)

```
CPU Utilization
    ↓
Monitor (Prometheus)
    ↓
HPA Controller
    ↓
Scale Decision
    ├── If CPU > 70% → Scale Up
    └── If CPU < 30% → Scale Down
    ↓
Update Deployment Replicas
```

### Pod Disruption Budget (PDB)

```
Cluster Maintenance
    ↓
Check PDB
    ├── Min Available: 1 Pod
    ├── Can evict: N-1 Pods
    └── Ensure: 1 Pod always running
```

## Monitoring et Observabilité

```
┌──────────────────────────────────────┐
│     Prometheus (Metrics)             │
│  - CPU, Memory, Network              │
│  - Helm releases                     │
│  - Argo CD sync status               │
└──────────────────────────────────────┘
         ↓
┌──────────────────────────────────────┐
│     Grafana (Visualization)          │
│  - Dashboards                        │
│  - Alerts                            │
└──────────────────────────────────────┘
         ↓
┌──────────────────────────────────────┐
│     Alertmanager (Alerting)          │
│  - Email, Slack, PagerDuty           │
└──────────────────────────────────────┘
```

## Cycle de vie d'une application

```
1. Développement
   └── Créer chart Helm
   └── Tester localement
   └── Commiter dans Git

2. CI Pipeline
   └── Build image Docker
   └── Lint chart
   └── Exécuter tests
   └── Push vers registry

3. Déploiement (GitOps)
   └── Argo CD détecte le changement
   └── Synchronise l'Application
   └── Helm déploie sur OpenShift

4. Monitoring
   └── Prometheus collecte les métriques
   └── Grafana affiche les dashboards
   └── Alertes si problème

5. Maintenance
   └── Mise à jour de l'image
   └── Upgrade du chart
   └── Rollback si nécessaire
```

## Intégration avec les Labs

```
Lab 00: Préparation
    ↓
Lab 10-11: Déployer avec Helm
    ↓
Lab 20-21: Créer des charts
    ↓
Lab 30-31: Multi-environnements
    ↓
Lab 40-41: Fonctionnalités avancées
    ↓
Lab 50-51: GitOps et Operators
    ↓
Architecture complète maîtrisée
```

## Ressources

*   [Helm Architecture](https://helm.sh/docs/intro/architecture/)
*   [OpenShift Architecture](https://docs.openshift.com/container-platform/latest/architecture/index.html)
*   [Argo CD Architecture](https://argo-cd.readthedocs.io/en/stable/operator-manual/architecture/)
*   [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
