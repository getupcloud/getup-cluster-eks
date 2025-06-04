## Upgrading karpenter 0.x to 1.5

```
echo UPSTREAM_CLUSTER_DIR=/home/mateus/getup/git/gitops/getup-cluster-eks >> .env
export UPSTREAM_CLUSTER_DIR=/home/mateus/getup/git/gitops/getup-cluster-eks

make update-from-local-cluster
cp $UPSTREAM_CLUSTER_DIR/cluster/overlay/aws-load-balancer-controller.yaml cluster/overlay/aws-load-balancer-controller.yaml
sed -i -e 's/ref=v2\.0\..*/ref=v1.4.3/' main-eks.tf
make init
kubectl delete nodepool --all
kubectl delete nodeclaim --all
kubectl delete ec2nodeclass --all
terraform destroy -target module.eks.module.karpenter
helm uninstall -n karpenter karpenter
helm uninstall -n karpenter karpenter-crd
make update-from-local-cluster
+ update terraform-eks.tfvars: karpenter_version = "1.5.0"
make init plan apply overlay commit push flux-rec-sg

kubectl delete pod -n getup -l app=teleport-agent
kubectl delete pod -n kube-system -l eks.amazonaws.com/component=coredns
kubectl delete pod -n kube-system -l app.kubernetes.io/component=csi-driver,app=ebs-csi-controller
kubectl delete pod -n keda -l app.kubernetes.io/name=keda-operator
kubectl delete pod -n karpenter -l app.kubernetes.io/name=karpenter
```
