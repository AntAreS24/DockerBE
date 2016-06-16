# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'open-uri'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.6.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.provider :virtualbox do |v, override|
		# bridged containers won't work, because the virtual NIC will filter out all packets with a different MAC address. If you are running VirtualBox in headless mode
		v.customize ['modifyvm', :id, '--nic1', 'nat']
		v.customize ['modifyvm', :id, '--nictype1', 'Am79C973'] #Am79C973|virtio
		v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
		# Fix to solve DNS issue with private Docker registry
		v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
	end
	config.vm.box = "bento/centos-6.7"

	config.vm.provision :shell, :path => "provision.sh"
	#config.vm.provision :shell, :inline => "ip route delete default 2>&1 >/dev/null || true; ip route add default via #{default_router}"
	
	config.vm.define "simple" do |c|
		c.vm.hostname = "simple"
		c.vm.network "private_network", ip: "10.20.30.100"
	end

	config.vm.define "simple2" do |c|
		c.vm.hostname = "simple2"
		c.vm.network "private_network", ip: "10.20.30.101"
	end

end
