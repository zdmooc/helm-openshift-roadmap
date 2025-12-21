# Commandes exécutées — session (reconstituées depuis la conversation)

> Limite : je ne peux lister **que** les commandes visibles dans les messages de cette conversation. Une partie du fil est tronquée ("conversation too long; truncated"), donc je ne vois pas toutes les commandes exécutées depuis le début. La section **Extraction complète** te permet d’exporter 100% de ton historique depuis ton poste.

## 1) Commandes visibles dans la conversation

### Lab Level-5 — lab50 (step12/step13)

```bash
cd /c/workspaces/openshift2026/helm-openshift-roadmap
E=labs/level-5-openshift-gitops-expert/evidence/lab50
NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
F="$E/step12-node-netcheck.txt"

echo "=== step12 lines ==="
wc -l "$F" 2>/dev/null || true
tail -n 20 "$F" 2>/dev/null || true

if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then
  echo "=== step13 rerun with winpty ==="
  winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
    # (suite non visible dans la conversation)
  '
fi
```

## 2) Extraction complète (depuis ton poste)

### Option A — Export brut de l’historique (Git Bash / WSL)

#### Git Bash (Windows)
```bash
# 1) Voir où est ton HISTFILE
set | grep -E '^HISTFILE='

# 2) Exporter l’historique (si tu es dans la même session shell)
history > /c/workspaces/openshift2026/helm-openshift-roadmap/session-history.txt

# 3) Variante avec numéros
history | nl -ba > /c/workspaces/openshift2026/helm-openshift-roadmap/session-history-numbered.txt
```

#### WSL / Linux
```bash
history > ~/session-history.txt
history | nl -ba > ~/session-history-numbered.txt
```

### Option B — Filtrer uniquement les commandes “lab” (oc/helm/kubectl/argocd/git)

```bash
OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-history-filtered.txt
history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git|kustomize|podman|docker)($|[[:space:]])' > "$OUT"
```

### Option C — Récupérer l’historique via les fichiers (si tu as changé de terminal)

#### Git Bash
```bash
ls -la ~/.bash_history

grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])' ~/.bash_history \
  > /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history-filtered.txt
```

#### WSL
```bash
ls -la ~/.bash_history
ls -la ~/.zsh_history 2>/dev/null || true

grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])' ~/.bash_history \
  > ~/bash_history-filtered.txt
```

## 3) Format Markdown prêt à coller dans un canvas

```bash
OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
{
  echo "# Commandes — export";
  echo;
  echo "## Historique filtré";
  echo;
  echo '```';
  history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';
  echo '```';
} > "$OUT"

echo "Wrote: $OUT"
```

## 4) Pour que je produise le canvas “100% complet”

Colle ici :
- le contenu de `session-history.txt` (ou `session-history-filtered.txt`),
- ou le fichier `session-commands.md`.

Je remplacerai alors ce canvas par la liste exhaustive, ordonnée, avec une courte description par commande et la correspondance avec tes steps/labs.

