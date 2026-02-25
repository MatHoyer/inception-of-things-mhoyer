# Part 1 — K3s Cluster

Two VMs: **mhoyerS** (server/controller) and **mhoyerSW** (worker/agent).

## Commands

### Launch

```bash
vagrant up
```

### SSH

```bash
vagrant ssh mhoyerS
vagrant ssh mhoyerSW
```

### SHOW NODES

```bash
sudo kubectl get nodes
```

### Stop

```bash
vagrant halt
```

### Destroy

```bash
vagrant destroy
```
