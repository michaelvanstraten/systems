# My Systems Repository

Welcome to my **Systems** repository, where I manage both my dotfiles and system
configurations using Nix Flakes. This repository represents an evolved version
of my previous
[dotfiles repository](https://github.com/michaelvanstraten/dotfiles), now
focusing on a more integrated and reproducible approach to system management.

## Overview

This repository leverages Nix Flakes to provide a declarative and reproducible
setup for both my personal and professional environments. It includes
configurations for various systems, including macOS and NixOS, ensuring a
consistent experience across different machines.

## Features

- **Nix Flakes**: Utilizes Nix Flakes for declarative and reproducible system
  configurations.
- **Cross-Platform**: Supports both macOS and NixOS systems.
- **Integrated Management**: Combines dotfiles and system configurations into a
  single repository for easier management.
- **Automated Checks**: Includes pre-commit hooks for maintaining code quality
  and consistency.

## To-Do

### Configuration Translation

- [ ] Translate legacy Neovim config to Nix-based configuration.
- [ ] Translate legacy Firefox user profile config to Nix-based configuration.

### System Management

- [ ] Make non-Darwin apps manageable using Nix.
- [x] Add work machine configuration.
- [ ] Abstract dotfiles into modules for better reusability and maintainability.

### Deployment and Secrets Management

- [ ] Explore using [MicroMDM](https://micromdm.io/) to deploy new Darwin
      systems.
- [ ] Use [Teller](https://github.com/spectralops/teller) to manage secrets
      securely.

### Miscellaneous

- [ ] Add [EditorConfig](https://editorconfig.org/) to dotfiles for consistent
      coding styles.

## Contributing

Contributions are welcome! If you have any improvements or bug fixes, feel free
to submit a pull request. For major changes, please open an issue first to
discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.
