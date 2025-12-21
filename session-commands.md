# Commandes — export

## Historique complet (history)

```bash
  154  kafka.sasl.mechanism=${env:KAFKA_SASL_MECHANISM:SCRAM-SHA-512}
  155  kafka.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${env:KAFKA_USERNAME}" password="${env:KAFKA_PASSWORD}";
  156  EOF
  157  cat <<'EOF' > apps/quarkus/bpce-events-demo/src/main/java/com/bpce/events/EventsResource.java
  158  package com.bpce.events;
  159  import jakarta.enterprise.context.ApplicationScoped;
  160  import jakarta.ws.rs.Consumes;
  161  import jakarta.ws.rs.POST;
  162  import jakarta.ws.rs.Path;
  163  import jakarta.ws.rs.core.MediaType;
  164  import jakarta.ws.rs.core.Response;
  165  import org.eclipse.microprofile.reactive.messaging.Channel;
  166  import org.eclipse.microprofile.reactive.messaging.Emitter;
  167  @Path("/events")
  168  @ApplicationScoped
  169  public class EventsResource {
  170    @Channel("events-out")
  171    Emitter<String> emitter;
  172    @POST
  173    @Consumes(MediaType.TEXT_PLAIN)
  174    public Response send(String body) {
  175      emitter.send(body == null ? "" : body);
  176      return Response.accepted().build();
  177    }
  178  }
  179  EOF
  180  cat <<'EOF' > apps/quarkus/bpce-events-demo/src/main/java/com/bpce/events/EventsConsumer.java
  181  package com.bpce.events;
  182  import jakarta.enterprise.context.ApplicationScoped;
  183  import org.eclipse.microprofile.reactive.messaging.Incoming;
  184  import org.jboss.logging.Logger;
  185  @ApplicationScoped
  186  public class EventsConsumer {
  187    private static final Logger LOG = Logger.getLogger(EventsConsumer.class);
  188    @Incoming("events-in")
  189    public void consume(String msg) {
  190      LOG.infov("bpce-events-demo received: {0}", msg);
  191    }
  192  }
  193  EOF
  194  # Dockerfile utilisé par BuildConfig (attend target/quarkus-app présent)
  195  mkdir -p apps/quarkus/bpce-events-demo/src/main/docker
  196  cat <<'EOF' > apps/quarkus/bpce-events-demo/src/main/docker/Dockerfile.jvm
  197  FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:latest
  198  WORKDIR /work/
  199  COPY target/quarkus-app/ /work/
  200  EXPOSE 8080
  201  USER 1001
  202  CMD ["java","-jar","quarkus-run.jar"]
  203  EOF
  204  git add apps/quarkus/bpce-events-demo
  205  git commit -m "apps: add quarkus bpce-events-demo (producer/consumer kafka)"
  206  git push
  207  mkdir -p platform/apps/bpce-events-demo/base
  208  cat <<'EOF' > platform/apps/bpce-events-demo/base/imagestream.yaml
  209  apiVersion: image.openshift.io/v1
  210  kind: ImageStream
  211  metadata:
  212    name: bpce-events-demo
  213    namespace: bpce-platform
  214  EOF
  215  cat <<'EOF' > platform/apps/bpce-events-demo/base/buildconfig.yaml
  216  apiVersion: build.openshift.io/v1
  217  kind: BuildConfig
  218  metadata:
  219    name: bpce-events-demo
  220    namespace: bpce-platform
  221  spec:
  222    source:
  223      type: Binary
  224    strategy:
  225      type: Docker
  226      dockerStrategy:
  227        dockerfilePath: src/main/docker/Dockerfile.jvm
  228    output:
  229      to:
  230        kind: ImageStreamTag
  231        name: bpce-events-demo:latest
  232    triggers: []
  233  EOF
  234  cat <<'EOF' > platform/apps/bpce-events-demo/base/deployment.yaml
  235  apiVersion: apps/v1
  236  kind: Deployment
  237  metadata:
  238    name: bpce-events-demo
  239    namespace: bpce-platform
  240    annotations:
  241      image.openshift.io/triggers: |
  242        [{"from":{"kind":"ImageStreamTag","name":"bpce-events-demo:latest"},"fieldPath":"spec.template.spec.containers[0].image"}]
  243  spec:
  244    replicas: 1
  245    selector:
  246      matchLabels:
  247        app: bpce-events-demo
  248    template:
  249      metadata:
  250        labels:
  251          app: bpce-events-demo
  252      spec:
  253        securityContext:
  254          seccompProfile:
  255            type: RuntimeDefault
  256        containers:
  257        - name: app
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
```

## Historique filtré (oc/kubectl/helm/argocd/git)

```bash
  204  git add apps/quarkus/bpce-events-demo
  205  git commit -m "apps: add quarkus bpce-events-demo (producer/consumer kafka)"
  206  git push
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
```
