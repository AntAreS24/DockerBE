# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'open-uri'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.6.0"

CHANNEL = ENV['CHANNEL'] || 'alpha'
COREOS_VERSION = ENV['COREOS_VERSION'] || 'latest'
upstream = "http://#{CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}"
if COREOS_VERSION == "latest"
	upstream = "http://#{CHANNEL}.release.core-os.net/amd64-usr/current"
	url = "#{upstream}/version.txt"
	RETRIEVED_COREOS_VERSION = open(url).read().scan(/COREOS_VERSION=.*/)[0].gsub('COREOS_VERSION=', '')
#else
#	RETRIEVED_COREOS_VERSION = #{COREOS_VERSION}
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.provider :virtualbox do |v|
		# On VirtualBox, we don't have guest additions or a functional vboxsf
		# in CoreOS, so tell Vagrant that so it can be smarter.
		v.check_guest_additions = false
		v.functional_vboxsf     = false
	end
	# Fix to solve DNS issue with private Docker registry
	config.vm.provider :virtualbox do |v, override|
		v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
		# bridged containers won't work, because the virtual NIC will filter out all packets with a different MAC address. If you are running VirtualBox in headless mode
		v.customize ['modifyvm', :id, '--nictype1', 'Am79C973']
		v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
	end
	config.vm.box = "coreos-#{CHANNEL}"
	config.vm.box_version = ">= #{RETRIEVED_COREOS_VERSION}"
	config.vm.box_url = "#{upstream}/coreos_production_vagrant.json"

	config.vm.define "simple" do |c|
		c.vm.hostname = "simple"
	end
end
