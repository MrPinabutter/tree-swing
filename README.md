# Tree Swing 🌳🎯

> A colorful, interactive bash script for merging branches with a beautiful arrow-key menu interface

[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

![Demo](demo.gif)

## ✨ Features

- 🎨 **Beautiful colored interface** - Easy on the eyes with syntax highlighting
- ⌨️ **Arrow-key navigation** - Intuitive menu selection
- 📝 **Configurable branches** - Define your branch shortcuts in a simple text file
- 🚀 **Quick workflow** - Merge branches in seconds
- 🔄 **Smart branch naming** - Automatically creates `for-{slug}/{current-branch}` branches
- 💪 **Force fetch** - Always gets the latest version of target branches

## Installation

### 1. Save the script

Save the script to a file named: `tree-swing`

```bash
# Create a directory for your custom scripts (if you don't have one)
mkdir -p ~/.local/bin

# Save the script there
nano ~/.local/bin/tree-swing
# (paste the script content and save)
```

### 2. Make it executable

```bash
chmod +x ~/.local/bin/tree-swing
```

### 3. Add to PATH

Add `~/.local/bin` to your PATH if it's not already there.

**For Bash** (add to `~/.bashrc` or `~/.bash_profile`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Zsh** (add to `~/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Fish** (add to `~/.config/fish/config.fish`):

```fish
set -gx PATH $HOME/.local/bin $PATH
```

### 4. Reload your shell

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc

# For Fish
source ~/.config/fish/config.fish

# OR just open a new terminal
```

## Configuration

Create a `branches.txt` file in your git repository root with your branch mappings:

```
dev develop
stag staging
prod production
main main
```

Format: `slug branch_name`

Each line defines a slug (shorthand) and the actual branch name.

## Usage

Navigate to your git repository and run:

```bash
tree-swing
```

### What it does:

1. Shows an interactive menu with your configured branch slugs
2. Use **arrow keys** to navigate
3. Press **Enter** to select
4. The script will:
   - Fetch the latest version of the target branch
   - Create a new branch named `for-{slug}/{current-branch}`
   - Merge the target branch into it

### Example workflow:

If you're on branch `feature/new-ui` and select `dev` from the menu:

- Fetches `origin/develop`
- Creates branch `for-dev/feature/new-ui`
- Merges `origin/develop` into it

### Custom branch option:

Select "other" from the menu to manually enter:

- Branch slug
- Branch name

## Troubleshooting

### Command not found

- Make sure `~/.local/bin` is in your PATH
- Verify the script is executable: `ls -l ~/.local/bin/tree-swing`
- Try running with full path: `~/.local/bin/tree-swing`

### branches.txt not found

- Create `branches.txt` in your repository root
- Or modify `CONFIG_FILE` in the script to use a different location

### Menu not displaying correctly

- Make sure your terminal supports ANSI colors
- Try a different terminal emulator if issues persist

## Alternative Installation Locations

You can also install to:

**System-wide** (requires sudo):

```bash
sudo cp tree-swing /usr/local/bin/
sudo chmod +x /usr/local/bin/tree-swing
```

**Current directory only**:

```bash
chmod +x tree-swing
./tree-swing
```

## License

Free to use and modify as needed!
