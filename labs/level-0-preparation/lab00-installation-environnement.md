_Titre: Lab 00: Installation de l'environnement de travail_

## Objectif

L'objectif de ce laboratoire est de mettre en place un environnement de développement local complet pour suivre les exercices de ce dépôt. Nous allons installer et configurer OpenShift Local (CRC), l'outil `oc` et Helm 3.

## Contexte

Pour travailler avec Helm sur OpenShift, il est essentiel de disposer d'un cluster accessible et des outils clients appropriés. OpenShift Local est la solution recommandée par Red Hat pour créer un cluster OpenShift mono-nœud sur une machine locale.

## Étapes

### 1. Installation d'OpenShift Local (CRC)

Suivez le [guide d'installation officiel](https://developers.redhat.com/products/openshift-local/overview) pour votre système d'exploitation (Windows, macOS ou Linux).

*   Téléchargez l'exécutable `crc`.
*   Exécutez `crc setup` pour configurer votre environnement.
*   Démarrez le cluster avec `crc start`. Cette opération peut prendre plusieurs minutes.

### 2. Configuration de l'environnement shell

Une fois le cluster démarré, `crc start` affichera des commandes à exécuter pour ajouter `oc` à votre `PATH` et vous connecter au cluster. Copiez et exécutez la commande qui ressemble à ceci :

```bash
eval $(crc oc-env)
```

### 3. Connexion au cluster OpenShift

Connectez-vous en tant qu'administrateur (`kubeadmin`) en utilisant la commande fournie par `crc start` :

```bash
oc login -u kubeadmin -p <mot-de-passe> https://api.crc.testing:6443
```

### 4. Installation de Helm 3

Si vous n'avez pas encore Helm 3, suivez le [guide d'installation officiel](https://helm.sh/docs/intro/install/). La méthode la plus simple est souvent d'utiliser un gestionnaire de paquets comme Homebrew (macOS/Linux) ou Chocolatey (Windows).

## Vérifications

*   **Vérifiez la version d'OpenShift** :

    ```bash
    oc version
    ```

    Vous devriez voir une version client et serveur.

*   **Vérifiez les nœuds du cluster** :

    ```bash
    oc get nodes
    ```

    Vous devriez voir un seul nœud `crc-xxxxx-master-0` avec le statut `Ready`.

*   **Vérifiez la version de Helm** :

    ```bash
    helm version
    ```

    Vous devriez voir la version de Helm 3 installée.

## Nettoyage

Pour arrêter le cluster et libérer les ressources, exécutez :

```bash
crc stop
```

Pour supprimer complètement la machine virtuelle du cluster, exécutez :

```bash
crc delete
```
