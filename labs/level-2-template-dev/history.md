HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026
$ oc version
oc whoami --show-server
oc get nodes
helm version
test -d helm-openshift-roadmap && cd helm-openshift-roadmap || (git clone https://github.com/zdmooc/helm-openshift-roadmap.git && cd helm-openshift-roadmap)
Client Version: 4.19.3
Kustomize Version: v5.5.0
Server Version: 4.19.3
Kubernetes Version: v1.32.5
https://api.crc.testing:6443
NAME   STATUS   ROLES                         AGE    VERSION
crc    Ready    control-plane,master,worker   155d   v1.32.5
version.BuildInfo{Version:"v3.15.2", GitCommit:"1a500d5625419a524fdae4b33de351cc4f58ec35", GitTreeState:"clean", GoVersion:"go1.22.4"}

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc whoami
oc project
oc get project helm-labs >/dev/null 2>&1 || oc new-project helm-labs --display-name="Helm Labs" --description="Roadmap Helm OpenShift"
oc project helm-labs
oc get ns helm-labs
kubeadmin
Using project "ex280-lab00-bootstrap-zidane" on server "https://api.crc.testing:6443".
Now using project "helm-labs" on server "https://api.crc.testing:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.43 -- /agnhost serve-hostname

Already on project "helm-labs" on server "https://api.crc.testing:6443".
NAME        STATUS   AGE
helm-labs   Active   3s

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc project helm-labs
oc auth can-i create deployments
oc auth can-i create routes
oc get sc
oc get sc -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}'
Already on project "helm-labs" on server "https://api.crc.testing:6443".
yes
yes
NAME                                     PROVISIONER                        RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
crc-csi-hostpath-provisioner (default)   kubevirt.io.hostpath-provisioner   Retain          WaitForFirstConsumer   false                  154d
crc-csi-hostpath-provisioner    true

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ ls -1 labs/level-1-helm-user
ls -1 charts
sed -n '1,120p' labs/level-1-helm-user/lab10*.md
lab10-deployer-nginx-sur-openshift.md
lab11-upgrade-rollback-release.md
README.md
fullstack-ocp/
myapp-ocp/
_Titre: Lab 10: Déployer NGINX sur OpenShift_

## Objectif

Déployer une première application sur OpenShift en utilisant un chart Helm provenant d'un dépôt public (Bitnami). Créer une Route pour exposer l'application à l'extérieur du cluster.

## Contexte

Le cas d'usage le plus courant de Helm est de déployer des applications tierces (bases de données, serveurs web, etc.) qui sont déjà packagées sous forme de charts. Nous allons utiliser le chart NGINX de Bitnami, qui est une référence dans l'écosystème Helm.

## Étapes

### 1. Créer un nouveau projet

Créez un projet OpenShift dédié pour ce laboratoire :

```bash
oc new-project helm-demo
```

### 2. Ajouter le dépôt de charts Bitnami

Ajoutez le dépôt de charts de Bitnami à votre configuration Helm locale :

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### 3. Déployer le chart NGINX

Installez le chart NGINX dans le projet `helm-demo`. Nous nommons cette release `my-nginx`.

```bash
helm install my-nginx bitnami/nginx --namespace helm-demo
```

### 4. Exposer l'application avec une Route

Par défaut, le chart NGINX crée un Service de type `LoadBalancer`. Sur OpenShift, la manière idiomatique d'exposer un service est d'utiliser une **Route**. Créez une Route pour le service NGINX :

```bash
oc expose service/my-nginx --name=my-nginx-route --namespace helm-demo
```

## Vérifications

*   **Vérifiez la release Helm** :

    ```bash
    helm list --namespace helm-demo
    ```

    Vous devriez voir la release `my-nginx` avec le statut `deployed`.

*   **Vérifiez les Pods** :

    ```bash
    oc get pods --namespace helm-demo
    ```

    Vous devriez voir un Pod `my-nginx-xxxx` en cours d'exécution (`Running`).

*   **Accédez à l'application** :

    Récupérez l'URL de la Route :

    ```bash
    oc get route my-nginx-route --namespace helm-demo --template='{{.spec.host}}'
    ```

    Ouvrez cette URL dans votre navigateur. Vous devriez voir la page d'accueil de NGINX.

## Nettoyage

Pour supprimer la release et toutes les ressources associées, exécutez :

```bash
helm uninstall my-nginx --namespace helm-demo
```

Pour supprimer le projet :

```bash
oc delete project helm-demo
```

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc new-project helm-demo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
Now using project "helm-demo" on server "https://api.crc.testing:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.43 -- /agnhost serve-hostname

"bitnami" already exists with the same configuration, skipping
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "apache-airflow" chart repository
...Successfully got an update from the "ibm-helm" chart repository
...Successfully got an update from the "ibm-helm-repo" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm install my-nginx bitnami/nginx -n helm-demo
helm list -n helm-demo
oc get pods -n helm-demo
NAME: my-nginx
LAST DEPLOYED: Sat Dec 13 10:17:00 2025
NAMESPACE: helm-demo
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 22.3.8
APP VERSION: 1.29.4

⚠ WARNING: Since August 28th, 2025, only a limited subset of images/charts are available for free.
    Subscribe to Bitnami Secure Images to receive continued support and security updates.
    More info at https://bitnami.com and https://github.com/bitnami/containers/issues/83267

