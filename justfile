default:
    @just --list

# Build and switch system configuration for current host
switch:
    #!/usr/bin/env bash
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo darwin-rebuild switch --flake .
    else
        sudo nixos-rebuild switch --flake .
    fi

# Install system on remote host via SSH
deploy host target=host:
    nixos-rebuild switch \
        --flake .#{{host}} \
        --target-host {{target}} \
        --build-host {{target}} \
        --sudo
