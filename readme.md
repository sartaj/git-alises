# Git Aliases

A collection of useful Git aliases and custom commands to enhance your Git workflow.

Each command is self contained, allowing you to install individually, or all.

## Install All With 1 Command

```bash
for a in git-commit-to git-squish; do curl -s "https://raw.githubusercontent.com/sartaj/git-aliases/main/$a/install.sh" | bash; done
```

## Available Commands

| Command                                      | Description                                                                     | Install                                                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `git commit-to <branch-name> [-m <message>]` | Push staged changes to a new branch without switching branches                  | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-commit-to/install.sh \| bash` |
| `git squish [-m <message>]`                  | Squash all commits on current branch back to where it diverged from base branch | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-squish/install.sh \| bash`    |

## Contributing

### Add new script

Add a folder. Each folder should have an `install.sh` script that adds the alias. In the above install all script, add the folder added.

## License

[MIT License](LICENSE)
