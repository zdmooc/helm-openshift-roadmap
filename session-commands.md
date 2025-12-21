# Commandes — export

## Historique complet (history)

```bash
  258          image: bpce-events-demo:latest
  259          ports:
  260          - name: http
  261            containerPort: 8080
  262          env:
  263          - name: KAFKA_BOOTSTRAP_SERVERS
  264            value: bpce-kafka-kafka-bootstrap:9093
  265          - name: KAFKA_USERNAME
  266            value: bpce-app
  267          - name: KAFKA_PASSWORD
  268            valueFrom:
  269              secretKeyRef:
  270                name: bpce-app
  271                key: password
  272          securityContext:
  273            allowPrivilegeEscalation: false
  274            capabilities:
  275              drop: ["ALL"]
  276          readinessProbe:
  277            httpGet:
  278              path: /q/health/ready
  279              port: 8080
  280          livenessProbe:
  281            httpGet:
  282              path: /q/health/live
  283              port: 8080
  284  EOF
  285  cat <<'EOF' > platform/apps/bpce-events-demo/base/service.yaml
  286  apiVersion: v1
  287  kind: Service
  288  metadata:
  289    name: bpce-events-demo
  290    namespace: bpce-platform
  291  spec:
  292    selector:
  293      app: bpce-events-demo
  294    ports:
  295    - name: http
  296      port: 8080
  297      targetPort: 8080
  298  EOF
  299  cat <<'EOF' > platform/apps/bpce-events-demo/base/route.yaml
  300  apiVersion: route.openshift.io/v1
  301  kind: Route
  302  metadata:
  303    name: bpce-events-demo
  304    namespace: bpce-platform
  305  spec:
  306    to:
  307      kind: Service
  308      name: bpce-events-demo
  309    port:
  310      targetPort: http
  311  EOF
  312  cat <<'EOF' > platform/apps/bpce-events-demo/base/kustomization.yaml
  313  apiVersion: kustomize.config.k8s.io/v1beta1
  314  kind: Kustomization
  315  resources:
  316    - imagestream.yaml
  317    - buildconfig.yaml
  318    - deployment.yaml
  319    - service.yaml
  320    - route.yaml
  321  EOF
  322  mkdir -p platform/apps/bpce-events-demo/overlays/lab
  323  cat <<'EOF' > platform/apps/bpce-events-demo/overlays/lab/kustomization.yaml
  324  apiVersion: kustomize.config.k8s.io/v1beta1
  325  kind: Kustomization
  326  resources:
  327    - ../../base
  328  EOF
  329  # Argo CD Application dédiée
  330  mkdir -p argocd/applications
  331  REPO_URL="$(git remote get-url origin)"
  332  cat <<EOF > argocd/applications/bpce-events-demo-lab-app.yaml
  333  apiVersion: argoproj.io/v1alpha1
  334  kind: Application
  335  metadata:
  336    name: bpce-events-demo-lab
  337    namespace: openshift-gitops
  338  spec:
  339    project: default
  340    source:
  341      repoURL: ${REPO_URL}
  342      targetRevision: main
  343      path: platform/apps/bpce-events-demo/overlays/lab
  344    destination:
  345      server: https://kubernetes.default.svc
  346      namespace: bpce-platform
  347    syncPolicy:
  348      automated:
  349        prune: true
  350        selfHeal: true
  351  EOF
  352  git add platform/apps/bpce-events-demo argocd/applications/bpce-events-demo-lab-app.yaml
  353  git commit -m "gitops: add bpce-events-demo build+deploy (lab)"
  354  git push
  355  oc apply -f argocd/applications/bpce-events-demo-lab-app.yaml
  356  cd apps/quarkus/bpce-events-demo
  357  mvn -DskipTests package
  358  oc -n bpce-platform start-build bc/bpce-events-demo --from-dir=. --follow
  359  oc -n bpce-platform rollout status deploy/bpce-events-demo
  360  ROUTE="$(oc -n bpce-platform get route bpce-events-demo -o jsonpath='{.spec.host}')"
  361  MSG="hello-$(date +%s)"
  362  curl -sS -X POST "http://$ROUTE/events" -H 'Content-Type: text/plain' -d "$MSG" -i
  363  oc -n bpce-platform logs deploy/bpce-events-demo --tail=80 | egrep -n "received|$MSG" || true
  364  oc adm policy add-role-to-user admin   -z openshift-gitops-argocd-application-controller   -n bpce-platform
  365  oc -n openshift-gitops annotate application bpce-kafka-lab   argocd.argoproj.io/refresh=hard --overwrite
  366  oc -n openshift-gitops annotate application bpce-events-demo-lab   argocd.argoproj.io/refresh=hard --overwrite
  367  oc -n openshift-gitops get application bpce-kafka-lab bpce-events-demo-lab   -o jsonpath='{range .items[*]}{.metadata.name} sync={.status.sync.status} health={.status.health.status}{"\n"}{end}'
  368  git add platform/kafka/base/kafka-bpce-kafka.yaml
  369  git commit -m "gitops: align Kafka manifest with SCRAM listener (9093)"
  370  git push
  371  cd ..
  372  cd ..
  373  cd ..
  374  git add platform/kafka/base/kafka-bpce-kafka.yaml
  375  git commit -m "gitops: align Kafka manifest with SCRAM listener (9093)"
  376  git push
  377  git add platform/kafka/overlays/lab/kafka-client-pod.yaml
  378  git commit -m "gitops: replace kafka-client Pod with Deployment"
  379  git push
  380  java -version
  381  mvn -v
  382  export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-17.0.*/"
  383  export PATH="$JAVA_HOME/bin:$PATH"
  384  java -version
  385  mvn -v
  386  # détecte le vrai dossier JDK 17 installé (pas de wildcard dans JAVA_HOME)
  387  JDK_DIR="$(ls -d "/c/Program Files/Eclipse Adoptium/jdk-17"* 2>/dev/null | sort | tail -n 1)"
  388  export JAVA_HOME="$JDK_DIR"
  389  export PATH="$JAVA_HOME/bin:$PATH"
  390  "$JAVA_HOME/bin/java" -version
  391  mvn -v
  392  which java
  393  which mvn
  394  echo "$JAVA_HOME"
  395  # 1) Mets JAVA_HOME au format Windows (indispensable pour mvn.cmd)
  396  export JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot'
  397  # 2) Mets les binaires en tête du PATH (format /c/... pour Git Bash)
  398  export PATH="/c/Program Files/Eclipse Adoptium/jdk-17.0.17.10-hotspot/bin:/c/maven/apache-maven-3.9.8/bin:$PATH"
  399  # 3) Force mvn -> mvn.cmd (comme PowerShell)
  400  alias mvn='mvn.cmd'
  401  # 4) Vérifie
  402  type -a mvn
  403  java -version
  404  mvn -v
  405  cat >> ~/.bashrc <<'EOF'
  406  export JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot'
  407  export PATH="/c/Program Files/Eclipse Adoptium\jdk-17.0.17.10-hotspot/bin:/c/maven/apache-maven-3.9.8/bin:$PATH"
  408  alias mvn='mvn.cmd'
  409  EOF
  410  notepad.exe ~/.bashrc
  411  cat ~/.bashrc
  412  notepad.exe ~/.bashrc
  413  sed -i 's#Eclipse Adoptium\\jdk-17\.0\.17\.10-hotspot#Eclipse Adoptium/jdk-17.0.17.10-hotspot#g' ~/.bashrc
  414  source ~/.bashrc
  415  echo "$JAVA_HOME"
  416  type -a mvn
  417  mvn -v
  418  # remplace JAVA_HOME par une forme 100% Windows (sans /)
  419  sed -i "s#^export JAVA_HOME=.*#export JAVA_HOME='C:\\\\Program Files\\\\Eclipse Adoptium\\\\jdk-17.0.17.10-hotspot'#g" ~/.bashrc
  420  source ~/.bashrc
  421  echo "$JAVA_HOME"
  422  mvn -v
  423  mvn -DskipTests clean package
  424  export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-17.0.*/"
  425  export PATH="$JAVA_HOME/bin:$PATH"
  426  java -version
  427  mvn -v
  428  export JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot'
  429  export PATH="/c/Program Files/Eclipse Adoptium/jdk-17.0.17.10-hotspot/bin:/c/maven/apache-maven-3.9.8/bin:$PATH"
  430  alias mvn='mvn.cmd'
  431  mvn -v
  432  oc -n bpce-platform get bc,deploy,svc,route | egrep -i 'bpce-events-demo|NAME' || true
  433  cd apps/quarkus/bpce-events-demo
  434  mvn -DskipTests package
  435  oc -n bpce-platform start-build bc/bpce-events-demo --from-dir=. --follow
  436  oc -n bpce-platform rollout status deploy/bpce-events-demo
  437  ROUTE="$(oc -n bpce-platform get route bpce-events-demo -o jsonpath='{.spec.host}')"
  438  MSG="hello-$(date +%s)"
  439  curl -sS -X POST "http://$ROUTE/events" -H 'Content-Type: text/plain' -d "$MSG" -i
  440  oc -n bpce-platform logs deploy/bpce-events-demo --tail=120 | egrep -n "received|$MSG" || true
  441  grep -n "SECURITY_PROTOCOL\|security.protocol\|KAFKA_SECURITY_PROTOCOL" -n   apps/quarkus/bpce-events-demo/src/main/resources/application.properties
  442  cd /c/workspaces/2026/bpce-natixis-gitops-openshift-quarkus-lab/apps/quarkus/bpce-events-demo
  443  # auto-détection JDK 17 (Temurin ou Java classique)
  444  JDK="$(ls -d "/c/Program Files/Eclipse Adoptium/"jdk-17* "/c/Program Files/Java/"jdk-17* 2>/dev/null | head -n1)"
  445  echo "JDK=$JDK"
  446  export JAVA_HOME="$JDK"
  447  export PATH="$JAVA_HOME/bin:$PATH"
  448  java -version
  449  mvn -v
  450  JDK_DIR="$(ls -d /c/Program\ Files/Eclipse\ Adoptium/jdk-17* | sort | tail -n 1)"
  451  export JAVA_HOME="$(cygpath -w "$JDK_DIR")"
  452  export PATH="$JDK_DIR/bin:/c/maven/apache-maven-3.9.8/bin:$PATH"
  453  alias mvn='mvn.cmd'
  454  echo "$JAVA_HOME"
  455  mvn -v
  456  cd /c/workspaces/2026/bpce-natixis-gitops-openshift-quarkus-lab/apps/quarkus/bpce-events-demo
  457  # garde l'alias mvn Windows
  458  alias mvn='mvn.cmd'
  459  # build
  460  mvn -DskipTests package
  461  # preuve que le runtime Quarkus est bien généré
  462  ls -la target/quarkus-app/ target/quarkus-app/quarkus-run.jar
  463  history > history1612205.txt
  464  git init
  465  git add .
  466  git commit -m "first commit"
  467  git branch -M main
  468  git remote add origin https://github.com/zdmooc/modernis-dat-repo.git
  469  git push -u origin main
  470  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  471  { echo "# Commandes — export"; echo; echo "## Historique filtré"; echo; echo '```'; history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])'; echo '```'; } > "$OUT"
  472  echo "Wrote: $OUT
  473  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  474  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  475  # S'assure que la session courante est écrite dans le fichier d'historique
  476  history -a
  477  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  478  echo "Wrote: $OUT"
  479  echo "HISTFILE=$HISTFILE"
  480  history -a
  481  cat "$HISTFILE" > "/c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt"
  482  git status
  483  sed -n '1,220p' /c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  484  wc -l /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  485  sed -n '1,200p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  486  sed -n '201,400p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  487  history
  488  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  489  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  490  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  491  F="$E/step12-node-netcheck.txt"
  492  echo "=== step12 lines ==="
  493  wc -l "$F" 2>/dev/null || true
  494  tail -n 20 "$F" 2>/dev/null || true
  495  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  496  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  497  { echo "# Commandes — export"; echo; echo "## Historique filtré"; echo; echo '```'; history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])'; echo '```'; } > "$OUT"
  498  echo "Wrote: $OUT"
  499  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  500  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  501  # S'assure que la session courante est écrite dans le fichier d'historique
  502  history -a
  503  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  504  echo "Wrote: $OUT"
  505  echo "HISTFILE=$HISTFILE"
  506  history -a
  507  cat "$HISTFILE" > "/c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt"
  508  git status
  509  sed -n '1,220p' /c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  510  wc -l /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  511  sed -n '1,200p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  512  sed -n '201,400p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  513  history
  514  # 1) Lab50 — step12 / step13 (netcheck node)
  515  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  516  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  517  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  518  F="$E/step12-node-netcheck.txt"
  519  echo "=== step12 lines ==="
  520  wc -l "$F" 2>/dev/null || true
  521  tail -n 20 "$F" 2>/dev/null || true
  522  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  523  # 2) Export filtré (oc/kubectl/helm/argocd/git) -> session-commands.md
  524  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  525  { echo "# Commandes — export"; echo; echo "## Historique filtré"; echo; echo '```'; history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])'; echo '```'; } > "$OUT"
  526  echo "Wrote: $OUT"
  527  # 3) Export complet + filtré -> session-commands.md
  528  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  529  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  530  history -a
  531  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  532  echo "Wrote: $OUT"
  533  # 4) Export HISTFILE -> bash_history_full.txt
  534  echo "HISTFILE=$HISTFILE"
  535  history -a
  536  cat "$HISTFILE" > "/c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt"
  537  # 5) Vérifs / affichages
  538  git status
  539  sed -n '1,220p' /c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  540  wc -l /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  541  sed -n '1,200p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  542  sed -n '201,400p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  543  history
  544  # 1) Lab50 — step12 / step13 (netcheck node)
  545  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  546  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  547  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  548  F="$E/step12-node-netcheck.txt"
  549  echo "=== step12 lines ==="
  550  wc -l "$F" 2>/dev/null || true
  551  tail -n 20 "$F" 2>/dev/null || true
  552  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  553  # 2) Export filtré (oc/kubectl/helm/argocd/git) -> session-commands.md
  554  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  555  { echo "# Commandes — export"; echo; echo "## Historique filtré"; echo; echo '```'; history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])'; echo '```'; } > "$OUT"
  556  echo "Wrote: $OUT"
  557  # 3) Export complet + filtré -> session-commands.md
  558  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  559  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  560  history -a
  561  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  562  echo "Wrote: $OUT"
  563  # 4) Export HISTFILE -> bash_history_full.txt
  564  echo "HISTFILE=$HISTFILE"
  565  history -a
  566  cat "$HISTFILE" > "/c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt"
  567  # 5) Vérifs / affichages
  568  git status
  569  sed -n '1,220p' /c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  570  wc -l /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  571  sed -n '1,200p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  572  sed -n '201,400p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  573  history
  574  # Lab50 — step12 / step13 (netcheck node)
  575  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  576  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  577  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  578  F="$E/step12-node-netcheck.txt"
  579  echo "=== step12 lines ==="
  580  wc -l "$F" 2>/dev/null || true
  581  tail -n 20 "$F" 2>/dev/null || true
  582  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  583  # Export historique vers fichier
  584  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  585  history -a
  586  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  587  echo "Wrote: $OUT"
  588  echo "HISTFILE=$HISTFILE"
  589  history -a
  590  cat "$HISTFILE" > "/c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt"
  591  git status
  592  sed -n '1,220p' /c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  593  wc -l /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  594  sed -n '1,200p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  595  sed -n '201,400p' /c/workspaces/openshift2026/helm-openshift-roadmap/bash_history_full.txt
  596  history
  597  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  598  echo "=== oc context ==="
  599  oc whoami
  600  oc project -q
  601  oc get clusterversion || true
  602  echo "=== openshift-gitops ==="
  603  oc get ns openshift-gitops
  604  oc get pods -n openshift-gitops -o wide
  605  oc get route -n openshift-gitops -l app.kubernetes.io/name=argocd-server || true
  606  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  607  echo "=== namespaces gitops ==="
  608  oc get ns | egrep -i 'openshift-gitops|argocd' || true
  609  echo "=== subscriptions / CSV (gitops) ==="
  610  oc get subscription -A | egrep -i 'gitops|argo' || true
  611  oc get csv -A | egrep -i 'gitops|argo' || true
  612  echo "=== openshift-gitops objects ==="
  613  oc get all -n openshift-gitops || true
  614  oc get argocd -n openshift-gitops || true
  615  echo "=== routes (openshift-gitops) ==="
  616  oc get route -n openshift-gitops || true
  617  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  618  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  619  mkdir -p "$E"
  620  OUT="$E/step00-gitops-check.txt"
  621  {   echo "=== DATE ===";   date;   echo;    echo "=== WHOAMI / PROJECT ===";   oc whoami || true;   oc project -q || true;   echo;    echo "=== NAMESPACES (gitops) ===";   oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true;   echo;    echo "=== CRDs (argoproj/argocd) ===";   oc get crd | egrep -i 'argoproj|argocd|applications\.argoproj|appprojects\.argoproj|applicationsets\.argoproj' || true;   echo;    echo "=== OLM: packagemanifests (gitops) ===";   oc get packagemanifests -n openshift-marketplace | egrep -i 'gitops|openshift-gitops|argo' || true;   echo;    echo "=== packagemanifest openshift-gitops-operator (channels) ===";   oc get packagemanifest openshift-gitops-operator -n openshift-marketplace     -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}' 2>/dev/null || echo "NOT FOUND";   echo;    echo "=== openshift-gitops namespace content ===";   oc get all -n openshift-gitops 2>/dev/null || echo "ns openshift-gitops: not found or empty";   echo;    echo "=== argocd CRs (if CRD exists) ===";   oc get argocd -A 2>/dev/null || echo "argocd CRD missing or no instances";   echo;    echo "=== routes openshift-gitops ===";   oc get route -n openshift-gitops 2>/dev/null || echo "no routes"; } | tee "$OUT"
  622  echo "Wrote: $OUT"
  623  sed -n '1,200p' "$OUT"
  624  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  625  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  626  mkdir -p "$E"
  627  cat > "$E/step00-gitops-check.sh" <<'EOF'
#!/usr/bin/env bash
set -u

echo "=== DATE ==="
date
echo

echo "=== WHOAMI / PROJECT ==="
oc whoami || true
oc project -q || true
echo

echo "=== NAMESPACES (gitops) ==="
oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true
echo

echo "=== CRDs (argoproj/argocd) ==="
oc get crd | egrep -i 'argoproj|argocd|applications\.argoproj|appprojects\.argoproj|applicationsets\.argoproj' || true
echo

echo "=== OLM: packagemanifests (gitops) ==="
oc get packagemanifests -n openshift-marketplace | egrep -i 'gitops|openshift-gitops|argo' || true
echo

echo "=== packagemanifest openshift-gitops-operator (channels) ==="
oc get packagemanifest openshift-gitops-operator -n openshift-marketplace \
  -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}' 2>/dev/null || echo "NOT FOUND"
echo

echo "=== openshift-gitops namespace content ==="
oc get all -n openshift-gitops 2>/dev/null || echo "ns openshift-gitops: not found or empty"
echo

echo "=== argocd CRs (instances) ==="
oc get argocd -A 2>/dev/null || echo "argocd CRD missing or no instances"
echo

echo "=== routes openshift-gitops ==="
oc get route -n openshift-gitops 2>/dev/null || echo "no routes"
EOF

  628  chmod +x "$E/step00-gitops-check.sh"
  629  OUT="$E/step00-gitops-check.txt"
  630  "$E/step00-gitops-check.sh" | tee "$OUT"
  631  echo "Wrote: $OUT"
  632  sed -n '1,200p' "$OUT"
  633  git status
  634  git
  635  git branch
  636  # Lab50 — netcheck node (step12/step13)
  637  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  638  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  639  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  640  F="$E/step12-node-netcheck.txt"
  641  echo "=== step12 lines ==="
  642  wc -l "$F" 2>/dev/null || true
  643  tail -n 20 "$F" 2>/dev/null || true
  644  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  645  # Export commandes (filtré) -> session-commands.md
  646  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  647  { echo "# Commandes — export"; echo; echo "## Historique filtré"; echo; echo '```'; history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])'; echo '```'; } > "$OUT"
  648  echo "Wrote: $OUT"
  649  # Export complet + filtré -> session-commands.md
  650  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  651  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  652  history -a
  653  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  654  echo "Wrote: $OUT"
  655  # Export HISTFILE -> bash_history_full.txt
  656  echo "HISTFILE=$HISTFILE"
  657  history -
  658  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  659  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  660  mkdir -p "$E"
  661  OUT="$E/step00-gitops-state.txt"
  662  (   echo "=== DATE ==="; date; echo;   echo "=== WHOAMI / PROJECT ==="; oc whoami; oc project -q; echo;   echo "=== NAMESPACES (gitops) ==="; oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true; echo;   echo "=== SUBSCRIPTIONS (gitops/argo) ==="; oc get subscription -A | egrep -i 'gitops|argo' || true; echo;   echo "=== CSV (gitops/argo) ==="; oc get csv -A | egrep -i 'gitops|argo' || true; echo;   echo "=== CRDs (argoproj/argocd) ==="; oc get crd | egrep -i 'argoproj|argocd' || true; echo;   echo "=== ARGOCD INSTANCES ==="; oc get argocd -A 2>/dev/null || true; echo;   echo "=== openshift-gitops OBJECTS ==="; oc get all -n openshift-gitops 2>/dev/null || true; ) 2>&1 | tee "$OUT"
  663  echo "Wrote: $OUT"
  664  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  665  # voir ce qui a changé
  666  git status
  667  git diff --stat
  668  # ajouter tout ce que tu viens de créer/modifier
  669  git add -A
  670  # vérif avant commit
  671  git status
  672  git diff --cached --stat
  673  # commit
  674  git commit -m "lab50: evidence gitops checks + netcheck + session command exports"
  675  # push (branche courante)
  676  git push -u origin HEAD
  677  sed -n '1,200p' "labs/level-5-openshift-gitops-expert/evidence/lab50/step01-install-gitops-operator.txt"
  678  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  679  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  680  mkdir -p "$E"
  681  OUT="$E/step03-create-myapp-projects.txt"
  682  (   echo "=== DATE ==="; date; echo;    echo "=== CREATE PROJECTS (myapp-dev / myapp-prod) ===";   oc new-project myapp-dev  || true;   oc new-project myapp-prod || true;   echo;    echo "=== LABEL managed-by (recommended) ===";   oc label ns myapp-dev  argocd.argoproj.io/managed-by=openshift-gitops --overwrite;   oc label ns myapp-prod argocd.argoproj.io/managed-by=openshift-gitops --overwrite;   echo;    echo "=== VERIFY ===";   oc get ns myapp-dev myapp-prod --show-labels; ) 2>&1 | tee "$OUT"
  683  echo "Wrote: $OUT"
  684  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  685  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  686  OUT="$E/step04-apply-argocd-apps.txt"
  687  (   echo "=== DATE ==="; date; echo;    echo "=== APPLY APPLICATIONS (Argo CD) ===";   oc apply -f gitops/argocd-apps/application-myapp-dev.yaml  -n openshift-gitops;   oc apply -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops;   echo;    echo "=== CHECK APPLICATIONS ===";   oc get applications.argoproj.io -n openshift-gitops; ) 2>&1 | tee "$OUT"
  688  echo "Wrote: $OUT"
  689  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  690  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  691  mkdir -p "$E"
  692  # DEV
  693  POD_DEV="$(oc get pod -n myapp-dev -o name | head -n1)"
  694  OUT_DEV="$E/step05-imagepull-debug-myapp-dev.txt"
  695  (   echo "=== DATE ==="; date; echo;   echo "=== DEPLOY IMAGE (myapp-dev) ===";   oc -n myapp-dev get deploy myapp-dev-myapp-ocp -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{" => "}{.image}{"\n"}{end}' || true;   echo;   echo "=== POD ==="; echo "$POD_DEV"; echo;   echo "=== DESCRIBE POD (myapp-dev) ===";   oc -n myapp-dev describe "$POD_DEV" || true;   echo;   echo "=== EVENTS (myapp-dev) ===";   oc -n myapp-dev get events --sort-by=.lastTimestamp | tail -n 50 || true; ) 2>&1 | tee "$OUT_DEV"
  696  echo "Wrote: $OUT_DEV"
  697  # PROD
  698  POD_PROD="$(oc get pod -n myapp-prod -o name | head -n1)"
  699  OUT_PROD="$E/step05-imagepull-debug-myapp-prod.txt"
  700  (   echo "=== DATE ==="; date; echo;   echo "=== DEPLOY IMAGE (myapp-prod) ===";   oc -n myapp-prod get deploy myapp-prod-myapp-ocp -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{" => "}{.image}{"\n"}{end}' || true;   echo;   echo "=== POD ==="; echo "$POD_PROD"; echo;   echo "=== DESCRIBE POD (myapp-prod) ===";   oc -n myapp-prod describe "$POD_PROD" || true;   echo;   echo "=== EVENTS (myapp-prod) ===";   oc -n myapp-prod get events --sort-by=.lastTimestamp | tail -n 50 || true; ) 2>&1 | tee "$OUT_PROD"
  701  echo "Wrote: $OUT_PROD"
  702  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  703  E="labs/level-5-openshift-gitops-expert/evidence/lab50"
  704  echo "===== DEV (image + erreurs) ====="
  705  grep -nE '=> |Image:|ErrImagePull|ImagePullBackOff|Failed|Back-off|pull|unauthorized|authentication|denied|not found|manifest|x509|tls|timeout|i/o|proxy|dns|dial tcp'   "$E/step05-imagepull-debug-myapp-dev.txt" | tail -n 120
  706  echo
  707  echo "===== PROD (image + erreurs) ====="
  708  grep -nE '=> |Image:|ErrImagePull|ImagePullBackOff|Failed|Back-off|pull|unauthorized|authentication|denied|not found|manifest|x509|tls|timeout|i/o|proxy|dns|dial tcp'   "$E/step05-imagepull-debug-myapp-prod.txt" | tail -n 120
  709  sed -n '/=== DEPLOY IMAGE/,/=== EVENTS/p' "labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-dev.txt"  | tail -n 220
  710  sed -n '/=== DEPLOY IMAGE/,/=== EVENTS/p' "labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-prod.txt" | tail -n 220
  711  git status
  712  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  713  # 1) Force l’affichage (pas de pager)
  714  GIT_PAGER=cat git status -sb
  715  # 2) Montre TOUT (même untracked), en format machine
  716  git status --porcelain=v1 -uall
  717  # 3) Vérifie que tes fichiers step05 existent et ont du contenu
  718  ls -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt
  719  wc -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt
  720  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  721  GIT_PAGER=cat git status -sb
  722  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  723  DBG="_debug/git-debug-$(date +%Y%m%d-%H%M%S).txt"
  724  mkdir -p _debug
  725  {   echo "DATE: $(date)";   echo "PWD : $(pwd)";   echo "BRANCH: $(git branch --show-current 2>/dev/null || echo '?')";   echo;    echo "== git --version ==";   git --version 2>&1;   echo;    echo "== git status -sb ==";   git --no-pager status -sb 2>&1;   echo;    echo "== git status --porcelain=v1 -uall ==";   git status --porcelain=v1 -uall 2>&1;   echo;    echo "== last commit ==";   git --no-pager log -1 --oneline --decorate 2>&1;   echo;    echo "== step05 files (existence + taille) ==";   ls -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt 2>&1 || true;   wc -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt 2>&1 || true; } > "$DBG"
  726  echo "WROTE: $DBG"
  727  notepad.exe "$(cygpath -w "$DBG")"
  728  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  729  # 1) Ajoute uniquement l'evidence lab50 (et optionnellement le debug)
  730  git add labs/level-5-openshift-gitops-expert/evidence/lab50
  731  # Optionnel: garder le debug (sinon ne pas l'ajouter)
  732  # git add _debug
  733  # 2) Vérifie
  734  git status -sb
  735  git diff --cached --stat
  736  # 3) Commit
  737  git commit -m "lab50: gitops operator + namespaces/projects + apps apply + imagepull debug"
  738  # 4) Push
  739  git push
  740  # --- Lab50 : netcheck node (step12/step13) ---
  741  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  742  E=labs/level-5-openshift-gitops-expert/evidence/lab50
  743  NODE="$(oc get nodes -o jsonpath='{.items[0].metadata.name}')"
  744  F="$E/step12-node-netcheck.txt"
  745  echo "=== step12 lines ==="
  746  wc -l "$F" 2>/dev/null || true
  747  tail -n 20 "$F" 2>/dev/null || true
  748  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
    echo "--- DATE"; date
    echo "--- PROXY ENV"; env | egrep -i "http_proxy|https_proxy|no_proxy" || true
    echo "--- DNS"; getent hosts registry.redhat.io || true
  '; fi
  749  # --- Export commandes de session (filtré) ---
  750  OUT=/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md
  751  {   echo "# Commandes — export";   echo;   echo "## Historique filtré";   echo;   echo '```';   history | grep -Ei '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
  752  echo "Wrote: $OUT"
  753  # --- Export commandes de session (complet + filtré) ---
  754  cd /c/workspaces/openshift2026/helm-openshift-roadmap
  755  OUT="/c/workspaces/openshift2026/helm-openshift-roadmap/session-commands.md"
  756  history -a
  757  {   echo "# Commandes — export";   echo;   echo "## Historique complet (history)";   echo;   echo '```bash';   history;   echo '```';   echo;   echo "## Historique filtré (oc/kubectl/helm/argocd/git)";   echo;   echo '```bash';   history | grep -E '(^|[[:space:]])(oc|kubectl|helm|argocd|git)($|[[:space:]])';   echo '```'; } > "$OUT"
```

## Historique filtré (oc/kubectl/helm/argocd/git)

```bash
  352  git add platform/apps/bpce-events-demo argocd/applications/bpce-events-demo-lab-app.yaml
  353  git commit -m "gitops: add bpce-events-demo build+deploy (lab)"
  354  git push
  355  oc apply -f argocd/applications/bpce-events-demo-lab-app.yaml
  358  oc -n bpce-platform start-build bc/bpce-events-demo --from-dir=. --follow
  359  oc -n bpce-platform rollout status deploy/bpce-events-demo
  363  oc -n bpce-platform logs deploy/bpce-events-demo --tail=80 | egrep -n "received|$MSG" || true
  364  oc adm policy add-role-to-user admin   -z openshift-gitops-argocd-application-controller   -n bpce-platform
  365  oc -n openshift-gitops annotate application bpce-kafka-lab   argocd.argoproj.io/refresh=hard --overwrite
  366  oc -n openshift-gitops annotate application bpce-events-demo-lab   argocd.argoproj.io/refresh=hard --overwrite
  367  oc -n openshift-gitops get application bpce-kafka-lab bpce-events-demo-lab   -o jsonpath='{range .items[*]}{.metadata.name} sync={.status.sync.status} health={.status.health.status}{"\n"}{end}'
  368  git add platform/kafka/base/kafka-bpce-kafka.yaml
  369  git commit -m "gitops: align Kafka manifest with SCRAM listener (9093)"
  370  git push
  374  git add platform/kafka/base/kafka-bpce-kafka.yaml
  375  git commit -m "gitops: align Kafka manifest with SCRAM listener (9093)"
  376  git push
  377  git add platform/kafka/overlays/lab/kafka-client-pod.yaml
  378  git commit -m "gitops: replace kafka-client Pod with Deployment"
  379  git push
  432  oc -n bpce-platform get bc,deploy,svc,route | egrep -i 'bpce-events-demo|NAME' || true
  435  oc -n bpce-platform start-build bc/bpce-events-demo --from-dir=. --follow
  436  oc -n bpce-platform rollout status deploy/bpce-events-demo
  440  oc -n bpce-platform logs deploy/bpce-events-demo --tail=120 | egrep -n "received|$MSG" || true
  464  git init
  465  git add .
  466  git commit -m "first commit"
  467  git branch -M main
  468  git remote add origin https://github.com/zdmooc/modernis-dat-repo.git
  469  git push -u origin main
  482  git status
  495  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
  508  git status
  522  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
  538  git status
  552  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
  568  git status
  582  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
  591  git status
  598  echo "=== oc context ==="
  599  oc whoami
  600  oc project -q
  601  oc get clusterversion || true
  603  oc get ns openshift-gitops
  604  oc get pods -n openshift-gitops -o wide
  605  oc get route -n openshift-gitops -l app.kubernetes.io/name=argocd-server || true
  608  oc get ns | egrep -i 'openshift-gitops|argocd' || true
  610  oc get subscription -A | egrep -i 'gitops|argo' || true
  611  oc get csv -A | egrep -i 'gitops|argo' || true
  613  oc get all -n openshift-gitops || true
  614  oc get argocd -n openshift-gitops || true
  616  oc get route -n openshift-gitops || true
  621  {   echo "=== DATE ===";   date;   echo;    echo "=== WHOAMI / PROJECT ===";   oc whoami || true;   oc project -q || true;   echo;    echo "=== NAMESPACES (gitops) ===";   oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true;   echo;    echo "=== CRDs (argoproj/argocd) ===";   oc get crd | egrep -i 'argoproj|argocd|applications\.argoproj|appprojects\.argoproj|applicationsets\.argoproj' || true;   echo;    echo "=== OLM: packagemanifests (gitops) ===";   oc get packagemanifests -n openshift-marketplace | egrep -i 'gitops|openshift-gitops|argo' || true;   echo;    echo "=== packagemanifest openshift-gitops-operator (channels) ===";   oc get packagemanifest openshift-gitops-operator -n openshift-marketplace     -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}' 2>/dev/null || echo "NOT FOUND";   echo;    echo "=== openshift-gitops namespace content ===";   oc get all -n openshift-gitops 2>/dev/null || echo "ns openshift-gitops: not found or empty";   echo;    echo "=== argocd CRs (if CRD exists) ===";   oc get argocd -A 2>/dev/null || echo "argocd CRD missing or no instances";   echo;    echo "=== routes openshift-gitops ===";   oc get route -n openshift-gitops 2>/dev/null || echo "no routes"; } | tee "$OUT"
oc whoami || true
oc project -q || true
oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true
oc get crd | egrep -i 'argoproj|argocd|applications\.argoproj|appprojects\.argoproj|applicationsets\.argoproj' || true
oc get packagemanifests -n openshift-marketplace | egrep -i 'gitops|openshift-gitops|argo' || true
oc get packagemanifest openshift-gitops-operator -n openshift-marketplace \
oc get all -n openshift-gitops 2>/dev/null || echo "ns openshift-gitops: not found or empty"
echo "=== argocd CRs (instances) ==="
oc get argocd -A 2>/dev/null || echo "argocd CRD missing or no instances"
oc get route -n openshift-gitops 2>/dev/null || echo "no routes"
  633  git status
  634  git
  635  git branch
  644  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
  662  (   echo "=== DATE ==="; date; echo;   echo "=== WHOAMI / PROJECT ==="; oc whoami; oc project -q; echo;   echo "=== NAMESPACES (gitops) ==="; oc get ns | egrep -i 'openshift-gitops|openshift-gitops-operator|argocd' || true; echo;   echo "=== SUBSCRIPTIONS (gitops/argo) ==="; oc get subscription -A | egrep -i 'gitops|argo' || true; echo;   echo "=== CSV (gitops/argo) ==="; oc get csv -A | egrep -i 'gitops|argo' || true; echo;   echo "=== CRDs (argoproj/argocd) ==="; oc get crd | egrep -i 'argoproj|argocd' || true; echo;   echo "=== ARGOCD INSTANCES ==="; oc get argocd -A 2>/dev/null || true; echo;   echo "=== openshift-gitops OBJECTS ==="; oc get all -n openshift-gitops 2>/dev/null || true; ) 2>&1 | tee "$OUT"
  666  git status
  667  git diff --stat
  669  git add -A
  671  git status
  672  git diff --cached --stat
  674  git commit -m "lab50: evidence gitops checks + netcheck + session command exports"
  676  git push -u origin HEAD
  682  (   echo "=== DATE ==="; date; echo;    echo "=== CREATE PROJECTS (myapp-dev / myapp-prod) ===";   oc new-project myapp-dev  || true;   oc new-project myapp-prod || true;   echo;    echo "=== LABEL managed-by (recommended) ===";   oc label ns myapp-dev  argocd.argoproj.io/managed-by=openshift-gitops --overwrite;   oc label ns myapp-prod argocd.argoproj.io/managed-by=openshift-gitops --overwrite;   echo;    echo "=== VERIFY ===";   oc get ns myapp-dev myapp-prod --show-labels; ) 2>&1 | tee "$OUT"
  687  (   echo "=== DATE ==="; date; echo;    echo "=== APPLY APPLICATIONS (Argo CD) ===";   oc apply -f gitops/argocd-apps/application-myapp-dev.yaml  -n openshift-gitops;   oc apply -f gitops/argocd-apps/application-myapp-prod.yaml -n openshift-gitops;   echo;    echo "=== CHECK APPLICATIONS ===";   oc get applications.argoproj.io -n openshift-gitops; ) 2>&1 | tee "$OUT"
  695  (   echo "=== DATE ==="; date; echo;   echo "=== DEPLOY IMAGE (myapp-dev) ===";   oc -n myapp-dev get deploy myapp-dev-myapp-ocp -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{" => "}{.image}{"\n"}{end}' || true;   echo;   echo "=== POD ==="; echo "$POD_DEV"; echo;   echo "=== DESCRIBE POD (myapp-dev) ===";   oc -n myapp-dev describe "$POD_DEV" || true;   echo;   echo "=== EVENTS (myapp-dev) ===";   oc -n myapp-dev get events --sort-by=.lastTimestamp | tail -n 50 || true; ) 2>&1 | tee "$OUT_DEV"
  700  (   echo "=== DATE ==="; date; echo;   echo "=== DEPLOY IMAGE (myapp-prod) ===";   oc -n myapp-prod get deploy myapp-prod-myapp-ocp -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{" => "}{.image}{"\n"}{end}' || true;   echo;   echo "=== POD ==="; echo "$POD_PROD"; echo;   echo "=== DESCRIBE POD (myapp-prod) ===";   oc -n myapp-prod describe "$POD_PROD" || true;   echo;   echo "=== EVENTS (myapp-prod) ===";   oc -n myapp-prod get events --sort-by=.lastTimestamp | tail -n 50 || true; ) 2>&1 | tee "$OUT_PROD"
  711  git status
  714  GIT_PAGER=cat git status -sb
  716  git status --porcelain=v1 -uall
  721  GIT_PAGER=cat git status -sb
  725  {   echo "DATE: $(date)";   echo "PWD : $(pwd)";   echo "BRANCH: $(git branch --show-current 2>/dev/null || echo '?')";   echo;    echo "== git --version ==";   git --version 2>&1;   echo;    echo "== git status -sb ==";   git --no-pager status -sb 2>&1;   echo;    echo "== git status --porcelain=v1 -uall ==";   git status --porcelain=v1 -uall 2>&1;   echo;    echo "== last commit ==";   git --no-pager log -1 --oneline --decorate 2>&1;   echo;    echo "== step05 files (existence + taille) ==";   ls -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt 2>&1 || true;   wc -l labs/level-5-openshift-gitops-expert/evidence/lab50/step05-imagepull-debug-myapp-*.txt 2>&1 || true; } > "$DBG"
  730  git add labs/level-5-openshift-gitops-expert/evidence/lab50
  732  # git add _debug
  734  git status -sb
  735  git diff --cached --stat
  737  git commit -m "lab50: gitops operator + namespaces/projects + apps apply + imagepull debug"
  739  git push
  748  if [[ "$(wc -l < "$F" 2>/dev/null)" -le 3 ]]; then   echo "=== step13 rerun with winpty ===";   winpty oc debug node/"$NODE" -- bash -lc '
```
