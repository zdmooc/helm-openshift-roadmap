# Level 4 – Features avancées (Lab40 + Lab41)

Document « runbook » reproductible : **commandes + objectif + fichiers d’evidence**.
Chemins basés sur ton poste : `C:\workspaces\openshift2026\helm-openshift-roadmap`.

---

## Pré-requis communs

- Être dans le dépôt :

```bash
cd /c/workspaces/openshift2026/helm-openshift-roadmap
```

- Outils : `helm`, `oc`, `git`.
- Connexion cluster :

```bash
oc whoami
oc version
helm version --short
```

- Convention evidence :

```bash
E=labs/level-4-features-avancees/evidence/<lab>
mkdir -p "$E"
```

---

## Lab 40 – Hooks + Tests + JSONSchema (focus: hook Job migrate)

### Objectif
- Ajouter un **hook Helm** (Job) exécuté en **pre-install/pre-upgrade**.
- Capturer les preuves : `helm lint`, `helm template`, `helm upgrade`, `oc get/describe/logs`, événements réseau/multus.

### Arborescence evidence attendue
- `labs/level-4-features-avancees/evidence/lab40/`

### Étape A — Baseline (lint/template avec valeurs de release)

**But**: établir une baseline avant hook.

```bash
E=labs/level-4-features-avancees/evidence/lab40
mkdir -p "$E"

# Optionnel : capturer charts trouvés
find charts -maxdepth 2 -name Chart.yaml -print | tee "$E/chart-yamls.txt"

# Baseline sur fullstack-ocp (si utilisé dans le lab)
helm lint charts/fullstack-ocp | tee "$E/step8-helm-lint.txt"
helm template fullstack-ocp charts/fullstack-ocp > "$E/step8-helm-template.yaml"

# Variante si tu pars d’une release existante
helm status <RELEASE> -n <NS> | tee "$E/helm-status.txt"
helm get values <RELEASE> -n <NS> -o yaml | tee "$E/helm-get-values.txt"
helm get manifest <RELEASE> -n <NS> | tee "$E/helm-get-manifest.yaml"
```

**Evidence**: `step8-helm-lint.txt`, `step8-helm-template.yaml`, + éventuellement `helm-status/values/manifest`.

### Étape B — Ajouter le hook migrate (Job)

**But**: créer un Job hook `pre-install,pre-upgrade`.

Fichier typique :
- `charts/fullstack-ocp/templates/hooks-migrate-job.yaml`

Annotations minimales (exemple) :
- `helm.sh/hook: pre-install,pre-upgrade`
- `helm.sh/hook-weight: "0"`
- `helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded`

Validation :

```bash
helm lint charts/fullstack-ocp | tee "$E/step9-helm-lint.txt"
helm template fullstack-ocp charts/fullstack-ocp > "$E/step9-helm-template.yaml"

# Vérifier que le hook est bien rendu
grep -n "helm.sh/hook" -n "$E/step9-helm-template.yaml" | tee "$E/step10-grep-helm-in-template.txt"
```

**Evidence**: `step9-*`, `step10-*`.

### Étape C — Exécuter un upgrade/install (déclenchement hook)

**But**: provoquer l’exécution du Job hook.

```bash
# Exemple upgrade
helm upgrade --install fullstack-ocp charts/fullstack-ocp -n <NS> --create-namespace \
  | tee "$E/step13-helm-upgrade-with-hook.txt"

# Observer jobs/pods
oc get jobs -n <NS> | tee "$E/step13-oc-get-job.txt"
oc get pods -n <NS> | tee "$E/step13-oc-get-hook-pod.txt"

# Décrire le job
oc describe job <HOOK_JOB_NAME> -n <NS> | tee "$E/step13-oc-describe-job.txt"

# Logs (si pod connu)
oc logs job/<HOOK_JOB_NAME> -n <NS> | tee "$E/step13-oc-logs-migrate.txt"
```

**Evidence**: `step13-*`.

### Étape D — Debug “ContainerCreating / réseau / multus”

**But**: diagnostiquer un blocage réseau (ex: multus unauthorized), capturer événements.

