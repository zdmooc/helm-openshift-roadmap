_Titre: Lab 21: Route et Contexte de Sécurité (SCC)_ 

## Objectif

Adapter un chart Helm pour qu'il respecte les contraintes de sécurité d'OpenShift (Security Context Constraints - SCC) et pour gérer finement la configuration de la Route.

## Contexte

OpenShift est un environnement Kubernetes sécurisé par défaut. Les conteneurs ne peuvent pas s'exécuter en tant que `root` et sont soumis à des contraintes de sécurité strictes via les SCC. Un chart Helm qui fonctionne sur un Kubernetes standard peut nécessiter des ajustements pour être déployé sur OpenShift. Nous allons modifier notre chart `myapp-ocp` pour qu'il soit compatible.

## Étapes

### 1. Prérequis

Assurez-vous d'avoir le chart `myapp-ocp` créé dans le **Lab 20**.

### 2. Ajouter un Contexte de Sécurité au Deployment

Modifiez le fichier `charts/myapp-ocp/templates/deployment.yaml`. Dans la section `spec.template.spec`, ajoutez un bloc `securityContext` pour spécifier que le conteneur ne s'exécute pas en tant que root.

```yaml
# ... spec.template.spec ...
      securityContext:
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
# ... containers ...
```

*Note : L'UID/GID `1001` est un exemple. Dans un vrai projet, cet ID serait géré par le cluster.* 

### 3. Améliorer la gestion de la Route

Nous allons rendre le nom d'hôte (host) de la Route configurable. Modifiez `charts/myapp-ocp/values.yaml` :

```yaml
# ...
route:
  enabled: true
  host: myapp.apps.crc.testing
```

Puis, mettez à jour `charts/myapp-ocp/templates/route.yaml` pour utiliser cette valeur :

```yaml
# ...
spec:
  host: {{ .Values.route.host | quote }}
  to:
# ...
```

## Vérifications

*   **Déployez le chart mis à jour** :

    ```bash
    helm upgrade --install myapp charts/myapp-ocp --namespace myapp-dev
    ```

*   **Vérifiez le contexte de sécurité du Pod** :

    Inspectez le Pod déployé et vérifiez que le `securityContext` est bien appliqué.

    ```bash
    oc describe pod/myapp-xxxx --namespace myapp-dev | grep -A 3 Security
    ```

*   **Vérifiez la Route** :

    Vérifiez que la Route a été créée avec le nom d'hôte spécifié.

    ```bash
    oc get route myapp --namespace myapp-dev -o yaml
    ```

## Nettoyage

```bash
helm uninstall myapp --namespace myapp-dev
oc delete project myapp-dev
```
