Vagrant.configure("2") do |config|
  config.ssh.shell = "sh -l"
  config.ssh.username = "docker"

  # Expose the Docker port
  config.vm.network "forwarded_port", guest: 4243, host: 4243

  # Attach the b2d ISO so that it can boot
  config.vm.provider "virtualbox" do |v|
    v.customize "pre-boot", [
      "storageattach", :id,
      "--storagectl", "IDE Controller",
      "--port", "0",
      "--device", "1",
      "--type", "dvddrive",
      "--medium", File.expand_path("../boot2docker.iso", __FILE__),
    ]
  end
end
