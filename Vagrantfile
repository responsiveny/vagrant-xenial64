# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.box="boxcutter/ubuntu1604" 
  config.vm.box_check_update = "false"

  config.vm.hostname = "myhost.dev"
  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network "private_network", ip: "192.168.100.50"
  # Share an additional folder to the guest VM. The first argument is the path on the host to the actual folder.
  # The second argument is the path on the guest to mount the folder.
  config.vm.provider "virtualbox" do |v|
    v.name = "Ubuntu 1604 Xenial x64"
    v.memory = 2048
    v.cpus = 1
  end
  
  # Define the bootstrap file: A (shell) script that runs after first setup of your box (= provisioning)
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.synced_folder "./", "/srv/www"

  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false
  
  config.vm.post_up_message = "Box is up!"

end
