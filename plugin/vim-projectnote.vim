" =======================
" Plugin: vim-projectnote
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================

" Settings {{{
let g:opennote=""
set switchbuf+=useopen
" }}}

" Command Assignments {{{
command! PNoteOpen :call s:PNoteGenerateAndGetNote()
command! -nargs=1 PNoteAddTodo :call s:PNoteAddToDo(<f-args>)
command! -nargs=1 PNoteAddNote :call s:PNoteAddNote(<f-args>)
command! -nargs=1 PNoteStrikeNote :call s:PNoteStrikeThroughNote(<f-args>)
command! -nargs=1 PNoteStrikeTodo :call s:PNoteStrikeThroughTodo(<f-args>)
command! PNoteClose :call s:PNoteCloseNote()
command! PNoteToggle :call s:PNoteToggleNote()
" }}}

" Vim Folder {{{
" vim:fdm=marker
" }}}

