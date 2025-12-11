_Titre: Lab 20: Créer un Chart Helm `myapp-ocp`_ 

## Objectif

Créer un chart Helm simple pour une application web "maison", en incluant les ressources de base (Deployment, Service) et en l'adaptant pour OpenShift.

## Contexte

Si `helm install` est utile pour les applications tierces, la vraie puissance de Helm réside dans la capacité à packager ses propres applications. Cela permet de standardiser les déploiements, de gérer les configurations et de partager facilement les applications au sein d'une organisation. Nous allons utiliser la commande `helm create` pour générer un squelette de chart.

## Étapes

### 1. Créer un nouveau projet

```bash
oc new-project myapp-dev
```

### 2. Créer le squelette du chart

Placez-vous dans le répertoire `helm-openshift-roadmap` et exécutez :

```bash
helm create charts/myapp-ocp
```

Cela va générer une arborescence de fichiers standard pour un nouveau chart. Nous allons simplifier et adapter ces fichiers.

### 3. Nettoyer le chart généré

Par défaut, `helm create` génère beaucoup de fichiers d'exemple. Pour notre cas simple, nous pouvons supprimer :

*   `templates/tests/` (le répertoire de tests)
*   `templates/NOTES.txt`
*   `templates/ingress.yaml` (nous utiliserons une Route OpenShift)
*   `templates/hpa.yaml`
*   Le contenu de `templates/_helpers.tpl`

### 4. Adapter `values.yaml`

Modifiez le fichier `charts/myapp-ocp/values.yaml` pour qu'il contienne uniquement les valeurs qui nous intéressent :

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21.0"

service:
  type: ClusterIP
  port: 80

route:
  enabled: true
```

### 5. Créer le template de Route

Créez un nouveau fichier `charts/myapp-ocp/templates/route.yaml` :

```yaml
{{- if .Values.route.enabled -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ include "myapp-ocp.fullname" . }}
  labels:
    {{- include "myapp-ocp.labels" . | nindent 4 }}
spec:
  to:
    kind: Service
    name: {{ include "myapp-ocp.fullname" . }}
  port:
    targetPort: http
{{- end }}
```

## Vérifications

*   **Vérifiez la syntaxe du chart** :

    ```bash
    helm lint charts/myapp-ocp
    ```

*   **Déployez le chart** :

    ```bash
    helm install myapp charts/myapp-ocp --namespace myapp-dev
    ```

*   **Vérifiez les ressources créées** :

    ```bash
    oc get all,route --namespace myapp-dev
    ```

    Vous devriez voir un Deployment, un Service, un Pod et une Route.

*   **Accédez à l'application** via l'URL de la Route.

## Nettoyage

```bash
helm uninstall myapp --namespace myapp-dev
oc delete project myapp-dev
```
