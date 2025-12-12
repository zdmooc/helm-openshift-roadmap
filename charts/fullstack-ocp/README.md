# Chart Helm `fullstack-ocp`

Ce chart Helm déploie une application full-stack complète sur OpenShift, composée d'un frontend, d'un backend et d'une base de données PostgreSQL.

## Caractéristiques

*   **Frontend** : Serveur web NGINX
*   **Backend** : Application Python (Flask/FastAPI)
*   **Database** : PostgreSQL (via dépendance Bitnami ou StatefulSet personnalisé)
*   **Multi-environnement** : Configurations distinctes pour développement et production
*   **OpenShift-ready** : Routes OpenShift, Security Context Constraints, NetworkPolicy
*   **Scalabilité** : Support HPA (Horizontal Pod Autoscaler) en production
*   **Résilience** : PodDisruptionBudget pour garantir la disponibilité

## Prérequis

*   Cluster OpenShift 4.x
*   Helm 3.x
*   Accès à un namespace avec droits de développeur

## Installation

### 1. Déploiement en développement

```bash
helm install fullstack-dev . \
  -f values-dev.yaml \
  --namespace fullstack-dev \
  --create-namespace
```

### 2. Déploiement en production

```bash
helm install fullstack-prod . \
  -f values-prod.yaml \
  --namespace fullstack-prod \
  --create-namespace
```

### 3. Avec dépendances PostgreSQL Bitnami

Si vous souhaitez utiliser PostgreSQL Bitnami au lieu du StatefulSet personnalisé :

```bash
# Mettre à jour les dépendances
helm dependency update

# Installer avec PostgreSQL Bitnami
helm install fullstack-prod . \
  -f values-prod.yaml \
  --set postgresql.enabled=true \
  --set database.enabled=false \
  --namespace fullstack-prod \
  --create-namespace
```

## Configuration

### Fichiers de valeurs

*   **`values.yaml`** : Configuration par défaut (développement)
*   **`values-dev.yaml`** : Configuration optimisée pour le développement (ressources minimales, pas de HPA)
*   **`values-prod.yaml`** : Configuration optimisée pour la production (ressources élevées, HPA activé, PDB activé)

### Paramètres clés

#### Frontend

```yaml
frontend:
  enabled: true
  replicaCount: 1
  image:
    repository: nginx
    tag: "1.21.0"
  route:
    enabled: true
    host: frontend.apps.crc.testing
```

#### Backend

```yaml
backend:
  enabled: true
  replicaCount: 1
  image:
    repository: python
    tag: "3.9-slim"
```

#### Database

```yaml
postgresql:
  enabled: true
  auth:
    username: appuser
    password: changeme
    database: appdb
```

## Mise à jour

Pour mettre à jour une release existante :

```bash
helm upgrade fullstack-dev . \
  -f values-dev.yaml \
  --namespace fullstack-dev
```

## Suppression

```bash
helm uninstall fullstack-dev --namespace fullstack-dev
oc delete namespace fullstack-dev
```

## Vérifications

### Vérifier les Pods

```bash
oc get pods -n fullstack-dev
```

### Vérifier les Services

```bash
oc get svc -n fullstack-dev
```

### Vérifier les Routes

```bash
oc get route -n fullstack-dev
```

### Accéder à l'application

```bash
oc get route fullstack-dev-frontend -n fullstack-dev -o jsonpath='{.spec.host}'
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    OpenShift Cluster                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         Frontend (NGINX)                    │   │
│  │  - Deployment (N replicas)                  │   │
│  │  - Service (ClusterIP)                      │   │
│  │  - Route (OpenShift)                        │   │
│  └─────────────────────────────────────────────┘   │
│                        ↓                            │
│  ┌─────────────────────────────────────────────┐   │
│  │         Backend (Python)                    │   │
│  │  - Deployment (N replicas)                  │   │
│  │  - Service (ClusterIP)                      │   │
│  │  - HPA (en production)                      │   │
│  └─────────────────────────────────────────────┘   │
│                        ↓                            │
│  ┌─────────────────────────────────────────────┐   │
│  │      Database (PostgreSQL)                  │   │
│  │  - StatefulSet ou Bitnami Chart             │   │
│  │  - Persistent Volume                        │   │
│  │  - Service (Headless)                       │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Support

Pour toute question ou problème, consultez la [documentation principale](../../README.md) ou les [laboratoires](../../labs/).
