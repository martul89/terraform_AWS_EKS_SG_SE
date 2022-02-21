output "AWS-kubeconfig" {
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
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.prefix}-eks_cluster-${random_id.random-string.dec}"

KUBECONFIG
}


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

output "NGINX_WAF_IP" {
  value = "${aws_instance.nginx_WAF.public_ip}"
}

output "NGINX_WAF_IP_ssh" {
  value = "ssh -i ${aws_key_pair.demo.key_name}.pem ubuntu@${aws_instance.nginx_WAF.public_ip}"
}

output "Jumphost_ubuntu" {
  value = "${aws_instance.nginx_public.public_ip}"
}

output "Jumphost_ubuntu_ssh" {
  value = "ssh -i ${aws_key_pair.demo.key_name}.pem ubuntu@${aws_instance.nginx_public.public_ip}"
}

output "NLB_Endpoint" {
  value = data.template_file.userdata-nginx-v1.vars.AWS_LB
}

output "TMSH-Config-for-F5" {
  value = <<RUN_AT_F5
SSH to F5 and run command:
tmsh install /sys crypto cert arcadiacert from-local-file /config/ssl/ssl.crt/arcadia.crt
tmsh install /sys crypto key arcadiakey from-local-file /config/ssl/ssl.key/arcadia.key
tmsh create /ltm profile client-ssl arcadia_ssl cert arcadiacert key arcadiakey
tmsh save sys config
RUN_AT_F5
}

/*

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /home/martul/.kube/config"
  }
} */

