# TODO

## Services

- [ ] monitoring (grafana + loki push with alloy)
- [ ] monero node
- [ ] tor node (multiple maybe)
- [ ] immich
- [ ] onlyoffice
- [ ] giteamirror (https://giteamirror.com)
- [ ] gitea (https://docs.gitea.com)
- [ ] move vaultwarden to this repo

## Cleanup

- [ ] configure authentik declaratively via blueprints (service runs, internal
      config is still manual)
- [ ] simplify container logic
- [ ] full disk encryption with remote unlock (key server or initrd SSH)
- [ ] zfs backups and monitoring
- [ ] fix nextcloud push (when using `bendDomainToLocalhost` it assumes http and
      configures that)
- [ ] Translate legacy Neovim config to Nix-based configuration.
- [ ] Fix Pangolin next cache issue (See
      https://github.com/NixOS/nixpkgs/pull/347856/changes#diff-fb0529f182d2495ecf94e3b97f79019df8fcc80442d6576e17a04ae9b9effd56):

      [Error: EACCES: permission denied, mkdir '/var/lib/pangolin/.next/cache'] {
        errno: -13,
        code: 'EACCES',
        syscall: 'mkdir',
        path: '/var/lib/pangolin/.next/cache'
      }
       ⨯ unhandledRejection:  [Error: EACCES: permission denied, mkdir '/var/lib/pangolin/.next/cache'] {
        errno: -13,
        code: 'EACCES',
        syscall: 'mkdir',
        path: '/var/lib/pangolin/.next/cache'
      }
       ⨯ Failed to write image to cache Cc6Vpwm9nA6fCNQhBnein9sVrACU06PTOx3YxG03Rog [Error: EACCES: permission denied, mkdir '/var/lib/pangolin/.next/cache'] {
        errno: -13,
        code: 'EACCES',
        syscall: 'mkdir',
        path: '/var/lib/pangolin/.next/cache'
      }
