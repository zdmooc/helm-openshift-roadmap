# Helm OpenShift Roadmap — Level 3 (Packaging & Dependencies)

## Contexte
Objectif du Level 3 : **packager un chart “fullstack” avec dépendances (subchart PostgreSQL)**, prouver que ça s’installe correctement sur **OpenShift (CRC)**, et produire des **preuves** (evidence) reproductibles.

Ce lab a aussi permis de traiter un point OpenShift très fréquent : **SCC “restricted” + images non prévues pour un UID arbitraire** (ex : `nginx` qui veut binder le port 80 et écrire sous `/etc/nginx`).

---

## Pré-requis
- Connectée sur le cluster :

```bash
oc whoami
oc status
```

- Helm opérationnel :

```bash
helm version
```

- Namespace utilisé dans ce lab : `fullstack-dev`

---

## Arborescence evidence
On garde un répertoire unique pour les preuves du Level 3.

```bash
cd /c/workspaces/openshift2026/helm-openshift-roadmap
mkdir -p labs/level-3-packaging-dependencies/evidence
```

---

## Step 1 — Vérifier l’état de la release Helm
But : confirmer si la release est `deployed`, `failed`, `pending-*`.

```bash
helm status fullstack -n fullstack-dev
```

Résultat observé au début : `STATUS: failed`.

---

## Step 2 — Collecter la preuve “Helm côté client”
But : récupérer les manifests rendus, notes, valeurs, hooks, etc.

```bash
# Manifests rendus
helm get manifest fullstack -n fullstack-dev > /tmp/fullstack-manifest.yaml || true

# Notes
helm get notes fullstack -n fullstack-dev |& tee labs/level-3-packaging-dependencies/evidence/helm-notes.txt

# Dump complet (values + manifest + hooks + notes)
helm get all fullstack -n fullstack-dev |& tee labs/level-3-packaging-dependencies/evidence/helm-get-all.txt

# Historique
helm history fullstack -n fullstack-dev |& tee labs/level-3-packaging-dependencies/evidence/helm-history-fullstack.log
```

---

## Step 3 — Collecter la preuve “cluster côté OpenShift”
But : voir ce qui existe réellement (Deployments/Pods/Services/Routes/PVC) et les events.

```bash
oc get deploy,sts,po,svc,route,pvc -n fullstack-dev -o wide \
  |& tee labs/level-3-packaging-dependencies/evidence/oc-state-after-reinstall-v2.txt

oc get events -n fullstack-dev --sort-by=.lastTimestamp \
  | tail -n 80 \
  |& tee labs/level-3-packaging-dependencies/evidence/oc-events-after-reinstall-v2.txt
```

Observation clé :
- `backend` **Running**
- `postgresql` **Running**
- `frontend` **CrashLoopBackOff**

---

## Step 4 — Trouver la cause exacte du CrashLoop (frontend)
But : récupérer logs + describe (raison exacte).

```bash
FRONT=$(oc -n fullstack-dev get po -l component=frontend -o jsonpath='{.items[0].metadata.name}')

a) Logs (dernier crash)
oc -n fullstack-dev logs "$FRONT" -c frontend --previous | tail -n 120 \
  |& tee labs/level-3-packaging-dependencies/evidence/logs-frontend-previous.txt

b) Describe pod (events, SCC, securityContext)
oc -n fullstack-dev describe pod "$FRONT" | tail -n 200 \
  |& tee labs/level-3-packaging-dependencies/evidence/describe-frontend.txt
```

### Root cause (confirmée par les logs)
- `nginx` essaye de binder le port **80** :
  - `bind() to 0.0.0.0:80 failed (13: Permission denied)`
- En SCC `restricted-v2`, le conteneur tourne en **non-root** (UID arbitraire), donc **pas le droit** de binder un port < 1024.

Conclusion : **il faut faire écouter nginx sur un port non-privilégié** (ex : 8080) et adapter la conf.

---

## Step 5 — Tentative “UID Base” (piste abandonnée)
But initial : injecter `fsGroup/runAsUser` aligné sur la plage UID SCC du namespace.

### 5.1 Extraire la base UID SCC du namespace
```bash
UID_BASE=$(oc get ns fullstack-dev -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}' | cut -d/ -f1)
echo "UID_BASE=$UID_BASE" | tee labs/level-3-packaging-dependencies/evidence/uid-base-v2.txt
```

