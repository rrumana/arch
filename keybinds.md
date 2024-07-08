# This is where my keybinds will go

This system is a work in progress. I am currently using Hyprland, Tmux, Neovim, so expect many keybinds.
Keybinds will be applied through the appropriate dotfiles, this is just a reference document.

I am actually not a very good typist, and I have implemented all of these keybinds in the last few months, so this is a big challenge for me. Hopefully after a few more months of struggling I will be able to efficiently navigate my new setup.

My goal is to refine these keybinds, like making new always \<leader\> n, rename always \<leader\> r, and so forth because that will greatly simplify the config since I only need to rememeber which application I am dealing with and apply the correct leader key. I just love piling new work on for myself.

# Hyprland
Leader key is 'Super' (Command on Mac or Windows Key)

| Hyprland Keybind | Description |
|------------------|-------------|
| \<leader\> t     | Alacritty   |
| \<leader\> q     | Kill window |
| \<leader\> l     | Lock screen |
| \<leader\> m     | Logout      |
| \<leader\> M     | Force quit |
| \<leader\> f     | Fullscreen  |
| \<leader\> d     | Dolphin     |
| \<leader\> v     | Toggle floating |
| \<leader\> n     | Wofi        |
| \<leader\> p     | Pseudo Dwindle     |
| \<leader\> j     | Togglesplit Dwindle     |
| \<leader\> s     | Screenshot  |
| \<ALT\> v        | Clipboard manager |

| Move & Focus  Keybind | Description |
|-----------------------|-------------|
| \<leader\> l          | Move focus left |
| \<leader\> r          | Move focus right | 
| \<leader\> u          | Move focus up |
| \<leader\> d          | Move focus down |
| \<leader\> 1-10       | Move focus to workspace 1-10 |
| \<leader\> SHIFT 1-10 | Move window to workspace 1-10 |

| Mouse Keybind | Description |
|---------------|-------------|
| \<leader\> mouse_down | Go up one workspace |
| \<leader\> mouse_up   | Go down one workspace |
| \<leader\> mouse_left | Move window |
| \<leader\> mouse_right| Resize window |

## Neovim
The following keybinds are all for my Neovim setup, which is losely based off of the Primeagen's config. He is an awesome creator and you should go check out his channel.

Leader key for this section is 'Space'

| Menu Keybind     | Description    |
|------------------|----------------|
| \<leader\> pv    | Filetree       |
| \<leader\> pf    | Preview files  |
| \<leader\> ps    | Search files   |
| \<Ctrl-p\>       | Github search  |

| Editing Keybind  | Description    |
|------------------|----------------|
| \<leader\> x     | Clipboard cut  |
| \<leader\> c     | Clipboard copy |
| \<leader\> v     | Clipboard paste|
| \<Ctrl-x\>       | Delete         |
| \<Ctrl-c\>       | Yank           |
| \<Ctrl-v\>       | Put            |
| \<Ctrl-r\>       | Redo           |
| \<Ctrl-z\>       | Undo           |


| NetRW Keybind | Description |
|---------------|-------------|
| n             | Create file  |
| d             | Create directory |
| r             | Rename file  |

| Harpoon Keybind | Description |
|-----------------|-------------|
| \<leader\> a    | Harpoon mark |
| \<Ctrl-e\>      | Harpoon UI   |
| \<Ctrl-h\>      | Harpoon 1    |
| \<Ctrl-j\>      | Harpoon 2    |
| \<Ctrl-k\>      | Harpoon 3    |
| \<Ctrl-l\>      | Harpoon 4    |

# Vim
[Operator] [Count] [Motion]

| Operator | Description |
|----------|-------------|
| i        | Insert       |
| I        | Insert at start of line |
| a        | Append       |
| A        | Append at end of line |
| w        | start of next word  |
| e        | End of word  |
| E        | End of line  |
| b        | Start of word|
| B        | Start of line|
| o        | New line below |
| O        | New line above |

## Tmux
Tmux is completely new to my config as of the writing of this document. It might seem silly to keep piling on new keybinds when I am still learning the old ones, but there's no better way to learn than to jump off of the deep end right?

Leader key is '\<Ctrl-s\>'

| Session Command | Description |
|-----------------|-------------|
| tmux            | Start tmux  |
| tmux new -s     | Start new session by name |
| tmux a          | Attatch session |
| tmux a -t       | Attatch session by name |
| tmux kill-ses   | Kill current session |
| tmux kill-session -t | Kill session by name |
| \<leader\> $    | Rename session |
| \<leader\> D    | Detatch session |
| \<leader\> )    | next session |
| \<leader\> (    | previous sessions |


| Window Keybind | Description |
|----------------|-------------|
| \<leader\> c    | Create window |
| \<leader\> n    | Next window   |
| \<leader\> p    | Previous window|
| \<leader\> l    | Last window   |
| \<leader\> 0-9  | Switch to window 0-9 |
| \<leader\> '    | Select windows by name |
| \<leader\> .    | Change window number  |
| \<leader\> ,    | Rename window  |
| \<leader\> F    | search windows        |
| \<leader\> &    | Kill window  |

| Pane Keybind   | Description |
|----------------|-------------|
| \<leader\> v    | Vertical split |
| \<leader\> h    | Horizontal split|
| \<leader\> h    | Move to pane to the right |
| \<leader\> j    | Move down to pane |
| \<leader\> k    | Move up to pane |
| \<leader\> l    | Move to pane to the left  |
| \<leader\> X    | Kill pane |


## Other

Other keybinds will be added here in the future. This is probably enough to learn for now

