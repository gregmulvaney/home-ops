# Home-ops
A Proxmox LXC based K3S deployment

## Prerequisites 
* [Task](https://github.com/go-task/task)
* [direnv](https://github.com/direnv/direnv)

## Installation
1. Install the other required tools

    `task brew:deps`
2. Prepare the terraform `tfvars` files

    `task tf:prepare`
