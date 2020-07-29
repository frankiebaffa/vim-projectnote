" Vim Syntax File
" Language: Marktwo
" Maintainer: Frankie Baffa
" Latest Revision 20 Feb 2020

if exists("b:current_syntax")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

syntax spell toplevel

syn case ignore

syn match ProjNoteTitle "^#\s.\+$" keepend

syn match ProjNoteCat "^\[\[todo\]\]$"
syn match ProjNoteCat "^\[\[notes\]\]$"

syn match ProjNoteCatElem "^[0-9]\+\.\s.\+$" keepend

syn match ProjNoteCatStruck "^[0-9]\+\.\s--.\+--$" keepend

hi def link ProjNoteTitle statement
hi def link ProjNoteCat type
hi def link ProjNoteCatElem preproc
hi def link ProjNoteCatStruck comment

