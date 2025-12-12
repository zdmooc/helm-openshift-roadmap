_Titre: Exemple CI/CD pour Helm sur OpenShift_

## Vue d'ensemble

Ce document montre comment intégrer Helm dans un pipeline CI/CD pour automatiser le build, les tests et le déploiement d'applications sur OpenShift.

## Architecture CI/CD

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Repository                    │
│  - Code source                                          │
│  - Dockerfile                                           │
│  - Chart Helm                                           │
└────────────────────────┬────────────────────────────────┘
                         │ (Git push)
                         ↓
┌─────────────────────────────────────────────────────────┐
│              GitHub Actions (CI Pipeline)               │
│  1. Build image Docker                                  │
│  2. Push vers registry (Quay.io, Docker Hub)            │
│  3. Lint chart Helm                                     │
│  4. Valider templates                                   │
│  5. Exécuter tests                                      │
└────────────────────────┬────────────────────────────────┘
                         │ (Success)
                         ↓
┌─────────────────────────────────────────────────────────┐
│         Argo CD (CD Pipeline - GitOps)                  │
│  1. Détecter le changement                              │
│  2. Synchroniser avec le cluster                        │
│  3. Déployer la nouvelle version                        │
└────────────────────────┬────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────┐
│                 OpenShift Cluster                        │
│  - Application déployée                                 │
│  - Tests de santé                                       │
│  - Monitoring                                           │
└─────────────────────────────────────────────────────────┘
```

## Pipeline GitHub Actions

Voici un exemple de workflow GitHub Actions pour un pipeline CI/CD complet :

### 1. Build et Push d'image Docker

**Fichier** : `.github/workflows/build.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Quay.io
        uses: docker/login-action@v2
        with:
          registry: quay.io
          username: ${{ secrets.QUAY_USERNAME }}
          password: ${{ secrets.QUAY_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: quay.io/${{ secrets.QUAY_USERNAME }}/myapp:${{ github.sha }}
          tags: quay.io/${{ secrets.QUAY_USERNAME }}/myapp:latest
```

### 2. Validation et Tests Helm

**Fichier** : `.github/workflows/helm-test.yml`

```yaml
name: Helm Lint and Test

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'charts/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'charts/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'
      
      - name: Lint myapp-ocp chart
        run: helm lint charts/myapp-ocp
      
      - name: Lint fullstack-ocp chart
        run: helm lint charts/fullstack-ocp
      
      - name: Validate templates
        run: |
          helm template myapp charts/myapp-ocp | kubectl apply --dry-run=client -f -
          helm template fullstack charts/fullstack-ocp | kubectl apply --dry-run=client -f -
      
      - name: Run Helm tests
        run: |
          helm install myapp-test charts/myapp-ocp --dry-run --debug
          helm install fullstack-test charts/fullstack-ocp --dry-run --debug
```

### 3. Déploiement avec Argo CD

**Fichier** : `.github/workflows/deploy.yml`

```yaml
name: Deploy to OpenShift

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up kubectl
        uses: azure/setup-kubectl@v3
      
      - name: Configure kubectl
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config
          chmod 600 $HOME/.kube/config
      
      - name: Sync Argo CD Applications
        run: |
          kubectl apply -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops
          kubectl apply -f gitops/argocd-apps/application-fullstack-prod.yaml -n openshift-gitops
      
      - name: Wait for sync
        run: |
          kubectl wait --for=condition=Synced application/myapp-prod -n openshift-gitops --timeout=300s
          kubectl wait --for=condition=Synced application/fullstack-prod -n openshift-gitops --timeout=300s
```

## Pipeline Tekton (Alternative)

Si vous utilisez Tekton (pipeline natif OpenShift) au lieu de GitHub Actions :

### 1. Task Helm Lint

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: helm-lint
spec:
  params:
    - name: chart-path
      description: Path to the Helm chart
  steps:
    - name: lint
      image: alpine/helm:latest
      script: |
        helm lint $(params.chart-path)
```

### 2. Task Helm Deploy

```yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: helm-deploy
spec:
  params:
    - name: chart-path
      description: Path to the Helm chart
    - name: release-name
      description: Release name
    - name: namespace
      description: Target namespace
    - name: values-file
      description: Values file to use
  steps:
    - name: deploy
      image: alpine/helm:latest
      script: |
        helm upgrade --install $(params.release-name) $(params.chart-path) \
          -f $(params.values-file) \
          --namespace $(params.namespace) \
          --create-namespace
```

## Bonnes pratiques

### 1. Versionnage des images

Utilisez des tags sémantiques pour vos images Docker :

```bash
# Tag avec le SHA du commit
docker tag myapp:latest quay.io/user/myapp:$GIT_SHA

# Tag avec la version
docker tag myapp:latest quay.io/user/myapp:v1.0.0

# Tag latest pour la branche main
docker tag myapp:latest quay.io/user/myapp:latest
```

### 2. Validation des charts

Toujours valider les charts avant le déploiement :

```bash
# Lint
helm lint charts/myapp-ocp

# Valider les templates
helm template myapp charts/myapp-ocp | kubectl apply --dry-run=client -f -

# Valider le schéma
helm template myapp charts/myapp-ocp --values invalid-values.yaml 2>&1 | grep -i error
```

### 3. Tests d'intégration

Tester le chart dans un environnement de test avant la production :

```bash
# Installer dans un namespace de test
helm install myapp-test charts/myapp-ocp --namespace test --create-namespace

# Exécuter les tests
helm test myapp-test --namespace test

# Nettoyer
helm uninstall myapp-test --namespace test
```

### 4. Promotion dev → prod

Utilisez des branches ou des tags pour contrôler la promotion :

```yaml
# .github/workflows/promote.yml
on:
  push:
    tags:
      - 'v*'

jobs:
  promote:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          kubectl apply -f gitops/argocd-apps/application-myapp-prod.yaml
```

### 5. Secrets et configuration

Ne commitez jamais de secrets en clair. Utilisez :

*   **GitHub Secrets** pour les credentials
*   **Sealed Secrets** ou **External Secrets** pour les secrets Kubernetes
*   **ConfigMaps** pour les configurations non-sensibles

```yaml
# Utiliser les secrets GitHub
- name: Deploy
  env:
    REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
  run: |
    echo $REGISTRY_PASSWORD | docker login -u $REGISTRY_USER --password-stdin
```

## Monitoring et Alertes

### 1. Vérifier le statut du déploiement

```bash
# Vérifier l'Application Argo CD
kubectl get application myapp-prod -n openshift-gitops

# Vérifier les Pods
kubectl get pods -n myapp-prod

# Vérifier les logs
kubectl logs -n myapp-prod deployment/myapp
```

### 2. Configurer des alertes

Utilisez Prometheus et Alertmanager pour monitorer :

```yaml
# Alerte si l'Application est OutOfSync
- alert: ArgoCDAppOutOfSync
  expr: argocd_app_info{sync_status="OutOfSync"} == 1
  for: 5m
  annotations:
    summary: "Argo CD Application {{ $labels.name }} is OutOfSync"
```

## Ressources utiles

*   [GitHub Actions Documentation](https://docs.github.com/en/actions)
*   [Tekton Pipelines](https://tekton.dev/)
*   [Argo CD CI/CD Integration](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/)
*   [OpenShift Pipelines](https://docs.openshift.com/container-platform/latest/cicd/pipelines/understanding-openshift-pipelines.html)

## Exemple complet

Pour un exemple complet et fonctionnel, consultez le dépôt [zdmooc/helm-openshift-roadmap](https://github.com/zdmooc/helm-openshift-roadmap) qui inclut des workflows GitHub Actions prêts à l'emploi.
