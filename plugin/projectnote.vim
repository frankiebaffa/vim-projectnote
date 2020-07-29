" =======================
" Plugin: projectnote.vim
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================

" Settings {{{
let g:opennote=""
set switchbuf+=useopen
" }}}

" Command Assignments {{{
command! PNoteOpen :call projectnote#PNoteGenerateAndGetNote()
command! -nargs=1 PNoteAddNote :call projectnote#PNoteAddNote(<f-args>)
command! -nargs=1 PNoteAddCat :call projectnote#PNoteAddCat(<f-args>)
command! -nargs=1 PNoteStrikeNote :call projectnote#PNoteStrikeThroughNote(<f-args>)
command! -nargs=1 PNoteStrikeTodo :call projectnote#PNoteStrikeThroughTodo(<f-args>)
command! PNoteClose :call projectnote#PNoteCloseNote()
command! PNoteToggle :call projectnote#PNoteToggleNote()
command! PNoteSortCat :call projectnote#PNoteSortCat()
" }}}

" Vim Folder {{{
" vim:fdm=marker
" }}}

