" =======================
" Plugin: vim-projectnote
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================

" Functions {{{
function! s:PNoteGenerateNewProjNote() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if !filereadable(checkname)
		exec "silent !echo \"\\# " . projname . "\\n\\n[[todo]]\\n\\n[[notes]]\\n\" >> " . checkname
		exec ':redraw!'
	end
endfunction "}}}

function! s:PNoteGenerateIfNotExist() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if !filereadable(checkname)
		call s:PNoteGenerateNewProjNote()
	end
endfunction "}}}

function! s:PNoteGenerateAndGetNote() "{{{
	if g:opennote == ""
		call s:PNoteGenerateIfNotExist()
		call s:PNoteGetNoteIfExist()
	end
endfunction "}}}

function! s:PNoteGetNoteIfExist() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if filereadable(checkname)
		let g:opennote=checkname
		silent exec "vsplit " . checkname
		silent setlocal syn=projectnote
		silent setlocal nolist
		silent setlocal breakat=" ^I!@*-+;:,./?"
		let &showbreak='+++ '
		setlocal wrap linebreak
		setlocal textwidth=0
		setlocal wrapmargin=0
		silent setlocal noma
		setlocal buftype=nofile
		silent wincmd L
		silent vert res 40
		silent wincmd p
	end
endfunction "}}}

function! s:PNoteToggleNote() "{{{
	if g:opennote == ""
		call s:PNoteGetNoteIfExist()
	elseif g:opennote != ""
		call s:PNoteCloseNote()
	end
endfunction "}}}

function! s:PNoteCloseNote() "{{{
	if g:opennote != ""
		silent exec "sbuffer " . g:opennote
		let notename=expand('%:t')
		silent exec "au BufWinLeave *" . notename . " let g:opennote = \"\""
		silent exec "q!"
		silent wincmd p
	end
endfunction "}}}

function! s:PNoteAddToDo(...) "{{{
	let notetext = a:000[0]
	python3 << endpy
import vim
lines = []
with open(vim.eval("g:opennote"), "r") as f:
		lines = f.readlines()
		f.close()

addat = -1
iadd = 2
for i in range(iadd, len(lines)):
		if lines[i] == "\n":
				addat = i
				break

if addat > 0:
	textto = vim.eval("notetext")
	lines.insert(addat, f"{addat-iadd}. {textto}\n")
	content = "".join(lines)

	with open(vim.eval("g:opennote"), "w") as f:
			f.write(content)
			f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! s:PNoteAddNote(...) "{{{
	let notetext = a:000[0]
	python3 << endpy
import vim
lines = []
with open(vim.eval("g:opennote"), "r") as f:
    lines = f.readlines()
    f.close()

start = -1
for i in range(len(lines)):
    if lines[i] == "[[notes]]\n":
        start = i
        break

if start > 0:
	addat = -1
	for i in range(start, len(lines)):
			if lines[i] == "\n":
					addat = i
					break

	if addat > -1:
		textto = vim.eval("notetext")
		lines.insert(addat, f"{addat-start}. {textto}\n")
		content = "".join(lines)

		with open(vim.eval("g:opennote"), "w") as f:
				f.write(content)
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! s:PNoteStrikeThroughNote(...) "{{{
	let notetostrike = a:000[0]
	python3 << endpy
tostrike = f"{vim.eval('notetostrike')}" + ". "
lines = []
with open(vim.eval('g:opennote'), "r") as f:
	lines = f.readlines()
	f.close()

tolen = len(tostrike)
insection = False
for i in range(len(lines)):
	if not insection and lines[i] == "[[notes]]\n":
		insection = True

	if lines[i][0:tolen] == tostrike and insection:
		s = lines[i]
		lines[i] = s[0:len(tostrike)] + "--" + s[len(tostrike):len(s)-1] + "--" + s[len(s)-1:]
		break

content = "".join(lines)

with open(vim.eval('g:opennote'), "w") as f:
	f.write(content)
	f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! s:PNoteStrikeThroughTodo(...) "{{{
	let notetostrike = a:000[0]
	python3 << endpy
tostrike = f"{vim.eval('notetostrike')}" + ". "
lines = []
with open(vim.eval('g:opennote'), "r") as f:
	lines = f.readlines()
	f.close()

tolen = len(tostrike)
insection = False
for i in range(len(lines)):
	if not insection and lines[i] == "[[todo]]\n":
		insection = True

	if lines[i][0:tolen] == tostrike and insection:
		s = lines[i]
		lines[i] = s[0:len(tostrike)] + "--" + s[len(tostrike):len(s)-1] + "--" + s[len(s)-1:]
		break

content = "".join(lines)

with open(vim.eval('g:opennote'), "w") as f:
	f.write(content)
	f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}
" }}}

" Vim Folder {{{
" vim:fdm=marker
" }}}