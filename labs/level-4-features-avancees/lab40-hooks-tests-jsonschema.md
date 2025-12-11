_Titre: Lab 40: Hooks, Tests et Validation JSON Schema_

## Objectif

Utiliser les fonctionnalités avancées de Helm pour améliorer la robustesse des déploiements : les **hooks** pour des actions pré/post-installation, les **tests** pour valider un déploiement, et le **JSON Schema** pour valider les valeurs fournies par l'utilisateur.

## Contexte

Pour des déploiements fiables, il est souvent nécessaire d'exécuter des tâches annexes (ex: migrations de base de données, backups) ou de valider que l'application fonctionne correctement après une mise à jour. Helm fournit des mécanismes pour automatiser ces processus.

## Étapes

### 1. Ajouter un Hook de type "post-install"

Un hook est un Job Kubernetes avec une annotation spéciale. Nous allons créer un Job qui s'exécute après l'installation pour afficher un message. Créez `charts/myapp-ocp/templates/post-install-job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-post-install-job"
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
      - name: post-install-container
        image: alpine
        command: ["sh", "-c", "echo Release {{ .Release.Name }} installée avec succès !"]
      restartPolicy: Never
```

### 2. Ajouter un Test Helm

Un test Helm est un Pod qui s'exécute sur `helm test` et dont le succès (exit code 0) indique que la release est fonctionnelle. Créez `charts/myapp-ocp/templates/tests/test-connection.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "myapp-ocp.fullname" . }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ["wget"]
      args: ["{{ include "myapp-ocp.fullname" . }}:{{ .Values.service.port }}"]
  restartPolicy: Never
```

### 3. Valider les valeurs avec JSON Schema

Pour éviter les erreurs de configuration, on peut définir un schéma pour `values.yaml`. Créez `charts/myapp-ocp/values.schema.json`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Valeurs pour le chart myapp-ocp",
  "type": "object",
  "required": ["image"],
  "properties": {
    "replicaCount": {
      "type": "integer",
      "minimum": 1
    },
    "image": {
      "type": "object",
      "properties": {
        "repository": {"type": "string"},
        "tag": {"type": "string"}
      },
      "required": ["repository", "tag"]
    }
  }
}
```

## Vérifications

*   **Déployez le chart** dans un nouveau projet `myapp-test`.
    ```bash
    oc new-project myapp-test
    helm install myapp charts/myapp-ocp -n myapp-test
    ```
*   **Vérifiez le hook**: juste après l'installation, regardez les logs du Job.
    ```bash
    oc logs -l job-name=myapp-post-install-job -n myapp-test
    ```
*   **Exécutez le test**: 
    ```bash
    helm test myapp -n myapp-test
    ```
    Le test doit réussir (SUCCEEDED).
*   **Testez la validation**: Essayez d'installer le chart avec une valeur incorrecte.
    ```bash
    helm install myapp-fail charts/myapp-ocp -n myapp-test --set replicaCount=0
    ```
    Helm devrait retourner une erreur indiquant que `replicaCount` doit être supérieur ou égal à 1.

## Nettoyage

```bash
helm uninstall myapp -n myapp-test
oc delete project myapp-test
```
