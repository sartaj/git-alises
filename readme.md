# Git Aliases

A collection of useful Git aliases and custom commands to enhance your Git workflow.

Each command is self contained, allowing you to install individually, or all.

## Install All

```bash
# Install all aliases with a single command
curl -s https://raw.githubusercontent.com/sartaj/git-alises/refs/heads/main/install-all.sh | bash
```

## Available Commands

| Command                                      | Description                                                                     | Install                                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `git commit-to <branch-name> [-m <message>]` | Push staged changes to a new branch without switching branches                  | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-commit-to/install.sh \| bash` |
| `git squish [-m <message>]`                  | Squash all commits on current branch back to where it diverged from base branch | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-squish/install.sh \| bash`    |

## Contributing

### Add new script

Add a folder. Each folder should have an `install.sh` script that adds the alias. In `install-all.sh`, add the folder added.

## License

[MIT License](LICENSE)