** Please be patient while the chart is being deployed **
NGINX can be accessed through the following DNS name from within your cluster:

    my-nginx.helm-demo.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace helm-demo -w my-nginx'

    export SERVICE_PORT=$(kubectl get --namespace helm-demo -o jsonpath="{.spec.ports[0].port}" services my-nginx)
    export SERVICE_IP=$(kubectl get svc --namespace helm-demo my-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
WARNING: Rolling tag detected (bitnami/nginx:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html
WARNING: Rolling tag detected (bitnami/git:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html
WARNING: Rolling tag detected (bitnami/nginx-exporter:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - cloneStaticSiteFromGit.gitSync.resources
  - resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-nginx        helm-demo       1               2025-12-13 10:17:00.7235439 +0100 CET   deployed        nginx-22.3.8    1.29.4
NAME                       READY   STATUS     RESTARTS   AGE
my-nginx-797874586-zp7pk   0/1     Init:0/1   0          2s

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc wait --for=condition=Available deploy/my-nginx -n helm-demo --timeout=180s
oc expose svc/my-nginx -n helm-demo --name=my-nginx-route
oc get route my-nginx-route -n helm-demo --template='{{.spec.host}}{{"\n"}}'
curl -I "http://$(oc get route my-nginx-route -n helm-demo --template='{{.spec.host}}')"
deployment.apps/my-nginx condition met
route.route.openshift.io/my-nginx-route exposed
my-nginx-route-helm-demo.apps-crc.testing
curl: (6) Could not resolve host: my-nginx-route-helm-demo.apps-crc.testing

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get route my-nginx-route -n helm-demo --template='{{.spec.host}}{{"\n"}}'
curl -I "http://$(oc get route my-nginx-route -n helm-demo --template='{{.spec.host}}')"
my-nginx-route-helm-demo.apps-crc.testing
HTTP/1.1 200 OK
server: nginx
date: Sat, 13 Dec 2025 09:20:37 GMT
content-type: text/html
content-length: 615
last-modified: Wed, 10 Dec 2025 13:05:16 GMT
etag: "6939700c-267"
x-frame-options: SAMEORIGIN
accept-ranges: bytes
set-cookie: 00ceaf67ff1de946a67f83c17a3bb91b=612dbaa35d428b568f6b8c6eee532402; path=/; HttpOnly
cache-control: private


HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ sed -n '1,200p' labs/level-1-helm-user/lab11-upgrade-rollback-release.md
helm history my-nginx -n helm-demo
helm get values my-nginx -n helm-demo -o yaml
_Titre: Lab 11: Upgrade et Rollback d'une Release Helm_

## Objectif

Mettre à jour une release Helm existante avec de nouvelles configurations et revenir à une version précédente en cas de problème.

## Contexte

La gestion du cycle de vie des applications est une fonctionnalité clé de Helm. Après avoir déployé une application, il est courant de devoir la mettre à jour pour changer sa version, sa configuration, ou ses ressources. Helm facilite ces opérations avec les commandes `helm upgrade` et `helm rollback`.

## Étapes

### 1. Prérequis

Assurez-vous d'avoir complété le **Lab 10** et d'avoir la release `my-nginx` déployée dans le projet `helm-demo`.

### 2. Mettre à jour la release (Upgrade)

Nous allons mettre à jour la release `my-nginx` pour utiliser une image NGINX différente et augmenter le nombre de réplicas. Pour voir les options configurables, vous pouvez inspecter le `values.yaml` du chart :

```bash
helm show values bitnami/nginx
```

Mettez à jour la release en passant de nouvelles valeurs avec l'option `--set` :

```bash
helm upgrade my-nginx bitnami/nginx --namespace helm-demo \
  --set image.tag=1.23.3-debian-11-r0 \
  --set replicaCount=2
```

### 3. Vérifier l'historique des révisions

Chaque `upgrade` crée une nouvelle révision de la release. Vous pouvez lister les révisions :

```bash
helm history my-nginx --namespace helm-demo
```

Vous devriez voir deux révisions. La révision 2 est la version actuellement déployée.

### 4. Revenir à la version précédente (Rollback)

Imaginons que la nouvelle version introduise un bug. Nous pouvons facilement revenir à la révision précédente (la révision 1) :

```bash
helm rollback my-nginx 1 --namespace helm-demo
```

## Vérifications

*   **Après l'upgrade** :

    Vérifiez que le nombre de Pods est passé à 2 :

    ```bash
    oc get pods --namespace helm-demo
    ```

    Vérifiez que la nouvelle image est utilisée en inspectant un des Pods :

    ```bash
    oc describe pod/my-nginx-xxxx --namespace helm-demo | grep "Image:"
    ```

*   **Après le rollback** :

    Vérifiez que le nombre de Pods est revenu à 1 :

    ```bash
    oc get pods --namespace helm-demo
    ```

    Vérifiez que l'image d'origine est de nouveau utilisée.

## Nettoyage

Supprimez la release et le projet :

```bash
helm uninstall my-nginx --namespace helm-demo
oc delete project helm-demo
```
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sat Dec 13 10:17:00 2025        deployed        nginx-22.3.8    1.29.4          Install complete
null

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm upgrade my-nginx bitnami/nginx -n helm-demo --set image.tag=1.23.3-debian-11-r0 --set replicaCount=2
oc rollout status deploy/my-nginx -n helm-demo --timeout=180s
helm history my-nginx -n helm-demo
oc get pods -n helm-demo
oc get pods -n helm-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
Release "my-nginx" has been upgraded. Happy Helming!
NAME: my-nginx
LAST DEPLOYED: Sat Dec 13 10:52:20 2025
NAMESPACE: helm-demo
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 22.3.8
APP VERSION: 1.29.4

⚠ WARNING: Since August 28th, 2025, only a limited subset of images/charts are available for free.
    Subscribe to Bitnami Secure Images to receive continued support and security updates.
    More info at https://bitnami.com and https://github.com/bitnami/containers/issues/83267

** Please be patient while the chart is being deployed **
NGINX can be accessed through the following DNS name from within your cluster:

    my-nginx.helm-demo.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace helm-demo -w my-nginx'

    export SERVICE_PORT=$(kubectl get --namespace helm-demo -o jsonpath="{.spec.ports[0].port}" services my-nginx)
    export SERVICE_IP=$(kubectl get svc --namespace helm-demo my-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
WARNING: Rolling tag detected (bitnami/git:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html
WARNING: Rolling tag detected (bitnami/nginx-exporter:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - cloneStaticSiteFromGit.gitSync.resources
  - resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

⚠ SECURITY WARNING: Original containers have been substituted. This Helm chart was designed, tested, and validated on multiple platforms using a specific set of Bitnami and Tanzu Application Catalog containers. Substituting other containers is likely to cause degraded security and performance, broken chart features, and missing environment variables.

Substituted images detected:
  - registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0

⚠ WARNING: Original containers have been retagged. Please note this Helm chart was tested, and validated on multiple platforms using a specific set of Bitnami and Bitnami Secure Images containers. Substituting original image tags could cause unexpected behavior.

Retagged images:
  - registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0
Waiting for deployment "my-nginx" rollout to finish: 1 out of 2 new replicas have been updated...
Waiting for deployment "my-nginx" rollout to finish: 1 out of 2 new replicas have been updated...
error: timed out waiting for the condition
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sat Dec 13 10:17:00 2025        superseded      nginx-22.3.8    1.29.4          Install complete
2               Sat Dec 13 10:52:20 2025        deployed        nginx-22.3.8    1.29.4          Upgrade complete
NAME                        READY   STATUS                  RESTARTS   AGE
my-nginx-68cb5696b6-r8r89   0/1     Init:ImagePullBackOff   0          3m3s
my-nginx-797874586-7cdrp    1/1     Running                 0          3m3s
my-nginx-797874586-zp7pk    1/1     Running                 0          38m
my-nginx-68cb5696b6-r8r89       registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0
my-nginx-797874586-7cdrp        registry-1.docker.io/bitnami/nginx:latest
my-nginx-797874586-zp7pk        registry-1.docker.io/bitnami/nginx:latest

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc describe pod my-nginx-68cb5696b6-r8r89 -n helm-demo | sed -n '/Init Containers:/,/Events:/p'
oc describe pod my-nginx-68cb5696b6-r8r89 -n helm-demo | sed -n '/Events:/,$p'
oc get pod my-nginx-68cb5696b6-r8r89 -n helm-demo -o jsonpath='{.spec.initContainers[*].name}{" => "}{.spec.initContainers[*].image}{"\n"}{.spec.containers[*].name}{" => "}{.spec.containers[*].image}{"\n"}'
Init Containers:
  preserve-logs-symlinks:
    Container ID:
    Image:           registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0
    Image ID:
    Port:            <none>
    Host Port:       <none>
    SeccompProfile:  RuntimeDefault
    Command:
      /bin/bash
    Args:
      -ec
      #!/bin/bash
      . /opt/bitnami/scripts/libfs.sh
      # We copy the logs folder because it has symlinks to stdout and stderr
      if ! is_dir_empty /opt/bitnami/nginx/logs; then
        cp -r /opt/bitnami/nginx/logs /emptydir/app-logs-dir
      fi

    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Limits:
      cpu:                150m
      ephemeral-storage:  2Gi
      memory:             192Mi
    Requests:
      cpu:                100m
      ephemeral-storage:  50Mi
      memory:             128Mi
    Environment:
      OPENSSL_FIPS:  yes
    Mounts:
      /emptydir from empty-dir (rw)
Containers:
  nginx:
    Container ID:
    Image:           registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0
    Image ID:
    Ports:           8080/TCP, 8443/TCP
    Host Ports:      0/TCP, 0/TCP
    SeccompProfile:  RuntimeDefault
    State:           Waiting
      Reason:        PodInitializing
    Ready:           False
    Restart Count:   0
    Limits:
      cpu:                150m
      ephemeral-storage:  2Gi
      memory:             192Mi
    Requests:
      cpu:                100m
      ephemeral-storage:  50Mi
      memory:             128Mi
    Liveness:             tcp-socket :http delay=30s timeout=5s period=10s #success=1 #failure=6
    Readiness:            http-get http://:http/ delay=5s timeout=3s period=5s #success=1 #failure=3
    Environment:
      BITNAMI_DEBUG:            false
      NGINX_HTTP_PORT_NUMBER:   8080
      OPENSSL_FIPS:             yes
      NGINX_HTTPS_PORT_NUMBER:  8443
    Mounts:
      /certs from certificate (rw)
      /opt/bitnami/nginx/conf from empty-dir (rw,path="app-conf-dir")
      /opt/bitnami/nginx/logs from empty-dir (rw,path="app-logs-dir")
      /opt/bitnami/nginx/tmp from empty-dir (rw,path="app-tmp-dir")
      /tmp from empty-dir (rw,path="tmp-dir")
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 False
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  empty-dir:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  certificate:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  my-nginx-tls
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
Events:
  Type     Reason          Age                    From               Message
  ----     ------          ----                   ----               -------
  Normal   Scheduled       32m                    default-scheduler  Successfully assigned helm-demo/my-nginx-68cb5696b6-r8r89 to crc
  Normal   AddedInterface  32m                    multus             Add eth0 [10.217.0.104/23] from ovn-kubernetes
  Normal   Pulling         29m (x5 over 32m)      kubelet            Pulling image "registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0"
  Warning  Failed          29m (x5 over 32m)      kubelet            Failed to pull image "registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0": initializing source docker://registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0: reading manifest 1.23.3-debian-11-r0 in registry-1.docker.io/bitnami/nginx: manifest unknown
  Warning  Failed          29m (x5 over 32m)      kubelet            Error: ErrImagePull
  Normal   BackOff         7m42s (x108 over 32m)  kubelet            Back-off pulling image "registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0"
  Warning  Failed          7m42s (x108 over 32m)  kubelet            Error: ImagePullBackOff
preserve-logs-symlinks => registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0
nginx => registry-1.docker.io/bitnami/nginx:1.23.3-debian-11-r0

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm rollback my-nginx 1 -n helm-demo
oc rollout status deploy/my-nginx -n helm-demo --timeout=180s
helm history my-nginx -n helm-demo
oc get pods -n helm-demo
Rollback was a success! Happy Helming!
deployment "my-nginx" successfully rolled out
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sat Dec 13 10:17:00 2025        superseded      nginx-22.3.8    1.29.4          Install complete
2               Sat Dec 13 10:52:20 2025        superseded      nginx-22.3.8    1.29.4          Upgrade complete
3               Sat Dec 13 11:30:58 2025        deployed        nginx-22.3.8    1.29.4          Rollback to 1
NAME                       READY   STATUS    RESTARTS   AGE
my-nginx-797874586-7cdrp   1/1     Running   0          38m

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm upgrade my-nginx bitnami/nginx -n helm-demo --reuse-values --set replicaCount=2
oc rollout status deploy/my-nginx -n helm-demo --timeout=180s
oc get pods -n helm-demo
helm history my-nginx -n helm-demo
Release "my-nginx" has been upgraded. Happy Helming!
NAME: my-nginx
LAST DEPLOYED: Sat Dec 13 11:58:51 2025
NAMESPACE: helm-demo
STATUS: deployed
REVISION: 4
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 22.3.8
APP VERSION: 1.29.4

⚠ WARNING: Since August 28th, 2025, only a limited subset of images/charts are available for free.
    Subscribe to Bitnami Secure Images to receive continued support and security updates.
    More info at https://bitnami.com and https://github.com/bitnami/containers/issues/83267

** Please be patient while the chart is being deployed **
NGINX can be accessed through the following DNS name from within your cluster:

    my-nginx.helm-demo.svc.cluster.local (port 80)

To access NGINX from outside the cluster, follow the steps below:

1. Get the NGINX URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace helm-demo -w my-nginx'

    export SERVICE_PORT=$(kubectl get --namespace helm-demo -o jsonpath="{.spec.ports[0].port}" services my-nginx)
    export SERVICE_IP=$(kubectl get svc --namespace helm-demo my-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "http://${SERVICE_IP}:${SERVICE_PORT}"
WARNING: Rolling tag detected (bitnami/nginx:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html
WARNING: Rolling tag detected (bitnami/git:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html
WARNING: Rolling tag detected (bitnami/nginx-exporter:latest), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://techdocs.broadcom.com/us/en/vmware-tanzu/application-catalog/tanzu-application-catalog/services/tac-doc/apps-tutorials-understand-rolling-tags-containers-index.html

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - cloneStaticSiteFromGit.gitSync.resources
  - resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
Waiting for deployment "my-nginx" rollout to finish: 1 of 2 updated replicas are available...
deployment "my-nginx" successfully rolled out
NAME                       READY   STATUS    RESTARTS   AGE
my-nginx-797874586-28khw   1/1     Running   0          11s
my-nginx-797874586-7cdrp   1/1     Running   0          66m
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Sat Dec 13 10:17:00 2025        superseded      nginx-22.3.8    1.29.4          Install complete
2               Sat Dec 13 10:52:20 2025        superseded      nginx-22.3.8    1.29.4          Upgrade complete
3               Sat Dec 13 11:30:58 2025        superseded      nginx-22.3.8    1.29.4          Rollback to 1
4               Sat Dec 13 11:58:51 2025        deployed        nginx-22.3.8    1.29.4          Upgrade complete

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ ls -1 labs/level-2-template-dev
sed -n '1,220p' labs/level-2-template-dev/lab20*.md
ls -1 charts/myapp-ocp
lab20-creer-chart-myapp-ocp.md
lab21-route-et-securitycontext.md
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
Chart.yaml
templates/
values.schema.json
values.yaml

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc new-project myapp-dev
ls -1 charts/myapp-ocp/templates
sed -n '1,200p' charts/myapp-ocp/values.yaml
Now using project "myapp-dev" on server "https://api.crc.testing:6443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.43 -- /agnhost serve-hostname

_helpers.tpl
configmap.yaml
deployment.yaml
route.yaml
service.yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21.0"

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

route:
  enabled: true
  host: myapp.apps.crc.testing

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

securityContext:
  runAsUser: 1001
  runAsGroup: 1001
  fsGroup: 1001

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm lint charts/myapp-ocp
helm install myapp charts/myapp-ocp -n myapp-dev
oc get all,route -n myapp-dev
==> Linting charts/myapp-ocp
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
W1213 14:50:14.910451    1748 warnings.go:70] would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "myapp-ocp" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "myapp-ocp" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "myapp-ocp" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "myapp-ocp" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
NAME: myapp
LAST DEPLOYED: Sat Dec 13 14:50:14 2025
NAMESPACE: myapp-dev
STATUS: deployed
REVISION: 1
TEST SUITE: None
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/myapp-myapp-ocp   ClusterIP   10.217.4.153   <none>        80/TCP    2s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myapp-myapp-ocp   0/1     0            0           2s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/myapp-myapp-ocp-69f56654fc   1         0         0       2s

NAME                                       HOST/PORT                PATH   SERVICES          PORT   TERMINATION   WILDCARD
route.route.openshift.io/myapp-myapp-ocp   myapp.apps.crc.testing          myapp-myapp-ocp   http                 None

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get pods -n myapp-dev -o wide
oc get events -n myapp-dev --sort-by=.lastTimestamp | tail -n 40
No resources found in myapp-dev namespace.
LAST SEEN   TYPE      REASON              OBJECT                                  MESSAGE
135m        Normal    ScalingReplicaSet   deployment/myapp-myapp-ocp              Scaled up replica set myapp-myapp-ocp-69f56654fc from 0 to 1
5m39s       Warning   FailedCreate        replicaset/myapp-myapp-ocp-69f56654fc   Error creating: pods "myapp-myapp-ocp-69f56654fc-" is forbidden: unable to validate against any security context constraint: [provider "anyuid": Forbidden: not usable by user or serviceaccount, provider restricted-v2: .spec.securityContext.fsGroup: Invalid value: []int64{1001}: 1001 is not an allowed group, provider restricted-v2: .containers[0].runAsUser: Invalid value: 1001: must be in the ranges: [1000690000, 1000699999], provider "restricted": Forbidden: not usable by user or serviceaccount, provider "nonroot-v2": Forbidden: not usable by user or serviceaccount, provider "nonroot": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid-v2": Forbidden: not usable by user or serviceaccount, provider "machine-api-termination-handler": Forbidden: not usable by user or serviceaccount, provider "hostnetwork-v2": Forbidden: not usable by user or serviceaccount, provider "hostnetwork": Forbidden: not usable by user or serviceaccount, provider "hostaccess": Forbidden: not usable by user or serviceaccount, provider "hostpath-provisioner": Forbidden: not usable by user or serviceaccount, provider "node-exporter": Forbidden: not usable by user or serviceaccount, provider "privileged": Forbidden: not usable by user or serviceaccount]

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get ns myapp-dev -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}{"\n"}{.metadata.annotations.openshift\.io/sa\.scc\.supplemental-groups}{"\n"}'
sed -n '1,220p' charts/myapp-ocp/templates/deployment.yaml
sed -n '1,120p' charts/myapp-ocp/values.yaml
1000690000/10000
1000690000/10000
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp-ocp.fullname" . }}
  labels:
    {{- include "myapp-ocp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp-ocp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp-ocp.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: {{ .Values.service.targetPort }}
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21.0"

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

route:
  enabled: true
  host: myapp.apps.crc.testing

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

securityContext:
  runAsUser: 1001
  runAsGroup: 1001
  fsGroup: 1001

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm upgrade myapp charts/myapp-ocp -n myapp-dev
oc rollout status deploy/myapp-myapp-ocp -n myapp-dev --timeout=180s
oc get pods -n myapp-dev -o wide
Release "myapp" has been upgraded. Happy Helming!
NAME: myapp
LAST DEPLOYED: Sat Dec 13 17:26:42 2025
NAMESPACE: myapp-dev
STATUS: deployed
REVISION: 2
TEST SUITE: None
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 0 of 1 updated replicas are available...
error: timed out waiting for the condition
NAME                               READY   STATUS              RESTARTS   AGE    IP       NODE   NOMINATED NODE   READINESS GATES
myapp-myapp-ocp-6848d559b4-lv7zj   0/1     ContainerCreating   0          3m2s   <none>   crc    <none>           <none>

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc describe pod myapp-myapp-ocp-6848d559b4-lv7zj -n myapp-dev | sed -n '/Events:/,$p'
oc get pod myapp-myapp-ocp-6848d559b4-lv7zj -n myapp-dev -o jsonpath='{.spec.containers[0].image}{"\n"}{.status.containerStatuses[0].state}{"\n"}'
oc get events -n myapp-dev --sort-by=.lastTimestamp | tail -n 40
Events:
  Type     Reason                  Age    From               Message
  ----     ------                  ----   ----               -------
  Normal   Scheduled               4m22s  default-scheduler  Successfully assigned myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj to crc
  Warning  FailedCreatePodSandBox  4m20s  kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e" Netns:"/var/run/netns/0b585b66-dddd-4d3b-a2af-b16cc639891a" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  4m16s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb" Netns:"/var/run/netns/a3741111-9238-4132-a7c9-78b9efd61c24" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  4m3s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545" Netns:"/var/run/netns/41197f1d-4c75-4e1b-a72d-c955b83c17b5" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  3m48s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba" Netns:"/var/run/netns/14f5f355-b76b-430d-ad47-48df1adec898" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  3m31s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c" Netns:"/var/run/netns/39451ab2-5650-4df8-9675-eac6bb6fb4b0" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  3m14s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb" Netns:"/var/run/netns/f7e54e31-933f-4d2a-a651-0e1af9219313" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  2m57s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5" Netns:"/var/run/netns/407ecc96-9157-40b8-803a-c4dc929ebcbe" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  2m41s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba" Netns:"/var/run/netns/363b613f-fbad-401a-ae94-35ae92024f9b" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  2m27s  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402" Netns:"/var/run/netns/9ee411f8-e6c9-43a0-9f93-4b804678bee2" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
  Warning  FailedCreatePodSandBox  4s (x9 over 2m11s)  kubelet  (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660" Netns:"/var/run/netns/0a183290-8a33-4dae-ad23-c1a8a5418c89" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized
': StdinData: {"auxiliaryCNIChainName":"vendor-cni-chain","binDir":"/var/lib/cni/bin","clusterNetwork":"/host/run/multus/cni/net.d/10-ovn-kubernetes.conf","cniVersion":"0.3.1","daemonSocketDir":"/run/multus/socket","globalNamespaces":"default,openshift-multus,openshift-sriov-network-operator,openshift-cnv","logLevel":"verbose","logToStderr":true,"name":"multus-cni-network","namespaceIsolation":true,"type":"multus-shim"}
nginx:1.21.0
{"waiting":{"reason":"ContainerCreating"}}
LAST SEEN   TYPE      REASON                   OBJECT                                  MESSAGE
4m24s       Normal    Scheduled                pod/myapp-myapp-ocp-6848d559b4-lv7zj    Successfully assigned myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj to crc
160m        Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled up replica set myapp-myapp-ocp-69f56654fc from 0 to 1
4m25s       Normal    SuccessfulCreate         replicaset/myapp-myapp-ocp-6848d559b4   Created pod: myapp-myapp-ocp-6848d559b4-lv7zj
4m25s       Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled up replica set myapp-myapp-ocp-6848d559b4 from 0 to 1
4m22s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e" Netns:"/var/run/netns/0b585b66-dddd-4d3b-a2af-b16cc639891a" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
4m18s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb" Netns:"/var/run/netns/a3741111-9238-4132-a7c9-78b9efd61c24" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
4m5s        Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545" Netns:"/var/run/netns/41197f1d-4c75-4e1b-a72d-c955b83c17b5" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
4m1s        Warning   FailedCreate             replicaset/myapp-myapp-ocp-69f56654fc   Error creating: pods "myapp-myapp-ocp-69f56654fc-" is forbidden: unable to validate against any security context constraint: [provider "anyuid": Forbidden: not usable by user or serviceaccount, provider restricted-v2: .spec.securityContext.fsGroup: Invalid value: []int64{1001}: 1001 is not an allowed group, provider restricted-v2: .containers[0].runAsUser: Invalid value: 1001: must be in the ranges: [1000690000, 1000699999], provider "restricted": Forbidden: not usable by user or serviceaccount, provider "nonroot-v2": Forbidden: not usable by user or serviceaccount, provider "nonroot": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid-v2": Forbidden: not usable by user or serviceaccount, provider "machine-api-termination-handler": Forbidden: not usable by user or serviceaccount, provider "hostnetwork-v2": Forbidden: not usable by user or serviceaccount, provider "hostnetwork": Forbidden: not usable by user or serviceaccount, provider "hostaccess": Forbidden: not usable by user or serviceaccount, provider "hostpath-provisioner": Forbidden: not usable by user or serviceaccount, provider "node-exporter": Forbidden: not usable by user or serviceaccount, provider "privileged": Forbidden: not usable by user or serviceaccount]
3m50s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba" Netns:"/var/run/netns/14f5f355-b76b-430d-ad47-48df1adec898" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
3m33s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c" Netns:"/var/run/netns/39451ab2-5650-4df8-9675-eac6bb6fb4b0" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
3m16s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb" Netns:"/var/run/netns/f7e54e31-933f-4d2a-a651-0e1af9219313" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
2m59s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5" Netns:"/var/run/netns/407ecc96-9157-40b8-803a-c4dc929ebcbe" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
2m43s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba" Netns:"/var/run/netns/363b613f-fbad-401a-ae94-35ae92024f9b" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
2m29s       Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402" Netns:"/var/run/netns/9ee411f8-e6c9-43a0-9f93-4b804678bee2" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
6s          Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660" Netns:"/var/run/netns/0a183290-8a33-4dae-ad23-c1a8a5418c89" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=42adcba11f00759c28a6a416da944f3ee5749ca72e85890437ed31258e61f660;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get co network
oc get pods -n openshift-multus -o wide
oc get pods -n openshift-ovn-kubernetes -o wide | head
NAME      VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
network   4.19.3    True        False         False      156d
NAME                                          READY   STATUS    RESTARTS   AGE     IP               NODE   NOMINATED NODE   READINESS GATES
multus-additional-cni-plugins-d4v4f           1/1     Running   0          6d21h   192.168.126.11   crc    <none>           <none>
multus-admission-controller-b8b6f8fb9-55pxb   2/2     Running   0          6d21h   10.217.0.42      crc    <none>           <none>
multus-kdzjh                                  1/1     Running   0          6d21h   192.168.126.11   crc    <none>           <none>
network-metrics-daemon-szq44                  2/2     Running   0          6d21h   10.217.0.3       crc    <none>           <none>
NAME                                     READY   STATUS    RESTARTS     AGE     IP               NODE   NOMINATED NODE   READINESS GATES
ovnkube-control-plane-5988777d5b-wwdfm   2/2     Running   0            6d21h   192.168.126.11   crc    <none>           <none>
ovnkube-node-8r6mk                       8/8     Running   7 (8h ago)   6d21h   192.168.126.11   crc    <none>           <none>

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get ds -n openshift-multus
oc -n openshift-multus rollout restart ds/multus
oc -n openshift-multus rollout status ds/multus --timeout=180s
NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
multus                          1         1         1       1            1           kubernetes.io/os=linux   156d
multus-additional-cni-plugins   1         1         1       1            1           kubernetes.io/os=linux   156d
network-metrics-daemon          1         1         1       1            1           kubernetes.io/os=linux   156d
daemonset.apps/multus restarted
Waiting for daemon set "multus" rollout to finish: 0 out of 1 new pods have been updated...
Waiting for daemon set "multus" rollout to finish: 0 out of 1 new pods have been updated...
Waiting for daemon set "multus" rollout to finish: 0 of 1 updated pods are available...
daemon set "multus" successfully rolled out

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc delete pod -n myapp-dev -l app.kubernetes.io/instance=myapp
oc rollout status deploy/myapp-myapp-ocp -n myapp-dev --timeout=180s
oc get pods -n myapp-dev -o wide
pod "myapp-myapp-ocp-6848d559b4-lv7zj" deleted
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 0 of 1 updated replicas are available...
error: timed out waiting for the condition
NAME                               READY   STATUS             RESTARTS      AGE    IP             NODE   NOMINATED NODE   READINESS GATES
myapp-myapp-ocp-6848d559b4-bsnfs   0/1     CrashLoopBackOff   4 (82s ago)   3m4s   10.217.0.202   crc    <none>           <none>

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc logs pod/myapp-myapp-ocp-6848d559b4-bsnfs -n myapp-dev -c myapp-ocp --previous --tail=120
oc logs pod/myapp-myapp-ocp-6848d559b4-bsnfs -n myapp-dev -c myapp-ocp --tail=60
oc describe pod myapp-myapp-ocp-6848d559b4-bsnfs -n myapp-dev | sed -n '/Events:/,$p'
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/12/13 16:40:20 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
2025/12/13 16:40:20 [emerg] 1#1: mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/12/13 16:40:20 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
2025/12/13 16:40:20 [emerg] 1#1: mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
Events:
  Type     Reason          Age                   From               Message
  ----     ------          ----                  ----               -------
  Normal   Scheduled       4m13s                 default-scheduler  Successfully assigned myapp-dev/myapp-myapp-ocp-6848d559b4-bsnfs to crc
  Normal   AddedInterface  4m13s                 multus             Add eth0 [10.217.0.202/23] from ovn-kubernetes
  Normal   Pulled          70s (x6 over 4m13s)   kubelet            Container image "nginx:1.21.0" already present on machine
  Normal   Created         70s (x6 over 4m13s)   kubelet            Created container: myapp-ocp
  Normal   Started         70s (x6 over 4m13s)   kubelet            Started container myapp-ocp
  Warning  BackOff         49s (x25 over 4m11s)  kubelet            Back-off restarting failed container myapp-ocp in pod myapp-myapp-ocp-6848d559b4-bsnfs_myapp-dev(65d3b909-4d1f-4b8a-bd9d-bc5cf05863db)

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ cat > charts/myapp-ocp/templates/configmap.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp-ocp.fullname" . }}-nginx-conf
  labels:
    {{- include "myapp-ocp.labels" . | nindent 4 }}
data:
  default.conf: |
    server {
      listen {{ .Values.service.targetPort }};
      listen [::]:{{ .Values.service.targetPort }};
      server_name _;
      location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
      }
    }
EOF

cat > charts/myapp-ocp/templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp-ocp.fullname" . }}
  labels:
    {{- include "myapp-ocp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp-ocp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp-ocp.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        seccompProfile:
oc get pods -n myapp-dev -o wideyapp-ocp -n myapp-dev --timeout=180sg }}"
Release "myapp" has been upgraded. Happy Helming!
NAME: myapp
LAST DEPLOYED: Sat Dec 13 17:47:28 2025
NAMESPACE: myapp-dev
STATUS: deployed
REVISION: 3
TEST SUITE: None
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 1 old replicas are pending termination...
deployment "myapp-myapp-ocp" successfully rolled out
NAME                               READY   STATUS    RESTARTS   AGE   IP             NODE   NOMINATED NODE   READINESS GATES
myapp-myapp-ocp-77c69d99b9-vvb52   1/1     Running   0          9s    10.217.0.208   crc    <none>           <none>

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get all,route -n myapp-dev
oc get route myapp-myapp-ocp -n myapp-dev --template='{{.spec.host}}{{"\n"}}'
curl -I "http://$(oc get route myapp-myapp-ocp -n myapp-dev --template='{{.spec.host}}')"
oc logs deploy/myapp-myapp-ocp -n myapp-dev --tail=40
Warning: apps.openshift.io/v1 DeploymentConfig is deprecated in v4.14+, unavailable in v4.10000+
NAME                                   READY   STATUS    RESTARTS   AGE
pod/myapp-myapp-ocp-77c69d99b9-vvb52   1/1     Running   0          2m7s

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/myapp-myapp-ocp   ClusterIP   10.217.4.153   <none>        80/TCP    179m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myapp-myapp-ocp   1/1     1            1           179m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/myapp-myapp-ocp-6848d559b4   0         0         0       22m
replicaset.apps/myapp-myapp-ocp-69f56654fc   0         0         0       179m
replicaset.apps/myapp-myapp-ocp-77c69d99b9   1         1         1       2m7s

NAME                                       HOST/PORT                PATH   SERVICES          PORT   TERMINATION   WILDCARD
route.route.openshift.io/myapp-myapp-ocp   myapp.apps.crc.testing          myapp-myapp-ocp   http                 None
myapp.apps.crc.testing
curl: (6) Could not resolve host: myapp.apps.crc.testing
2025/12/13 16:47:30 [notice] 1#1: start worker process 19
2025/12/13 16:47:30 [notice] 1#1: start worker process 20
2025/12/13 16:47:30 [notice] 1#1: start worker process 21
2025/12/13 16:47:30 [notice] 1#1: start worker process 22
2025/12/13 16:47:30 [notice] 1#1: start worker process 23
10.217.0.2 - - [13/Dec/2025:16:47:36 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:47:41 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:47:46 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:47:51 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:47:56 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:00 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:01 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:06 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:10 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:11 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:16 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:20 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:21 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:26 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:30 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:31 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:36 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:40 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:41 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:46 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:50 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:51 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:48:56 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:00 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:01 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:06 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:10 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:11 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:16 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:20 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:21 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:26 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:30 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:31 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"
10.217.0.2 - - [13/Dec/2025:16:49:36 +0000] "GET / HTTP/1.1" 200 612 "-" "kube-probe/1.32" "-"

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ curl -I "http://$(oc get route myapp-myapp-ocp -n myapp-dev --template='{{.spec.host}}')"
HTTP/1.1 200 OK
server: nginx/1.21.0
date: Sat, 13 Dec 2025 16:51:39 GMT
content-type: text/html
content-length: 612
last-modified: Tue, 25 May 2021 12:28:56 GMT
etag: "60aced88-264"
accept-ranges: bytes
set-cookie: 52b281bfd254e8503daa012468efd4bb=8665dcdf3530e5e69b82b4ad14d0e811; path=/; HttpOnly
cache-control: private


HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ # PowerShell en admin
crc ip
127.0.0.1

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$  curl -I "http://$(oc get route myapp-myapp-ocp -n myapp-dev --template='{{.spec.host}}')"
HTTP/1.1 200 OK
server: nginx/1.21.0
date: Sat, 13 Dec 2025 17:01:19 GMT
content-type: text/html
content-length: 612
last-modified: Tue, 25 May 2021 12:28:56 GMT
etag: "60aced88-264"
accept-ranges: bytes
set-cookie: 52b281bfd254e8503daa012468efd4bb=8665dcdf3530e5e69b82b4ad14d0e811; path=/; HttpOnly
cache-control: private


HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ ping myapp.apps.crc.testing
curl -I http://myapp.apps.crc.testing

Envoi d’une requête 'ping' sur myapp.apps.crc.testing [127.0.0.1] avec 32 octets de données :
Réponse de 127.0.0.1 : octets=32 temps<1ms TTL=128
Réponse de 127.0.0.1 : octets=32 temps<1ms TTL=128
Réponse de 127.0.0.1 : octets=32 temps<1ms TTL=128
Réponse de 127.0.0.1 : octets=32 temps<1ms TTL=128

Statistiques Ping pour 127.0.0.1:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
HTTP/1.1 200 OK
server: nginx/1.21.0
date: Sat, 13 Dec 2025 17:01:35 GMT
content-type: text/html
content-length: 612
last-modified: Tue, 25 May 2021 12:28:56 GMT
etag: "60aced88-264"
accept-ranges: bytes
set-cookie: 52b281bfd254e8503daa012468efd4bb=8665dcdf3530e5e69b82b4ad14d0e811; path=/; HttpOnly
cache-control: private



HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ helm upgrade myapp charts/myapp-ocp -n myapp-dev --set replicaCount=2
oc rollout status deploy/myapp-myapp-ocp -n myapp-dev --timeout=180s
oc get pods -n myapp-dev -o wide
Release "myapp" has been upgraded. Happy Helming!
NAME: myapp
LAST DEPLOYED: Sat Dec 13 18:20:10 2025
NAMESPACE: myapp-dev
STATUS: deployed
REVISION: 4
TEST SUITE: None
Waiting for deployment "myapp-myapp-ocp" rollout to finish: 1 of 2 updated replicas are available...
deployment "myapp-myapp-ocp" successfully rolled out
NAME                               READY   STATUS    RESTARTS   AGE   IP             NODE   NOMINATED NODE   READINESS GATES
myapp-myapp-ocp-77c69d99b9-dth4v   1/1     Running   0          10s   10.217.0.222   crc    <none>           <none>
myapp-myapp-ocp-77c69d99b9-vvb52   1/1     Running   0          32m   10.217.0.208   crc    <none>           <none>

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ # 1) Vérif “zéro warning” côté namespace
oc get events -n myapp-dev --sort-by=.lastTimestamp | tail -n 40

# 2) Vérifier que le Pod tourne bien en UID random OpenShift (pas 0, pas 1001 fixé)
POD=$(oc get pod -n myapp-dev -l app.kubernetes.io/instance=myapp -o jsonpath='{.items[0].metadata.name}')
oc exec -n myapp-dev "$POD" -- id

# 3) Vérifier que les securityContext “restricted” sont bien présents sur le conteneur
oc get pod -n myapp-dev "$POD" -o jsonpath='{.spec.securityContext.seccompProfile.type}{"\n"}{.spec.containers[0].securityContext}{"\n"}'

# 4) Vérifier accès Route (depuis Windows)
curl -I http://myapp.apps.crc.testing
59m         Normal    SuccessfulCreate         replicaset/myapp-myapp-ocp-6848d559b4   Created pod: myapp-myapp-ocp-6848d559b4-lv7zj
59m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e" Netns:"/var/run/netns/0b585b66-dddd-4d3b-a2af-b16cc639891a" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
59m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb" Netns:"/var/run/netns/a3741111-9238-4132-a7c9-78b9efd61c24" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
59m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545" Netns:"/var/run/netns/41197f1d-4c75-4e1b-a72d-c955b83c17b5" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
59m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba" Netns:"/var/run/netns/14f5f355-b76b-430d-ad47-48df1adec898" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
58m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c" Netns:"/var/run/netns/39451ab2-5650-4df8-9675-eac6bb6fb4b0" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
58m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb" Netns:"/var/run/netns/f7e54e31-933f-4d2a-a651-0e1af9219313" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
58m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5" Netns:"/var/run/netns/407ecc96-9157-40b8-803a-c4dc929ebcbe" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
58m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba" Netns:"/var/run/netns/363b613f-fbad-401a-ae94-35ae92024f9b" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
57m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402" Netns:"/var/run/netns/9ee411f8-e6c9-43a0-9f93-4b804678bee2" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
53m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483" Netns:"/var/run/netns/4b38641e-d81d-4548-b673-bec763daabeb" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
51m         Normal    Pulling                  pod/myapp-myapp-ocp-6848d559b4-lv7zj    Pulling image "nginx:1.21.0"
51m         Normal    AddedInterface           pod/myapp-myapp-ocp-6848d559b4-lv7zj    Add eth0 [10.217.0.196/23] from ovn-kubernetes
50m         Normal    Pulled                   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Successfully pulled image "nginx:1.21.0" in 43.922s (43.922s including waiting). Image size: 137367999 bytes.
49m         Warning   BackOff                  pod/myapp-myapp-ocp-6848d559b4-lv7zj    Back-off restarting failed container myapp-ocp in pod myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev(f2a884f4-604b-4194-9938-5997bfea89eb)
49m         Normal    Created                  pod/myapp-myapp-ocp-6848d559b4-lv7zj    Created container: myapp-ocp
49m         Normal    Started                  pod/myapp-myapp-ocp-6848d559b4-lv7zj    Started container myapp-ocp
49m         Normal    Pulled                   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Container image "nginx:1.21.0" already present on machine
49m         Normal    SuccessfulCreate         replicaset/myapp-myapp-ocp-6848d559b4   Created pod: myapp-myapp-ocp-6848d559b4-bsnfs
49m         Normal    AddedInterface           pod/myapp-myapp-ocp-6848d559b4-bsnfs    Add eth0 [10.217.0.202/23] from ovn-kubernetes
43m         Normal    Created                  pod/myapp-myapp-ocp-6848d559b4-bsnfs    Created container: myapp-ocp
43m         Normal    Started                  pod/myapp-myapp-ocp-6848d559b4-bsnfs    Started container myapp-ocp
43m         Normal    Pulled                   pod/myapp-myapp-ocp-6848d559b4-bsnfs    Container image "nginx:1.21.0" already present on machine
39m         Warning   FailedCreate             replicaset/myapp-myapp-ocp-69f56654fc   Error creating: pods "myapp-myapp-ocp-69f56654fc-" is forbidden: unable to validate against any security context constraint: [provider "anyuid": Forbidden: not usable by user or serviceaccount, provider restricted-v2: .spec.securityContext.fsGroup: Invalid value: []int64{1001}: 1001 is not an allowed group, provider restricted-v2: .containers[0].runAsUser: Invalid value: 1001: must be in the ranges: [1000690000, 1000699999], provider "restricted": Forbidden: not usable by user or serviceaccount, provider "nonroot-v2": Forbidden: not usable by user or serviceaccount, provider "nonroot": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid-v2": Forbidden: not usable by user or serviceaccount, provider "machine-api-termination-handler": Forbidden: not usable by user or serviceaccount, provider "hostnetwork-v2": Forbidden: not usable by user or serviceaccount, provider "hostnetwork": Forbidden: not usable by user or serviceaccount, provider "hostaccess": Forbidden: not usable by user or serviceaccount, provider "hostpath-provisioner": Forbidden: not usable by user or serviceaccount, provider "node-exporter": Forbidden: not usable by user or serviceaccount, provider "privileged": Forbidden: not usable by user or serviceaccount]
39m         Normal    SuccessfulCreate         replicaset/myapp-myapp-ocp-77c69d99b9   Created pod: myapp-myapp-ocp-77c69d99b9-vvb52
39m         Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled up replica set myapp-myapp-ocp-77c69d99b9 from 0 to 1
39m         Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled down replica set myapp-myapp-ocp-69f56654fc from 1 to 0
39m         Normal    Started                  pod/myapp-myapp-ocp-77c69d99b9-vvb52    Started container myapp-ocp
39m         Normal    AddedInterface           pod/myapp-myapp-ocp-77c69d99b9-vvb52    Add eth0 [10.217.0.208/23] from ovn-kubernetes
39m         Normal    Pulled                   pod/myapp-myapp-ocp-77c69d99b9-vvb52    Container image "nginx:1.21.0" already present on machine
39m         Normal    Created                  pod/myapp-myapp-ocp-77c69d99b9-vvb52    Created container: myapp-ocp
39m         Warning   BackOff                  pod/myapp-myapp-ocp-6848d559b4-bsnfs    Back-off restarting failed container myapp-ocp in pod myapp-myapp-ocp-6848d559b4-bsnfs_myapp-dev(65d3b909-4d1f-4b8a-bd9d-bc5cf05863db)
38m         Normal    SuccessfulDelete         replicaset/myapp-myapp-ocp-6848d559b4   Deleted pod: myapp-myapp-ocp-6848d559b4-bsnfs
38m         Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled down replica set myapp-myapp-ocp-6848d559b4 from 1 to 0
6m23s       Normal    SuccessfulCreate         replicaset/myapp-myapp-ocp-77c69d99b9   Created pod: myapp-myapp-ocp-77c69d99b9-dth4v
6m23s       Normal    ScalingReplicaSet        deployment/myapp-myapp-ocp              Scaled up replica set myapp-myapp-ocp-77c69d99b9 from 1 to 2
6m22s       Normal    AddedInterface           pod/myapp-myapp-ocp-77c69d99b9-dth4v    Add eth0 [10.217.0.222/23] from ovn-kubernetes
6m22s       Normal    Started                  pod/myapp-myapp-ocp-77c69d99b9-dth4v    Started container myapp-ocp
6m22s       Normal    Created                  pod/myapp-myapp-ocp-77c69d99b9-dth4v    Created container: myapp-ocp
6m22s       Normal    Pulled                   pod/myapp-myapp-ocp-77c69d99b9-dth4v    Container image "nginx:1.21.0" already present on machine
uid=1000690000(1000690000) gid=0(root) groups=0(root),1000690000
RuntimeDefault
{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true,"runAsUser":1000690000}
HTTP/1.1 200 OK
server: nginx/1.21.0
date: Sat, 13 Dec 2025 17:26:41 GMT
content-type: text/html
content-length: 612
last-modified: Tue, 25 May 2021 12:28:56 GMT
etag: "60aced88-264"
accept-ranges: bytes
set-cookie: 52b281bfd254e8503daa012468efd4bb=8665dcdf3530e5e69b82b4ad14d0e811; path=/; HttpOnly
cache-control: private


HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get events -n myapp-dev --field-selector type=Warning --sort-by=.lastTimestamp | tail -n 30
LAST SEEN   TYPE      REASON                   OBJECT                                  MESSAGE
62m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e" Netns:"/var/run/netns/0b585b66-dddd-4d3b-a2af-b16cc639891a" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=c7988a11e8006f7ee40a1e2b3172f5c3f18f4ece9b0509b6acd8efb8b5f0582e;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
62m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb" Netns:"/var/run/netns/a3741111-9238-4132-a7c9-78b9efd61c24" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=2602efb6351759c245cafe9596bee5cc4f77ffd0a6174d2bc2574c7e60ced5eb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
62m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545" Netns:"/var/run/netns/41197f1d-4c75-4e1b-a72d-c955b83c17b5" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=a86b07b6ba26e896255974bbedcabbe1acb2ad1355114b1ca797bc1a01618545;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
62m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba" Netns:"/var/run/netns/14f5f355-b76b-430d-ad47-48df1adec898" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=df87d2a6a5ec3e01cb67aee0e655c2a12e4724f5e6429ba4ea6521f20b8f64ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
61m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c" Netns:"/var/run/netns/39451ab2-5650-4df8-9675-eac6bb6fb4b0" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=3e8b3bb4cc6a2cc172af0cd38c7f8f95f0fb54eb9f89a8b4cb7706b10a5bdd9c;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
61m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb" Netns:"/var/run/netns/f7e54e31-933f-4d2a-a651-0e1af9219313" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=e2f8c6332bfceb93cebb1c8817932a798d90452e96c6afab6baa991631f107cb;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
61m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5" Netns:"/var/run/netns/407ecc96-9157-40b8-803a-c4dc929ebcbe" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=f007e5608c5734cadcfd3a789db60afe59f3965285e25436537b4aeb30ed6bf5;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
61m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba" Netns:"/var/run/netns/363b613f-fbad-401a-ae94-35ae92024f9b" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=597861cc1a46e231285451e96353069cdedb6c5526078467349eff267279f6ba;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
60m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402" Netns:"/var/run/netns/9ee411f8-e6c9-43a0-9f93-4b804678bee2" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=1d47cf34f833ca3e67e3ef677ec927ab07eb62f627beeb0ada85e2f70c7de402;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
56m         Warning   FailedCreatePodSandBox   pod/myapp-myapp-ocp-6848d559b4-lv7zj    (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to create pod network sandbox k8s_myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev_f2a884f4-604b-4194-9938-5997bfea89eb_0(00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483): error adding pod myapp-dev_myapp-myapp-ocp-6848d559b4-lv7zj to CNI network "multus-cni-network": plugin type="multus-shim" name="multus-cni-network" failed (add): CmdAdd (shim): CNI request failed with status 400: 'ContainerID:"00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483" Netns:"/var/run/netns/4b38641e-d81d-4548-b673-bec763daabeb" IfName:"eth0" Args:"IgnoreUnknown=1;K8S_POD_NAMESPACE=myapp-dev;K8S_POD_NAME=myapp-myapp-ocp-6848d559b4-lv7zj;K8S_POD_INFRA_CONTAINER_ID=00b91ed9d58552fcbb9503ac5c230c21b443603f54eaab0f8aa006682bb62483;K8S_POD_UID=f2a884f4-604b-4194-9938-5997bfea89eb" Path:"" ERRORED: error configuring pod [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj] networking: Multus: [myapp-dev/myapp-myapp-ocp-6848d559b4-lv7zj/f2a884f4-604b-4194-9938-5997bfea89eb]: error waiting for pod: Unauthorized...
52m         Warning   BackOff                  pod/myapp-myapp-ocp-6848d559b4-lv7zj    Back-off restarting failed container myapp-ocp in pod myapp-myapp-ocp-6848d559b4-lv7zj_myapp-dev(f2a884f4-604b-4194-9938-5997bfea89eb)
42m         Warning   FailedCreate             replicaset/myapp-myapp-ocp-69f56654fc   Error creating: pods "myapp-myapp-ocp-69f56654fc-" is forbidden: unable to validate against any security context constraint: [provider "anyuid": Forbidden: not usable by user or serviceaccount, provider restricted-v2: .spec.securityContext.fsGroup: Invalid value: []int64{1001}: 1001 is not an allowed group, provider restricted-v2: .containers[0].runAsUser: Invalid value: 1001: must be in the ranges: [1000690000, 1000699999], provider "restricted": Forbidden: not usable by user or serviceaccount, provider "nonroot-v2": Forbidden: not usable by user or serviceaccount, provider "nonroot": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid": Forbidden: not usable by user or serviceaccount, provider "hostmount-anyuid-v2": Forbidden: not usable by user or serviceaccount, provider "machine-api-termination-handler": Forbidden: not usable by user or serviceaccount, provider "hostnetwork-v2": Forbidden: not usable by user or serviceaccount, provider "hostnetwork": Forbidden: not usable by user or serviceaccount, provider "hostaccess": Forbidden: not usable by user or serviceaccount, provider "hostpath-provisioner": Forbidden: not usable by user or serviceaccount, provider "node-exporter": Forbidden: not usable by user or serviceaccount, provider "privileged": Forbidden: not usable by user or serviceaccount]
42m         Warning   BackOff                  pod/myapp-myapp-ocp-6848d559b4-bsnfs    Back-off restarting failed container myapp-ocp in pod myapp-myapp-ocp-6848d559b4-bsnfs_myapp-dev(65d3b909-4d1f-4b8a-bd9d-bc5cf05863db)

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc delete event -n myapp-dev --all || true
oc delete events.events.k8s.io -n myapp-dev --all || true
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b6e9d0096a" deleted
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b709c4f65a" deleted
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b70bd6cd15" deleted
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b71322e345" deleted
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b713ca2a46" deleted
event "myapp-myapp-ocp-6848d559b4-bsnfs.1880d3b791e9ab67" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d3239953c13c" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d32448c173bc" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d3251640361a" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d3284481a9f3" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d32bc3172904" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d32fb6dbe021" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d333ad1c582f" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d337a34f1ac6" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d33b5cd823dc" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d33e9eb2968a" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d342580b78bf" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d395748ddbf6" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d39579516c96" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d39fb34cdd96" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d39fbc92f721" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d39fbdb99f96" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d39fdce978cd" deleted
event "myapp-myapp-ocp-6848d559b4-lv7zj.1880d3a01c0fd5ff" deleted
event "myapp-myapp-ocp-6848d559b4.1880d32398b4d5c9" deleted
event "myapp-myapp-ocp-6848d559b4.1880d3b6e937fc8f" deleted
event "myapp-myapp-ocp-6848d559b4.1880d4475f359c49" deleted
event "myapp-myapp-ocp-69f56654fc.1880ca99bdf249a0" deleted
event "myapp-myapp-ocp-77c69d99b9-dth4v.1880d60e882ba345" deleted
event "myapp-myapp-ocp-77c69d99b9-dth4v.1880d60eac4e04b4" deleted
event "myapp-myapp-ocp-77c69d99b9-dth4v.1880d60eaec9596b" deleted
event "myapp-myapp-ocp-77c69d99b9-dth4v.1880d60ec1787cf1" deleted
event "myapp-myapp-ocp-77c69d99b9-dth4v.1880d60ec2991fdd" deleted
event "myapp-myapp-ocp-77c69d99b9-vvb52.1880d445bcf6bbba" deleted
event "myapp-myapp-ocp-77c69d99b9-vvb52.1880d445e45bc110" deleted
event "myapp-myapp-ocp-77c69d99b9-vvb52.1880d445e6773c9c" deleted
event "myapp-myapp-ocp-77c69d99b9-vvb52.1880d445ee73f07d" deleted
event "myapp-myapp-ocp-77c69d99b9-vvb52.1880d445ef9093a5" deleted
event "myapp-myapp-ocp-77c69d99b9.1880d445bb94645a" deleted
event "myapp-myapp-ocp-77c69d99b9.1880d60e8763b64c" deleted
event "myapp-myapp-ocp.1880d32397369ae0" deleted
event "myapp-myapp-ocp.1880d445b8e5f830" deleted
event "myapp-myapp-ocp.1880d445ba41d8d5" deleted
event "myapp-myapp-ocp.1880d4475d3ca998" deleted
event "myapp-myapp-ocp.1880d60e85867b41" deleted
No resources found

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ script -f session-gitbash.log   # puis exit à la fin
bash: script: command not found

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$ oc get events -n myapp-dev --field-selector type=Warning --sort-by=.lastTimestamp | tail -n 30
No resources found in myapp-dev namespace.

HP 17 G3 Win 11 23H2@HP17G3 MINGW64 /c/workspaces/openshift2026/helm-openshift-roadmap (master)
$
