# vim-symlink

## Note:
Although this plugin was inspired by [aymericbeaumet/vim-symlink](https://github.com/aymericbeaumet/vim-symlink/actions/workflows/ci.yml),
it is almost completely re-written.

[vim-symlink](https://github.com/jasha10/vim-symlink) enables to
automatically follow the symlinks in Vim or Neovim. This means that when you
edit a pathname that is a symlink, vim will instead open the file using the
resolved target path.

[![demo](./media/demo.gif)](./media/demo.gif)

## Features

- Cross-platform
- Recursive symlinks resolution
- [`vimdiff`](http://vimdoc.sourceforge.net/htmldoc/diff.html) support (still after rewrite?)
- Allow to create new files in symlinked directories
- Make [vim-fugitive](https://github.com/tpope/vim-fugitive) behave properly
  with linked files

## Install

Install with [packer](https://github.com/wbthomason/packer.nvim):

```lua
use { 'jasha10/vim-symlink', branch = 'jasha-dev' }
```

Install with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "jasha10/vim-symlink", branch = 'jasha-dev' }
```

Install with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'jasha10/vim-symlink', { 'branch': 'jasha-dev' }
```

## Usage

Read more about the usage in [the documentation](./doc/symlink.txt).
