# Part 1 — K3s Cluster

One VMs: **mhoyerS** (server/controller).

## Commands

### Launch

```bash
vagrant up
```

### SSH

```bash
vagrant ssh mhoyerS
```

### Show running services

```bash
sudo kubectl get all
```

### Try curl

```bash
curl -H "Host:app2.com" 192.168.56.110
```

### Stop

```bash
vagrant halt
```

### Destroy

```bash
vagrant destroy
```
