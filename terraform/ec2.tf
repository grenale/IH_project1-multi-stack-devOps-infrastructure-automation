resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  security_groups             = [aws_security_group.app_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "grenale-app"
  }

  provisioner "local-exec" {
    command = <<EOT
        echo "${self.tags["Name"]} ansible_host=${self.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.ssh_private_key_path}" >> ${var.ansible_inventory_path}
        echo "Added ${self.tags["Name"]} with IP: ${self.public_ip} to hosts file" >> ${var.terraform_log_path}
      EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      sed -i '/${self.tags["Name"]}/d' ../ansible/inventory/hosts.ini
      echo "Removed ${self.tags["Name"]} from the hosts file" >> /tmp/terraform-debug.log
    EOT
  }
}
