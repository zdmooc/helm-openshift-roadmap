Titre: Prérequis Techniques

Avant de commencer les laboratoires, assurez-vous que votre environnement de travail est correctement configuré.

## Prérequis Matériels et Logiciels

*   **Cluster OpenShift** : Vous avez besoin d'un accès à un cluster OpenShift 4.x. Pour un environnement local, nous recommandons fortement **[OpenShift Local](https://developers.redhat.com/products/openshift-local/overview)** (anciennement CodeReady Containers ou CRC). Il fournit un cluster OpenShift complet sur votre machine locale (Windows, macOS, Linux).
*   **`oc` CLI** : L'outil en ligne de commande `oc` est indispensable pour interagir avec votre cluster OpenShift. Suivez les [instructions officielles](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html) pour l'installer et le configurer.
*   **`helm` CLI** : Vous devez installer **Helm 3**. Les instructions d'installation sont disponibles sur le [site officiel de Helm](https://helm.sh/docs/intro/install/).
*   **`kubectl` CLI** : Bien que `oc` soit un sur-ensemble de `kubectl`, avoir `kubectl` peut être utile. Il est généralement inclus avec l'installation de `oc`.

## Connaissances Minimales Requises

Ce dépôt suppose que vous avez une compréhension de base des concepts suivants de Kubernetes :

*   **Pods** : L'unité de déploiement de base.
*   **Deployments** : Gestion des Pods et de leurs mises à jour.
*   **Services** : Exposition des applications en réseau.
*   **Namespaces** : Isolation des ressources.

## Rappels Importants

### Helm vs. `oc apply`

*   **`oc apply -f <fichier.yaml>`** est une commande impérative qui applique une configuration statique à un cluster. Elle ne gère pas le cycle de vie de l'application dans son ensemble.
*   **`helm install`** est une approche déclarative qui installe un "chart" (un paquet applicatif). Helm suit la "release" (l'instance déployée du chart), ce qui permet des mises à jour (`helm upgrade`) et des retours en arrière (`helm rollback`) de manière transactionnelle.

### Routes vs. Ingress

*   **Ingress** est la ressource standard de Kubernetes pour gérer l'accès externe aux services HTTP/HTTPS. Sa fonctionnalité est basique.
*   **Route** est une ressource spécifique à OpenShift, plus puissante et flexible qu'un Ingress. Elle offre des fonctionnalités avancées comme le TLS passthrough, le split-traffic pour les A/B tests, et une intégration native avec le routeur OpenShift. Dans ce dépôt, nous utiliserons principalement des **Routes**.
