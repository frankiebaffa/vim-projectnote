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
command! -nargs=1 PNoteStrike :call projectnote#PNoteStrike(<f-args>)
command! -nargs=1 PNoteUndoStrike :call projectnote#PNoteUndoStrike(<f-args>)
command! PNoteClose :call projectnote#PNoteCloseNote()
command! PNoteToggle :call projectnote#PNoteToggleNote()
command! PNoteSort :call projectnote#PNoteSort()
command! -nargs=1 PNoteEdit :call projectnote#PNoteEdit(<f-args>)
command! -nargs=1 PNoteDelete :call projectnote#PNoteDelete(<f-args>)
command! -nargs=1 PNoteDeleteCat :call projectnote#PNoteDeleteCat(<f-args>)
command! -nargs=1 PNoteEditCat :call projectnote#PNoteEditCat(<f-args>)
command! PNoteExpandAll :call projectnote#PNoteExpandAll()
command! -nargs=1 PNoteExpandCat :call projectnote#PNoteExpandCat(<f-args>)
command! PNoteCollapseAll :call projectnote#PNoteCollapseAll()
command! -nargs=1 PNoteCollapseCat :call projectnote#PNoteCollapseCat(<f-args>)
" }}}
" Autocmd {{{
" force size of window on file open / close
"au BufWinLeave,BufWinEnter,BufLeave,BufEnter,WinLeave,WinEnter * call projectnote#PNoteForceSize()
" }}}
" Vim Folder {{{
" vim:fdm=marker
" }}}

