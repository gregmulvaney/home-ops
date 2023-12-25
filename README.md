# Home-ops
A Proxmox LXC based K3S deployment

## Prerequisites 
* [Task](https://github.com/go-task/task)
* [direnv](https://github.com/direnv/direnv)

## Installation
This setup currently only supports Debian based images
1. Install the other required tools

    `task brew:deps`
2. Prepare the terraform `tfvars` files

    `task tf:prepare`

3. fillout the Proxmox terraform `tfvars` files at `./infrastructure/terraform/proxmox`
4. Once you've filled the required variables provision your Proxmox LXCs

    ```sh
    task tf:pm:init
    task tf:pm:plan
    ```
    Look over the output and ensure everything looks right and then run:

    ```sh
    task tf:pm:apply
    ```
    If you make any mistakes you can destroy your created LXCs using 

    ```sh
    task tf:pm:destroy
    ```
