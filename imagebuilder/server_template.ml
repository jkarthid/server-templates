Name: Image Bundler For RightLink 10
Description: "This ServerTemplate uses Packer to create cloud images, and if needed
  add RightLink 10 to the target image.\n\n# Documentation\n* [Overview](https://docs.rightscale.com/st/rl10/image-bundler/)\n*
  [Tutorial](http://docs.rightscale.com/st/rl10/image-bundler/tutorial.html)\n\n#
  Clouds\n* AWS \n* Google \n* Azure Resource Manager\n"

Inputs:
  MANAGED_LOGIN: "text:enable"
RightScripts:
  Boot:
  - Name: RL10 Linux Wait For EIP
    Revision: 5
    Publisher: RightScale
  - Name: RL10 Linux Enable Managed Login
    Revision: 7
    Publisher: RightScale
  - packer_install.sh
  - packer_install_plugins.sh
  - packer_configure.sh
  - packer_build.sh
  Operational:
MultiCloudImages:
- Name: Ubuntu_14.04_x64
  Revision: 70
- Name: Ubuntu_14.04_x64_KVM
  Revision: 31
Alerts: []
