Vagrant.configure("2") do |config|
  CURRENT_DIR = Dir.pwd

  config.ssh.shell = "sh"
  config.ssh.username = "docker"

  # Used on Vagrant >= 1.7.x to disable the ssh key regeneration
  config.ssh.insert_key = false

  # Use NFS folder sync if env variable B2D_NFS_SYNC is set
  if ENV['B2D_NFS_SYNC']
    config.vm.synced_folder ".", CURRENT_DIR, type: "nfs", mount_options: ["nolock", "vers=3", "udp"], id: "nfs-sync"
  else
    config.vm.synced_folder ".", CURRENT_DIR
  end

  config.vm.provider "virtualbox" do |v, override|
    # Expose the Docker ports (non secured AND secured)
    override.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true, id: "docker"
    override.vm.network "forwarded_port", guest: 2376, host: 2376, host_ip: "127.0.0.1", auto_correct: true, id: "docker-ssl"

    if !ENV['B2D_DISABLE_PRIVATE_NETWORK']
      # Create a private network for accessing VM without NAT
      override.vm.network "private_network", ip: "192.168.10.10", id: "default-network", nic_type: "virtio"
    end
  end

  config.vm.provision "shell", inline: "[ ! -d /vagrant ] && ln -s #{CURRENT_DIR} /vagrant || true"

  # Add bootlocal support
  if File.file?('./bootlocal.sh')
    config.vm.provision "shell", path: "bootlocal.sh", run: "always"
  end

end