### 5.2 Injecter dans un values override
```bash
cat > labs/level-3-packaging-dependencies/values-dev-ocp-uid.yaml <<EOF
openshift:
  uidBase: ${UID_BASE}
EOF
```

### 5.3 Problèmes rencontrés
- `nil pointer evaluating interface {}.uidBase` (clé `openshift` absente)
- tentative avec `dig` → erreur de conversion (`chartutil.Values`)

Conclusion : cette approche est **inutile** pour le problème réel (port 80). Le bon fix est : **listen 8080 + config nginx**.

---

## Step 6 — Fix OpenShift-ready : nginx écoute sur 8080 via ConfigMap

### 6.1 Créer un ConfigMap nginx (default.conf)
But : fournir une conf nginx compatible non-root, avec `listen 8080`.

```bash
cat > charts/fullstack-ocp/templates/frontend-nginx-configmap.yaml <<'EOF'
{{- if .Values.frontend.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "fullstack-ocp.fullname" . }}-frontend-nginx
  labels:
    {{- include "fullstack-ocp.labels" . | nindent 4 }}
    component: frontend
data:
  default.conf: |
    server {
      listen {{ default 8080 .Values.frontend.containerPort }};
      server_name _;

      location = /health {
        return 200 "OK\n";
        add_header Content-Type text/plain;
      }

      location / {
        return 200 "FRONTEND OK\n";
        add_header Content-Type text/plain;
      }
    }
{{- end }}
EOF
```

### 6.2 Adapter le Deployment frontend
But :
- exposer `containerPort: 8080`
- monter le `default.conf` de la ConfigMap
- garder des répertoires writeable (`/var/cache/nginx`, `/var/run`) via `emptyDir`

```bash
cat > charts/fullstack-ocp/templates/frontend-deployment.yaml <<'EOF'
{{- if .Values.frontend.enabled -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "fullstack-ocp.fullname" . }}-frontend
  labels:
    {{- include "fullstack-ocp.labels" . | nindent 4 }}
    component: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  selector:
    matchLabels:
      {{- include "fullstack-ocp.selectorLabels" . | nindent 6 }}
      component: frontend
  template:
    metadata:
      labels:
        {{- include "fullstack-ocp.selectorLabels" . | nindent 8 }}
        component: frontend
    spec:
      containers:
        - name: frontend
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag }}"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: {{ default 8080 .Values.frontend.containerPort }}
              protocol: TCP
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
            runAsNonRoot: true
            readOnlyRootFilesystem: false
          volumeMounts:
            - name: nginx-cache
              mountPath: /var/cache/nginx
            - name: nginx-run
              mountPath: /var/run
            - name: nginx-conf
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.frontend.resources | nindent 12 }}
      volumes:
        - name: nginx-cache
          emptyDir: {}
        - name: nginx-run
          emptyDir: {}
        - name: nginx-conf
          configMap:
            name: {{ include "fullstack-ocp.fullname" . }}-frontend-nginx
{{- end }}
EOF
```

### 6.3 Ajouter un values override pour le port
But : garder le chart générique, et activer le comportement OpenShift via fichier d’override.

```bash
cat > labs/level-3-packaging-dependencies/values-dev-ocp-frontend-port.yaml <<'EOF'
frontend:
  containerPort: 8080
EOF
```

---

## Step 7 — Réinstaller proprement et valider

### 7.1 Nettoyage (optionnel mais utile après plusieurs essais)
But : repartir d’un état propre.

```bash
helm uninstall fullstack -n fullstack-dev --ignore-not-found

oc delete deploy,sts,po,svc,route,cm,secret,sa,role,rolebinding \
  -n fullstack-dev -l app.kubernetes.io/instance=fullstack --ignore-not-found=true
```

### 7.2 Lint + Template
But : vérifier rendu local avant install.

```bash
helm lint charts/fullstack-ocp \
  -f charts/fullstack-ocp/values-dev.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-overrides.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-frontend-port.yaml

helm template fullstack charts/fullstack-ocp -n fullstack-dev \
  -f charts/fullstack-ocp/values-dev.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-overrides.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-frontend-port.yaml \
  --set postgresql.enabled=true \
  > /tmp/fullstack-render.yaml
```

