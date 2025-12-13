# Polycopié — Helm OpenShift Roadmap (du début à maintenant)

## 0. Vision du parcours (objectif final)
L’objectif global du dépôt **helm-openshift-roadmap** est de te faire progresser, par **labs successifs**, vers une maîtrise opérationnelle de **Helm 3 sur OpenShift**.

À la fin de tous les levels, tu sauras produire un **chart industrialisable** :
- **OpenShift-ready** (Route, SCC/PSA, UID random, restricted-v2)
- **Sécurisé par défaut** (seccomp, readOnlyRootFilesystem, capabilities drop, no privilege escalation)
- **Paramétrable multi-environnements** (values par env, overrides, conventions GitOps)
- **Testable** (Helm tests), **traçable** (evidence/runbook), **maintenable**
- **Prêt GitOps** (compatibilité Argo CD, patterns de packaging)

Ce polycopié couvre **tout ce qui a été fait jusqu’à maintenant**, et sert de base au futur “livre” final.

---

## 1. Méthode de travail (notre “mode opératoire”)
Approche strictement interactive :
1) Une action à la fois
2) Vérifications systématiques après chaque changement
3) Capturer l’évidence (logs/commandes)
4) Commit Git propre et descriptif

Outils utilisés :
- `oc` (OpenShift CLI)
- `helm` (lint/template/upgrade/history/get/test)
- `curl` (test de Route)
- Git Bash (Windows)

---

## 2. Contexte technique du lab en cours
Plateforme : **OpenShift Local / CRC**
Namespace : `myapp-dev`
Release Helm : `myapp`
Chart : `charts/myapp-ocp`
Image : `nginx:1.21.0`
Exposition : `Route` OpenShift

---

## 3. Lab — level-2-template-dev (ce qu’on a fait)
Ce lab a servi à transformer un chart Helm “Kubernetes standard” en un chart **compatible OpenShift restricted-v2**.

### 3.1 Objectifs du level-2
- Déployer avec Helm dans OpenShift
- Exposer via `Route`
- Passer les contraintes de sécurité OpenShift :
  - pas de `runAsUser` fixe (UID random OpenShift)
  - pas de `fsGroup` non autorisé
  - **seccomp RuntimeDefault**
  - **capabilities drop ALL**
  - **allowPrivilegeEscalation false**
  - **runAsNonRoot true**
  - **readOnlyRootFilesystem true**
- Gérer les dossiers d’écriture via `emptyDir`
- Stabiliser NGINX (config) et supprimer warnings inutiles
- Ajouter un **Helm test** automatisé
- Capturer l’évidence + écrire l’historique

---

## 4. Problèmes rencontrés et corrections

### 4.1 Erreur SCC (OpenShift restricted-v2)
Symptôme :
- Events du namespace : `FailedCreate` / “forbidden: unable to validate against any security context constraint”
- Causes : `runAsUser: 1001` et `fsGroup: 1001` non autorisés dans la plage UID/GID allouée au projet.

Correction :
- Supprimer les UID/GID fixes.
- Laisser OpenShift injecter un UID arbitraire dans la plage du namespace.

Validation :
- `oc exec ... id` => UID du type `1000690000` (random projet)

---

### 4.2 Erreurs réseau Multus (Unauthorized)
Symptôme :
- Events: `FailedCreatePodSandBox` / multus / Unauthorized

Résolution :
- Le problème était transitoire pendant les tentatives. Après correction SCC et redéploiement, les pods ont fini par se stabiliser.

Validation :
- Pods en `Running`
- Route répond en HTTP 200

---

### 4.3 Warning Helm : `unknown field "spec.template.spec.volumeMounts"`
Symptôme :
- `helm upgrade` affiche : `unknown field "spec.template.spec.volumeMounts"`

Cause :
- `volumeMounts` était mal positionné au niveau `spec.template.spec` au lieu de `spec.template.spec.containers[].volumeMounts`.

Correction :
- Déplacer `volumeMounts` dans le container.

Validations :
- `helm template ... | grep volumeMounts` => un seul bloc au bon endroit
- `oc get deploy ... jsonpath='{.spec.template.spec.volumeMounts}'` => vide
- `oc get deploy ... jsonpath='{.spec.template.spec.containers[0].volumeMounts}'` => montages OK
- `helm upgrade --dry-run --debug | grep -i warning` => **NO WARNINGS**

---

## 5. Ce qu’on a livré dans le chart (état actuel)

### 5.1 values.yaml (structure utilisée)
- `replicaCount`
- `image.repository`, `image.tag`, `image.pullPolicy`
- `service.type`, `service.port`, `service.targetPort`
- `route.enabled`, `route.host`
- `resources.requests/limits`

Et ajout progressif des options de sécurité gérées au template.

### 5.2 Deployment “restricted OpenShift”
Ajouts clés dans le template :
- Pod securityContext :
  - `seccompProfile: RuntimeDefault`
- Container securityContext :
  - `allowPrivilegeEscalation: false`
  - `capabilities.drop: ["ALL"]`
  - `runAsNonRoot: true`
  - `readOnlyRootFilesystem: true`

Volumes / mounts :
- `emptyDir` montés sur :
  - `/var/cache/nginx`
  - `/var/run`
