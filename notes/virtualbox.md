# Virtual machines and VirtualBox

A virtual machine (VM) runs a guest operating system on virtual hardware provided by a hypervisor. It has its own kernel, memory allocation, virtual disks, and network interfaces. VMs are useful for disposable labs, testing operating systems, and separating workloads.

## Hypervisor types

A type 1 hypervisor runs directly on hardware. Examples include VMware ESXi and Microsoft Hyper-V. A type 2 hypervisor runs on a host operating system; VirtualBox is commonly described this way.

VM configuration and virtual disks are stored on the host. A VM can use multiple disk and configuration files, and those files are not automatically a complete, consistent backup of a running application.

## Choose a network mode

| Mode | Typical use | Reachability |
| --- | --- | --- |
| NAT | Guest needs outbound access | Inbound access usually needs explicit port forwarding |
| Bridged | Guest should appear on the physical network | Other devices may reach it, subject to network and firewall rules |
| Host-only | Host and guests need a private lab network | No external access through this interface alone |
| Internal | Guests need an isolated network with each other | Host and external access are absent through this interface |

A NAT Network can also connect guests to each other while providing NAT access. Multiple adapters can change the isolation model, so inspect every enabled adapter. Use host-only or internal networking when external connectivity is unnecessary.

## A repeatable lab

Create a base VM, allocate resources within the host's capacity, install the guest OS, and document how to connect. Use keys for SSH, restrict incoming connections, and keep the guest patched. Record image versions and setup steps so the environment can be recreated.

A snapshot helps return a lab to an earlier state. It depends on the VM's storage chain and is not an independent backup. Reverting also discards changes made since the snapshot. Keep important work and backup copies outside the disposable guest.

For automation, learn the installed version's `VBoxManage` commands or use a tool that manages VM definitions. Start with create, start, stop, network configuration, and deletion in a test environment.

Reference: [VirtualBox networking](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html). Related: [containers](containers_and_orchestration.md) and [backup and recovery](backup_and_recovery.md).
