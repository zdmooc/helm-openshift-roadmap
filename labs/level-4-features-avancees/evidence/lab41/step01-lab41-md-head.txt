_Titre: Lab 41: Dépôt Helm sur GitHub et Artifact Hub_

## Objectif

Publier un chart Helm sur un dépôt hébergé sur GitHub Pages et le rendre découvrable via Artifact Hub.

## Contexte

Pour partager des charts Helm publiquement ou au sein d'une organisation, on les publie sur un **dépôt de charts**. Un dépôt Helm est simplement un serveur web HTTP qui héberge un fichier `index.yaml` et les archives `.tgz` des charts. GitHub Pages est un moyen simple et gratuit d'héberger un tel dépôt.

## Étapes

### 1. Préparer le chart

Assurez-vous que votre chart `myapp-ocp` a une version correcte dans son `Chart.yaml` (ex: `version: 0.1.0`).

### 2. Packager le chart

Créez l'archive du chart :

```bash
helm package charts/myapp-ocp
```

Cette commande crée un fichier `myapp-ocp-0.1.0.tgz`.

### 3. Créer le dépôt sur GitHub Pages

*   Créez un nouveau dépôt GitHub (ex: `my-helm-charts`).
*   Activez GitHub Pages dans les paramètres du dépôt, en choisissant la branche `main` et le dossier `/docs` comme source.
*   Clonez ce nouveau dépôt en local.

### 4. Initialiser l'index du dépôt

Dans le dépôt cloné, créez un dossier `docs` et générez le fichier `index.yaml` :

```bash
mkdir docs
helm repo index . --url https://<VOTRE-USER>.github.io/my-helm-charts/
```

*Remplacez `<VOTRE-USER>` par votre nom d'utilisateur GitHub.*

### 5. Ajouter le chart au dépôt

*   Copiez l'archive `myapp-ocp-0.1.0.tgz` dans le dossier `docs`.
*   Mettez à jour l'index pour inclure le nouveau chart :

    ```bash
    helm repo index docs --url https://<VOTRE-USER>.github.io/my-helm-charts/
    ```

### 6. Pousser les changements sur GitHub

Commitez et poussez le contenu du dossier `docs` (y compris `index.yaml` et le `.tgz`) vers votre dépôt GitHub.

### 7. Ajouter le dépôt à Artifact Hub (Optionnel)

[Artifact Hub](https://artifacthub.io/) est un annuaire de packages Cloud Native. Vous pouvez y enregistrer votre dépôt pour que d'autres puissent trouver vos charts.

*   Connectez-vous à Artifact Hub avec votre compte GitHub.
*   Allez dans le Control Panel et ajoutez un nouveau dépôt, en fournissant l'URL de votre dépôt GitHub Pages.

## Vérifications

*   **Ajoutez votre nouveau dépôt à Helm** :

    ```bash
    helm repo add my-charts https://<VOTRE-USER>.github.io/my-helm-charts/
    ```

*   **Recherchez votre chart** :

    ```bash
    helm search repo my-charts/myapp-ocp
    ```

*   **Installez le chart depuis votre dépôt** :

    ```bash
    oc new-project myapp-repo-test
    helm install myapp-from-repo my-charts/myapp-ocp -n myapp-repo-test
    ```

## Nettoyage

```bash
helm uninstall myapp-from-repo -n myapp-repo-test
oc delete project myapp-repo-test
helm repo remove my-charts
```
