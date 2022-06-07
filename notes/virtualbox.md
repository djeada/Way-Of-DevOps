* automatically creating vms
* accessing and restricting internet
* ssh into the vm
* orchestrating the vms
* snapshot and recreating vms

## Virtualization

* Type 1: run directly on the bare metal. Example: Microsoft Hyper-v.

    vm |  vm  | vm
    --------------
    Hypervisor
    --------------
    Bare Metal
  

* Type 1: run directly on the bare metal. Example: VrirtualBox.

    vm |  vm  | vm
    --------------
    Hypervisor
    --------------
    Operating System
    --------------
    Bare Metal
    
    
## Oracle VirtualBox

* Free
* Opensource
* Runs on any platform (Windows and Linux)
* Run multiple VMs
* Networking

The VM itself and all its contents are stored in a file on a host operating system.

## Network

* Bridge: vm can connect to the internet as well as becomes an ip adress
