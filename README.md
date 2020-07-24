# vim-projectnote

Project Note is a simple, straightforward plugin for vim. The primary
function is to generate a template note file for the project being worked
on and to also have the ability to automate the addition and completion of
todos and notes.

Project Note uses python3 embedded in vimscript to parse / edit the notes
file.

## Commands

The commands that I highly recommend binding to your keyboard are (where
XXXX represents your desired hotkey):
```vim
nmap XXXX :PNoteOpen<cr>
nmap XXXX :PNoteAddTodo<space>
nmap XXXX :PNoteAddNote<space>
nmap XXXX :PNoteStrikethrough<space>
```

`PNoteOpen` will check, create and open the note file for your specified
project. The filename and title of the note file will be based on the
directory you have opened vim.

`PNoteAddTodo` creates a new entry in the 'todo' section of the note. The
number of this todo will be incremented from the previous maximum + 1. This
command takes vimscripts k-args:
```vim
PNoteAddTodo this is a new todo
```

`PNoteAddNote` creates a new entry in the 'notes' section of the note. The
number of this note will be incremented form the previous maximum + 1. This
command takes vimscripts k-args:
```vim
PNoteAddNote this is a new note
```

`PNoteStrikethrough` marks a todo or note as complete. This command takes an
argument which signifies the todo or note number:
```vim
PNOteStrikethrough t2
```

## Installation

Install using your package manager or using vim's built-in.  

vim:
```bash
mkdir -p ~/.vim/pack/frankiebaffa/start;
cd ~/.vim/pack/frankiebaffa/start;
git clone https://github.com/frankiebaffa/vim-projectnote.git;
vim -u NONE -c "helptags fugitive/doc" -c q;
```

vim-plug (add to the plug section of your .vimrc):
```vim
Plug 'https://github.com/frankiebaffa/vim-projectnote.git'
```

