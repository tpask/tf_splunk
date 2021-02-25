output "instance_ip_addr" { value = "ssh centos@${aws_instance.my_instance.public_ip}" }
