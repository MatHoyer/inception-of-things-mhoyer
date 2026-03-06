If server pod isn't running delete it (it will be recreated)

```bash
kubectl get pod
```

```bash
kubectl delete pod -n argocd <pod-name>
```
