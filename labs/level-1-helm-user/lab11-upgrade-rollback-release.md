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
