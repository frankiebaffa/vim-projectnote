" Vim Syntax File
" Language: PNote
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

syn region ProjNoteBlock start="^\(\[\[\)\@=" end="^$\n" keepend fold
		\ transparent contains=ProjNoteCat,ProjNoteCatElem,ProjNoteCatStruct

syn region ProjNoteCat start="^\[\[" end="\]\]$" oneline
		\ contained
		\ containedin=ProjNoteBlock

syn region ProjNoteCatElem start="^[0-9]\+\." end="$" keepend oneline
		\ contained
		\ containedin=ProjNoteBlock

syn region ProjNoteCatStruck start="^[0-9]\+\.\s--" end="--$" keepend oneline
		\ contained
		\ containedin=ProjNoteBlock

hi def link ProjNoteTitle Statement
hi def link ProjNoteCat Type
hi def link ProjNoteCatElem Normal
hi def link ProjNoteCatStruck Comment

