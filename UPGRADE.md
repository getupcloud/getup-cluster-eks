## Upgrading karpenter 0.x to 1.5

```
make init
kubectl delete nodepool --all
kubectl delete nodeclaim --all
kubectl delete ec2nodeclass --all
terraform destroy -target module.eks.module.karpenter
helm uninstall -n karpenter karpenter
helm uninstall -n karpenter karpenter-crd
make update
sed -i -e 's/karpenter_version.*/karpenter_version = "1.5.0"/' terraform-eks.auto.tfvars
make init plan apply overlay commit push flux-rec-sg

kubectl delete pod -n getup -l app=teleport-agent
kubectl delete pod -n kube-system -l eks.amazonaws.com/component=coredns
kubectl delete pod -n kube-system -l app.kubernetes.io/component=csi-driver,app=ebs-csi-controller
kubectl delete pod -n keda -l app.kubernetes.io/name=keda-operator
kubectl delete pod -n karpenter -l app.kubernetes.io/name=karpenter
```
