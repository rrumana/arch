# This is where my keybinds will go

This system is a work in progress. I am currently using Hyprland, Tmux, Neovim, so expect many keybinds.
Keybinds will be applied through the appropriate dotfiles, this is just a reference document.

# Hyprland
Leader key is 'Super' (Command on Mac or Windows Key)

## Neovim
Leader key is 'Space'

| Menu Keybind     | Description    |
|------------------|----------------|
| <leader>pv       | Filetree       |
| <leader>pf       | Preview files  |
| <leader>ps       | Search files   |
| <Ctrl-p>         | Github search  |

| Editing Keybind  | Description    |
|------------------|----------------|
| <leader>x        | Clipboard cut  |
| <leader>c        | Clipboard copy |
| <leader>v        | Clipboard paste|
| <Ctrl-x>         | Delete         |
| <Ctrl-c>         | Yank           |
| <Ctrl-v>         | Put            |
| <Ctrl-r>         | Redo           |
| <Ctrl-z>         | Undo           |

```
<leader>pv&nbsp;- Filetree
<leader>pf      - Preview files
<leader>ps      - Search files      (Grep)
<Ctrl-p>        - Github search     (only works in github directory)

<leader>x       - Clipboard cut 	(normal and visual)
<leader>c       - Clipboard copy	(normal and visual)
<leader>v       - Clipboard paste	(normal and visual)
<Ctrl-x>        - Delete		(normal and visual)
<Ctrl-c> 	- Yank                  (normal and visual)
<Ctrl-v> 	- Put                   (normal, insert, and visual)
<Ctrl-r>	- Redo                  (normal and visual)
<Ctrl-z> 	- Undo                  (normal and visual)
```

# Vim
[Operator] [Count] [Motion]

```
I   - navigate to start of line and go into insert mode
w 	- Until the start of the next word, Excluding the first character.
e 	- To the end of the current word, Including the last character.
E 	- To the end of the line, Including the last character.
b   - jump backwards to the start of a word 
B   - jump backwards to the start of a line   
O   - Create a line above and go into insert mode
o   - Create a line below and go into insert mode
```

# Netrw
n  	   - Create new file\
d  	   - Create directory\
r 	   - Rename a file\

# Harpoon
Leader + a      - Harpoon mark	(normal only)\
Ctrl + e        - Harpoon UI	(normal only)\
Ctrl + h 	    - Harpoon 1		(normal only)\
Ctrl + j 	    - Harpoon 2		(normal only)\
Ctrl + k 	    - Harpoon 3		(normal only)\
Ctrl + l 	    - Harpoon 4		(normal only)\


## Tmux
Leader key is 'Ctrl + s'

## Other