```bash
# Nom du pod hook
oc get pods -n <NS> -o name | grep -i migrate | head -n1 | tee "$E/step14-hook-pod-name.txt"

POD=$(cat "$E/step14-hook-pod-name.txt" | sed 's#pod/##')

oc describe pod "$POD" -n <NS> | tee "$E/step14-oc-describe-hook-pod.txt"
oc get events -n <NS> --sort-by=.metadata.creationTimestamp | tail -n 200 \
  | tee "$E/step14-oc-events-tail.txt"

# Etat réseau global (OpenShift)
oc get co network | tee "$E/step15-co-network.txt"

# Multus (si namespace openshift-multus présent)
oc get pods -n openshift-multus -o wide | tee "$E/step15-openshift-multus-pods.txt" || true
oc get pods -n openshift-multus -o wide | tee "$E/step15-openshift-multus-pods-after.txt" || true
oc get deploy -n openshift-multus -o wide | tee "$E/step15-openshift-multus-workloads.txt" || true
oc get events -n openshift-multus --sort-by=.metadata.creationTimestamp | tail -n 200 \
  | tee "$E/step15-openshift-multus-events-tail.txt" || true
```

**Evidence**: `step14-*`, `step15-*`.

### Étape E — Hook delete policy + preuve YAML du job après run

**But**: confirmer `hook-delete-policy` et capturer le YAML final du job.

```bash
# Vérifier delete policy dans template
grep -n "hook-delete-policy" -n charts/fullstack-ocp/templates/hooks-migrate-job.yaml \
  | tee "$E/step12-hook-delete-policy.txt"

# Après succès : récupérer YAML du job
oc get job <HOOK_JOB_NAME> -n <NS> -o yaml \
  | tee "$E/step17-hook-job-yaml-after-run.yaml"
```

---

## Lab 41 – Dépôt Helm sur GitHub Pages + Artifact Hub (optionnel)

### Objectif
- Packager `charts/myapp-ocp` → `.tgz`.
- Publier dans un **repo Helm** statique (GitHub Pages) : `index.yaml` + `.tgz`.
- Vérifier côté client : `helm repo add`, `helm search`, `curl -I`.

### Evidence
- `labs/level-4-features-avancees/evidence/lab41/`

### Step01 — Capture contexte + consignes

```bash
E=labs/level-4-features-avancees/evidence/lab41
mkdir -p "$E"

git rev-parse --abbrev-ref HEAD | tee "$E/step01-branch.txt"
git remote -v | tee "$E/step01-remote.txt"
date | tee "$E/step01-date.txt"

wc -l labs/level-4-features-avancees/lab41-repo-helm-github-et-artifacthub.md \
  | tee "$E/step01-lab41-wc.txt"
sed -n '1,220p' labs/level-4-features-avancees/lab41-repo-helm-github-et-artifacthub.md \
  | tee "$E/step01-lab41-md-head.txt"

git add "$E/step01-"*
git commit -m "lab41: init evidence + capture lab instructions"
```

### Step02 — Lint + package

```bash
E=labs/level-4-features-avancees/evidence/lab41
CHART_DIR="charts/myapp-ocp"

helm show chart "$CHART_DIR" | tee "$E/step02-helm-show-chart.txt"
helm lint "$CHART_DIR" | tee "$E/step02-helm-lint.txt"

mkdir -p "$E/pkg"
helm package "$CHART_DIR" -d "$E/pkg" | tee "$E/step02-helm-package.txt"
ls -la "$E/pkg" | tee "$E/step02-pkg-ls.txt"

ls -1 "$E/pkg"/*.tgz | head -n1 | tee "$E/step02-package-path.txt"

git add "$E/step02-"*
git commit -m "lab41: package chart + capture lint/show evidence"
```

### Step03–05 — Fix `networkpolicy.yaml` (nil pointer) + rendre le template safe

#### Problème typique
- `helm lint` échoue : `.Values.networkPolicy.enabled` absent.

#### Fix recommandé (simple et robuste)
- Ajouter un bloc `networkPolicy:` dans `values.yaml`.
- Encadrer le template par `with` + `if`.

Header recommandé dans `charts/myapp-ocp/templates/networkpolicy.yaml` :

```yaml
{{- with .Values.networkPolicy }}
{{- if .enabled }}
...
{{- end }}
{{- end }}
```

Valeurs recommandées dans `charts/myapp-ocp/values.yaml` :

```yaml
networkPolicy:
  enabled: false
  allowedNamespaces:
    - openshift-ingress
```

Bump version (`Chart.yaml`) à chaque correctif : `0.1.0 → 0.1.1 → 0.1.2 → 0.1.3`.

Validation :

```bash
helm lint charts/myapp-ocp
helm template myapp-ocp charts/myapp-ocp > /tmp/myapp-rendered.yaml
```

(Et capture evidence : heads/tails + lint + package, comme tu l’as fait en step03/04/05.)

### Step06 — Validation serveur (dry-run=server)

**But**: détecter YAML invalide (validation API server).

