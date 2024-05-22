Creating a cluster
------------------

Run the command below and follow the instructions.

```
curl -OLs https://github.com/getupcloud/terraform-cluster/raw/main/create-cluster.sh
bash ./create-cluster.sh
```

Default operation flow
----------------------

```
make init
make plan
make apply
make overlay
make commit
make push
```
