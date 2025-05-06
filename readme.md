# Git Aliases

A collection of useful Git aliases and custom commands to enhance your Git workflow.

## Quick Install

Install all aliases with a single command
```bash
curl -s https://raw.githubusercontent.com/sartaj/git-alises/refs/heads/main/install.sh | bash
```

## Available Commands

| Command | Description |
|---------|-------------|
| `git committo <branch-name> [-m <message>]` | Push staged changes to a new branch without switching branches |

## Features

- **Easy Installation**: One command to install all aliases
- **Configurable**: Set your preferred default base branch
- **Modular**: Each command is a separate script for easy maintenance
- **Extensible**: Simple structure for adding new commands
- **Seamless Integration**: Works with standard Git commands

## Requirements

- Git (version 2.20 or higher recommended)
- Bash shell
- curl

## Configuration

The system's behavior can be configured by editing `~/.git-aliases/aliases.conf`. 

### Default Base Branch

By default, commands use `master` as the base branch. You can change this by setting:

```
@default_base_branch=main
```

This is useful for repositories that use `main` or other names for their default branch.

## Command Details

### git committo

Push staged changes to a new branch without switching from your current branch.

```bash
git committo <new-branch-name> [-m "commit message"]
```

**Parameters:**
- `<new-branch-name>`: Name of the new branch to create
- `-m, --message`: Optional commit message (defaults to "update")

**Example:**
```bash
# Stage some changes
git add file1.txt file2.txt

# Create a new branch with those changes
git committo feature/new-feature -m "Add new feature files"
```

**What it does:**
1. Creates a new branch from your default base branch
2. Applies your staged changes to that branch
3. Commits the changes with your message
4. Pushes the new branch to origin
5. Leaves your current branch and working directory untouched

This is perfect for when you've staged changes but realize they should be in a new branch.

## Adding Your Own Commands

1. Create a script in the `scripts` directory
2. Add an entry to `aliases.conf`
3. Run the update script

See the existing scripts for examples of how to structure your commands.

## Updating

To update all aliases to the latest version:

```bash
~/.git-aliases/update.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)
