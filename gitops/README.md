_Titre: GitOps avec Argo CD sur OpenShift_

## Vue d'ensemble

Ce répertoire contient les manifestes Argo CD pour déployer les applications Helm de ce dépôt en utilisant une approche GitOps. Argo CD synchronise automatiquement l'état du cluster avec les déclarations présentes dans ce dépôt Git.

## Qu'est-ce que GitOps ?

GitOps est une méthodologie qui utilise Git comme source unique de vérité pour déclarer l'état souhaité d'une infrastructure. Les changements sont versionnés, auditables et peuvent être facilement rollback.

**Avantages** :
*   **Traçabilité** : Tous les changements sont enregistrés dans Git
*   **Auditabilité** : Historique complet des modifications
*   **Automation** : Déploiements automatiques lors de changements
*   **Récupération** : Rollback facile en cas de problème
*   **Collaboration** : Utilisation des pull requests pour les changements

## Architecture GitOps

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Repository                      │
│  (helm-openshift-roadmap)                                   │
│  - charts/myapp-ocp                                         │
│  - charts/fullstack-ocp                                     │
│  - gitops/argocd-apps/                                      │
└────────────────────────┬────────────────────────────────────┘
                         │ (Git webhook)
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    Argo CD (OpenShift)                       │
│  - Surveille le dépôt Git                                   │
│  - Détecte les changements                                  │
│  - Synchronise automatiquement                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                 OpenShift Cluster                            │
│  - Namespaces: myapp-dev, myapp-prod                        │
│  - Namespaces: fullstack-dev, fullstack-prod                │
│  - Applications déployées et synchronisées                  │
└─────────────────────────────────────────────────────────────┘
```

## Structure du répertoire

```
gitops/
├── README.md                              # Ce fichier
├── argocd-apps/
│   ├── application-myapp-dev.yaml         # App Argo CD pour myapp en dev
│   ├── application-myapp-prod.yaml        # App Argo CD pour myapp en prod
│   ├── application-fullstack-dev.yaml     # App Argo CD pour fullstack en dev
│   ├── application-fullstack-prod.yaml    # App Argo CD pour fullstack en prod
│   └── application-helm-roadmap.yaml      # App-of-Apps orchestrant tous les déploiements
└── examples/
    └── README-gitops-exemples.md          # Exemples et bonnes pratiques
```

## Installation d'Argo CD

### 1. Installer l'Operator OpenShift GitOps

Via la console web d'OpenShift :
1. Allez dans **Operators > OperatorHub**
2. Recherchez **OpenShift GitOps**
3. Cliquez sur **Install**
4. Acceptez les paramètres par défaut et cliquez sur **Install**

L'Operator crée automatiquement une instance d'Argo CD dans le namespace `openshift-gitops`.

### 2. Accéder à Argo CD

Récupérez l'URL de la console Argo CD :

```bash
oc get route -n openshift-gitops -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].spec.host}'
```

Connectez-vous avec vos identifiants OpenShift.

## Déploiement des Applications

### Option 1 : Déployer individuellement

Déployez chaque application séparément :

```bash
# Application myapp en développement
oc apply -f gitops/argocd-apps/application-myapp-dev.yaml -n openshift-gitops

# Application myapp en production
oc apply -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops

# Application fullstack en développement
oc apply -f gitops/argocd-apps/application-fullstack-dev.yaml -n openshift-gitops

# Application fullstack en production
oc apply -f gitops/argocd-apps/application-fullstack-prod.yaml -n openshift-gitops
```

### Option 2 : Utiliser l'App-of-Apps (recommandé)

Déployez une seule application qui orchestrera toutes les autres :

```bash
oc apply -f gitops/argocd-apps/application-helm-roadmap.yaml -n openshift-gitops
```

Cette approche est plus propre et permet de gérer tous les déploiements comme une unité.

## Synchronisation

### Synchronisation manuelle

1. Accédez à la console Argo CD
2. Cliquez sur l'application
3. Cliquez sur le bouton **Sync**
4. Confirmez la synchronisation

### Synchronisation automatique

La synchronisation automatique est activée par défaut dans les manifestes. Argo CD :
*   Synchronise automatiquement quand le Git change
*   Nettoie les ressources supprimées de Git (`prune: true`)
*   Corrige les dérives (`selfHeal: true`)

## Gestion des environnements

### Développement vs. Production

Les fichiers de valeurs distincts (`values-dev.yaml` et `values-prod.yaml`) permettent des configurations différentes :

**Développement** :
*   Ressources minimales
*   Pas d'HPA
*   Pas de PDB
*   Pas de NetworkPolicy

**Production** :
*   Ressources élevées
*   HPA activé (2-5 replicas)
*   PDB activé (minimum 1 Pod disponible)
*   NetworkPolicy activée

### Promotion dev → prod

Pour promouvoir une application de dev à prod :

1. Testez en développement
2. Une fois validé, appliquez le manifeste prod
3. Argo CD synchronise automatiquement

Ou, pour une approche plus GitOps :

1. Créez une branche `main` pour la prod
2. Pointez l'Application prod vers la branche `main`
3. Utilisez des pull requests pour les changements

## Dépannage

### L'Application est OutOfSync

Cela signifie que l'état du cluster ne correspond pas à celui déclaré dans Git.

**Solutions** :
*   Cliquez sur **Sync** pour synchroniser manuellement
*   Vérifiez les logs de l'Application pour les erreurs
*   Assurez-vous que le dépôt Git est accessible

### Les Pods ne démarrent pas

Vérifiez les logs :

```bash
# Logs de l'Application Argo CD
oc logs -n openshift-gitops deployment/argocd-application-controller

# Logs des Pods déployés
oc logs -n myapp-dev deployment/myapp
```

### Erreur d'authentification Git

Si Argo CD ne peut pas accéder au dépôt Git :

1. Assurez-vous que l'URL du dépôt est correcte
2. Pour les dépôts privés, configurez une clé SSH ou un token GitHub
3. Consultez la documentation d'Argo CD pour l'authentification

## Bonnes pratiques

1. **Utilisez des branches Git** pour les environnements :
   - `main` pour la production
   - `develop` pour la pré-production
   - `feature/*` pour les développements

2. **Versionnez vos charts** correctement dans `Chart.yaml`

3. **Testez en dev avant prod** : Déployez d'abord en développement, validez, puis en production

4. **Utilisez des namespaces distincts** pour chaque environnement

5. **Gérez les secrets** avec Sealed Secrets ou External Secrets, jamais en clair dans Git

6. **Auditez les changements** : Utilisez les pull requests pour tous les changements

7. **Monitorer Argo CD** : Configurez des alertes pour les synchronisations échouées

## Intégration avec les Labs

Les manifestes Argo CD utilisent les charts Helm du dépôt. Consultez :
*   [Lab 50](../labs/level-5-openshift-gitops-expert/lab50-argo-cd-helm-multi-environnements.md) pour une démonstration complète
*   [Lab 51](../labs/level-5-openshift-gitops-expert/lab51-operator-helm-based-intro.md) pour les Operators basés sur Helm

## Ressources utiles

*   [Documentation officielle Argo CD](https://argo-cd.readthedocs.io/)
*   [Argo CD sur OpenShift](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html)
*   [GitOps Best Practices](https://opengitops.dev/)

## Support

Pour toute question, consultez :
*   La [documentation principale](../README.md)
*   Les [exemples GitOps](./examples/README-gitops-exemples.md)
*   Les [laboratoires pratiques](../labs/)