```bash
E=labs/level-4-features-avancees/evidence/lab41
CHART_DIR=charts/myapp-ocp
NS=myapp-repo-test

helm lint "$CHART_DIR" | tee "$E/step06-helm-lint.txt"
helm template myapp-ocp "$CHART_DIR" > "$E/step06-helm-template.yaml"

oc get ns "$NS" >/dev/null 2>&1 || oc new-project "$NS" | tee "$E/step06-oc-new-project.txt"

oc apply -n "$NS" --dry-run=server -f "$E/step06-helm-template.yaml" \
  | tee "$E/step06-oc-apply-dry-run-server.txt" || true

git add "$E/step06-"*
git commit -m "lab41: validate rendered manifests (server dry-run)"
```

### Step07 — Publier le repo Helm dans un dépôt GitHub Pages (repo séparé)

#### Repo cible
- Exemple : `https://github.com/<USER>/my-helm-charts`
- Contenu servi par Pages : dossier **`/docs`**.

#### Script (local)

```bash
# A exécuter à côté (dans /c/workspaces/openshift2026)
cd /c/workspaces/openshift2026

USER=zdmooc
REPO=my-helm-charts
PAGES_URL="https://${USER}.github.io/${REPO}"
SRC_TGZ="/c/workspaces/openshift2026/helm-openshift-roadmap/labs/level-4-features-avancees/evidence/lab41/pkg/myapp-ocp-0.1.3.tgz"

mkdir -p ${REPO}/docs
cp -f "$SRC_TGZ" ${REPO}/docs/

helm repo index ${REPO}/docs --url "$PAGES_URL" \
  | tee "/c/workspaces/openshift2026/helm-openshift-roadmap/labs/level-4-features-avancees/evidence/lab41/step07-helm-repo-index.txt"

ls -la ${REPO}/docs
sed -n '1,120p' ${REPO}/docs/index.yaml
```

#### Publier sur GitHub

```bash
cd /c/workspaces/openshift2026/my-helm-charts

git init
git branch -M main
git remote add origin https://github.com/zdmooc/my-helm-charts.git

git add docs
git commit -m "Publish Helm repo (docs/index.yaml + tgz)"
git push -u origin main
```

#### Activer GitHub Pages (UI)
- GitHub → Repo `my-helm-charts` → **Settings** → **Pages**
- Source : **Deploy from a branch**
- Branch : `main` ; Folder : `/docs`

Astuce URL directe (si menu introuvable) :
- Ouvrir : `https://github.com/<USER>/<REPO>/settings/pages`

### Step08 — Vérifier côté client (HTTP + Helm)

```bash
PAGES_URL="https://zdmooc.github.io/my-helm-charts"
ROADMAP="/c/workspaces/openshift2026/helm-openshift-roadmap"
E="$ROADMAP/labs/level-4-features-avancees/evidence/lab41"

helm repo remove my-charts >/dev/null 2>&1 || true
helm repo add my-charts "$PAGES_URL" | tee "$E/step07-helm-repo-add.txt"
helm repo update | tee "$E/step07-helm-repo-update.txt"

helm search repo my-charts/myapp-ocp -l | tee "$E/step08-helm-search-repo.txt"
helm show chart my-charts/myapp-ocp | tee "$E/step08-helm-show-chart-from-repo.txt"

curl -I "$PAGES_URL/index.yaml" | tee "$E/step08-curl-index-head.txt"
curl -I "$PAGES_URL/myapp-ocp-0.1.3.tgz" | tee "$E/step08-curl-tgz-head.txt"

cd "$ROADMAP"
git add "$E/step07-"* "$E/step08-"*
git commit -m "lab41: verify GitHub Pages helm repo (helm repo add/search + curl 200 evidence)"
```

### Artifact Hub (optionnel)
- Se connecter à Artifact Hub (GitHub OAuth)
- Ajouter repo : URL `https://<USER>.github.io/my-helm-charts`
- Vérifier l’index expose bien `entries:`.

---

## Checklist “Done” Level 4

- [x] Lab40 : hook job (pre-install/pre-upgrade) + preuves `helm/oc/events`.
- [x] Lab41 : chart `myapp-ocp` lint OK + version bump + validation server dry-run.
- [x] Repo Helm GitHub Pages : `docs/index.yaml` + `.tgz`, `curl -I` en 200, `helm repo add/search` OK.
- [x] PR mergée dans `master`, branches lab supprimées (local + origin).

---

## Nettoyage (optionnel)

```bash
# Projet de test
oc delete project myapp-repo-test || true

# Repo helm côté client
helm repo remove my-charts || true
```