### 7.3 Upgrade/Install
But : installation réelle + wait.

```bash
helm upgrade --install fullstack charts/fullstack-ocp -n fullstack-dev \
  --reset-values \
  -f charts/fullstack-ocp/values-dev.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-overrides.yaml \
  -f labs/level-3-packaging-dependencies/values-dev-ocp-frontend-port.yaml \
  --set postgresql.enabled=true \
  --wait --timeout 10m
```

### 7.4 Vérification cluster
But : confirmer que tout est `Running`.

```bash
oc -n fullstack-dev get po -o wide
oc -n fullstack-dev get deploy,sts,svc,route,pvc -o wide
```

---

## Step 8 — Tests fonctionnels

### 8.1 Test via Route (CRC en HTTP)
```bash
curl -sS http://frontend-dev.apps.crc.testing/health
curl -sS http://frontend-dev.apps.crc.testing/
```

Attendu :
- `/health` → `OK`
- `/` → `FRONTEND OK`

### 8.2 Test backend depuis le cluster (DNS service)
But : valider le réseau service→service.

```bash
oc -n fullstack-dev exec deploy/fullstack-fullstack-ocp-frontend -- \
  sh -c 'curl -sS http://fullstack-fullstack-ocp-backend:5000/health && echo'
```

Attendu : `OK`.

---

## Step 9 — Capturer les preuves finales

```bash
helm status fullstack -n fullstack-dev \
  |& tee labs/level-3-packaging-dependencies/evidence/helm-status-deployed.txt

oc get deploy,sts,po,svc,route,pvc -n fullstack-dev -o wide \
  |& tee labs/level-3-packaging-dependencies/evidence/oc-state-deployed.txt

oc logs -n fullstack-dev -l component=frontend --tail=80 \
  |& tee labs/level-3-packaging-dependencies/evidence/logs-frontend.txt
```

---

## Step 10 — Git : commits + push

### 10.1 Commit “frontend OpenShift-ready”
```bash
git add charts/fullstack-ocp/templates/frontend-deployment.yaml \
        charts/fullstack-ocp/templates/frontend-nginx-configmap.yaml \
        labs/level-3-packaging-dependencies/values-dev-ocp-frontend-port.yaml

git commit -m "Fix frontend for OpenShift restricted SCC: nginx listens on 8080 + ConfigMap"
```

### 10.2 Commit “backend OpenShift-ready” (si appliqué)
```bash
git add charts/fullstack-ocp/templates/backend-deployment.yaml

git commit -m "Fix backend for OpenShift restricted SCC (non-root + health endpoint)"
```

### 10.3 Commit “evidence + overrides”
```bash
git add labs/level-3-packaging-dependencies/evidence \
        labs/level-3-packaging-dependencies/values-dev-ocp-overrides.yaml \
        labs/level-3-packaging-dependencies/values-dev-ocp-uid.yaml

git commit -m "lab(level-3): packaging/deps evidence + OpenShift values overrides"
```

### 10.4 Nettoyage template inutile (si fait)
```bash
git rm charts/fullstack-ocp/templates/services.yaml

git commit -m "Remove unused services.yaml template"
```

### 10.5 Push
```bash
git push
```

---

## Résultat final attendu
- `helm status fullstack -n fullstack-dev` → `STATUS: deployed`
- Pods `backend`, `frontend`, `postgresql` → `Running`
- `curl http://frontend-dev.apps.crc.testing/health` → `OK`
- Test intra-cluster backend → `OK`

---

## Rappels “OpenShift-ready” (patterns à retenir)
- **Ports privilégiés** (<1024) : en SCC restricted, **non-root** ⇒ utiliser **8080/8443**.
- Images (nginx, etc.) : besoin de répertoires writeable ⇒ `emptyDir` sur `/var/run` et `/var/cache/...`.
- Préférer **ConfigMap** pour override de conf (nginx/apache) plutôt que tenter de modifier `/etc` au runtime.

---

## Prochaine étape (Level 4)
- Packaging plus avancé : `helm package`, `helm repo index`, publication dans un repo chart (ou OCI), intégration GitOps (Argo CD).

