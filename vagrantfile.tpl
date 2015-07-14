Vagrant.configure("2") do |config|
  config.ssh.shell = "sh"
  config.ssh.username = "docker"

  # Used on Vagrant >= 1.7.x to disable the ssh key regeneration
  config.ssh.insert_key = false

  # Use NFS folder sync if env variable B2D_NFS_SYNC is set
  if ENV['B2D_NFS_SYNC']
    config.vm.synced_folder "/Users", "/Users", type: "nfs", mount_options: ["nolock", "vers=3", "udp"], id: "nfs-sync"
  else
    config.vm.synced_folder "/Users", "/Users"
  end

  # Add bootlocal support
  if File.file?('./bootlocal.sh')
    config.vm.provision "shell", path: "bootlocal.sh", run: "always"
  end

end
