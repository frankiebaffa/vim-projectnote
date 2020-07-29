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

syn region ProjNoteBlock start="^\(\[\[\)\@=" end="^$\n"ms=s,me=s keepend fold transparent
		\ contains=ProjNoteCat,ProjNoteCatElem,ProjNoteCatStruct

syn region ProjNoteCat start="^\[\[" end="\]\]$"ms=s+1 oneline
		\ contained
		\ containedin=ProjNoteBlock

syn region ProjNoteCatElem start="^[0-9]\+\." end="$" keepend oneline
		\ contained
		\ containedin=ProjNoteBlock

syn region ProjNoteCatStruck start="^[0-9]\+\.\s--" end="--$" keepend oneline
		\ contained
		\ containedin=ProjNoteBlock

hi def link ProjNoteTitle statement
hi def link ProjNoteCat type
hi def link ProjNoteCatElem preproc
hi def link ProjNoteCatStruck comment