- ConfigMap monté sur :
  - `/etc/nginx/conf.d/default.conf`
- ConfigMap monté sur :
  - `/etc/nginx/nginx.conf`

### 5.3 ConfigMap NGINX
- `configmap.yaml` : `default.conf` pour servir le contenu sur `8080`
- `configmap-nginx-main.yaml` : `nginx.conf` corrigé

### 5.4 Service + Route
- Service ClusterIP port `80` -> targetPort `8080`
- Route `myapp.apps.crc.testing` (HTTP) -> Service

### 5.5 Probes
- livenessProbe HTTP `/`
- readinessProbe HTTP `/`

### 5.6 Helm test
Ajout : `charts/myapp-ocp/templates/tests/test-service.yaml`
- exécute un `wget/curl` vers le service
- renvoie `OK`
- hook de nettoyage pour éviter l’erreur “pod not found”

---

## 6. Validations réalisées (commandes de référence)

### 6.1 État global
- `helm list -n myapp-dev`
- `helm history myapp -n myapp-dev`
- `oc get deploy,rs,pod,svc,route -n myapp-dev -o wide`

### 6.2 Sécurité OpenShift
- UID random :
  - `oc exec -n myapp-dev $POD -- id`
- seccomp :
  - `oc get pod -n myapp-dev -l app.kubernetes.io/instance=myapp -o jsonpath='{.items[*].spec.securityContext.seccompProfile.type}'`
- securityContext container :
  - `oc get pod ... -o jsonpath='{.items[*].spec.containers[0].securityContext}'`

### 6.3 readOnlyRootFilesystem
- Écriture refusée sur rootfs :
  - `touch /etc/nginx/nginx.conf` => Permission denied / RO
- Écriture OK sur `emptyDir` :
  - `touch /var/cache/nginx/ok`
  - `touch /var/run/...` (selon droits)

### 6.4 Tests NGINX
- `oc exec -n myapp-dev $POD -- nginx -t`

### 6.5 Route
- `curl -I http://myapp.apps.crc.testing` => HTTP 200

### 6.6 Qualité Helm
- `helm lint charts/myapp-ocp`
- `helm template myapp charts/myapp-ocp -n myapp-dev > /tmp/rendered.yaml`
- `helm upgrade myapp charts/myapp-ocp -n myapp-dev --dry-run --debug`

### 6.7 Tests Helm
- `helm test myapp -n myapp-dev --logs`

---

## 7. Traçabilité Git (ce qui a été versionné)
Commits majeurs :
- `lab(level-2): make chart OpenShift-restricted (seccomp, readonly rootfs, nginx conf)`
- `chore: enforce LF line endings via .gitattributes`
- `lab(level-2): add helm test hook for service check`

Fichiers ajoutés/édités :
- `charts/myapp-ocp/templates/deployment.yaml`
- `charts/myapp-ocp/templates/configmap.yaml`
- `charts/myapp-ocp/templates/configmap-nginx-main.yaml`
- `charts/myapp-ocp/values.yaml`
- `charts/myapp-ocp/templates/tests/test-service.yaml`
- `labs/level-2-template-dev/history.md`
- `labs/level-2-template-dev/evidence/commandes-gitbash.txt`
- `.gitattributes`

---

## 8. Où on en est maintenant
État :
- Le chart est **fonctionnel**, **déployé**, **sans warnings Helm**, **compatible OpenShift restricted-v2**, **Route OK**, **Helm test OK**.

Lab actuel : **level-2-template-dev** (terminable dès qu’on a finalisé l’evidence “helm test” + mise à jour history.md si besoin).

---

## 9. Ce qu’il reste (prochaine étape immédiate)
Clôture propre du level-2 :
- Capturer l’evidence du `helm test` dans `labs/level-2-template-dev/evidence/`
- Enrichir `history.md` (résumé : problèmes rencontrés + validations)
- Commit “capture evidence”

---

## 10. Suite du parcours (à venir — vue “livre”)
Ce qui est logique après level-2 :
- **Level-3** : valeurs multi-env (dev/preprod/prod), overrides, conventions
- **Level-4** : packaging, versioning chart, release notes, chart repository (ou OCI)
- **Level-5** : GitOps Argo CD (valueFiles, parameters, sync options, drift)
- **Level-6** : policies (LimitRange/Quota, Kyverno/Gatekeeper), observabilité

(La liste exacte sera alignée sur les dossiers labs du dépôt au moment où on reprend.)

---

## 11. Annexes
### 11.1 Rappel : pourquoi OpenShift refuse runAsUser/fsGroup fixes
OpenShift attribue à chaque namespace une plage UID. Fixer un UID (ex: 1001) sort de cette plage et fait échouer l’admission SCC.

### 11.2 Point d’attention : readOnlyRootFilesystem
Avec `readOnlyRootFilesystem: true`, il faut explicitement prévoir des zones d’écriture (tmp/cache/run) via `emptyDir` ou PVC.

---

# TODO (checklist du polycopié)
- [ ] Ajouter “evidence helm test” (log) dans `evidence/`
- [ ] Mettre à jour `history.md` (résumé clair)
- [ ] Commit/push

