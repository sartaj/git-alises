[![Tests](https://github.com/sartaj/git-aliases/actions/workflows/test.yml/badge.svg)](https://github.com/sartaj/git-aliases/actions/workflows/test.yml)

# Git Aliases

A collection of useful git aliases to help improve your git workflow.

## Quick Install

Just want to install a specific command? Copy and paste the relevant command below:

```bash
# Install individual commands
for a in git-push-staged-to git-flatten; do curl -s "https://raw.githubusercontent.com/sartaj/git-aliases/main/$a/install.sh" | bash; done
```

## Available Commands

| Command                                           | Description                                                                      | Individual Install Command                                                                                |
| ------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `git push-staged-to <branch-name> [-m <message>]` | Commit your changes to a new branch from current HEAD                            | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-push-staged-to/install.sh \| bash` |
| `git flatten [-m <message>]`                      | Flatten all commits on current branch back to where it diverged from base branch | `curl -s https://raw.githubusercontent.com/sartaj/git-aliases/main/git-flatten/install.sh \| bash`        |

## Contributing

### Add new script

Add a folder. Each folder should have an `install.sh` script that adds the alias. In the above install all script, add the folder added.

## License

[MIT License](LICENSE)
