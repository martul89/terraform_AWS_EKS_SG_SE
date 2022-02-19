output "kubeconfig" {
  value = <<KUBECONFIG
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.prefix}-eks_cluster-${random_id.random-string.dec}"

KUBECONFIG
}

/*
output "ec2_ip" {
   value = "${aws_instance.nginx_public.public_ip}"
 }

 output "To_SSH_into_the_ubuntu" {
  value =  "ssh -i ${aws_key_pair.demo.key_name}.pem ubuntu@${aws_instance.nginx_public.public_ip}"
 } */

/*
 resource "null_resource" "eks_kubeconfig" {
    provisioner "local-exec" {
    command = <<EOT
    "sudo scripts/.runtest.sh"
    EOT
  depends_on = [module.bigip]
  } */
 

 output "F5_IP" {
  value = module.bigip.0.mgmtPublicIP
}

output "F5_Password" {
  value = random_string.password.result
}

output "F5_Username" {
  value = "admin"
}

output "F5_ssh" {
  value = "ssh -i ${aws_key_pair.demo.key_name}.pem admin@${module.bigip.0.mgmtPublicIP}"
}

output "F5_UI" {
  value = "https://${module.bigip.0.mgmtPublicIP}:8443"
}




/*
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /home/martul/.kube/config"
  }
} 


 command = <<EOT
    "mkdir /home/martul/.kube/"
    "terraform output -raw kubeconfig > /home/martul/.kube/config"
    "aws configure set aws_access_key_id ${var.access_key}"
    "aws configure set aws_secret_access_key ${var.secret_key}"
    "aws configure set region ${var.region}"
    EOT 
    
    */

