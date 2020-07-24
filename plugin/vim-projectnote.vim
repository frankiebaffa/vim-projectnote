" vim:fdm=marker

" =======================
" Plugin: vim-projectnote
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================

let g:opennote=""
set switchbuf+=useopen

function! s:PNoteGenerateNewProjNote()"{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if !filereadable(checkname)
		exec "silent !echo \"\\# " . projname . "\\n\\n[[todo]]\\n\\n[[notes]]\\n\" >> " . checkname
		exec ':redraw!'
	end
endfunction"}}}

function! s:PNoteGetProjNote()"{{{
	if g:opennote == ""
		let switchback=@%
		let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
		let checkname=$HOME . "/notes/" . projname . ".pnote"
		if !filereadable(checkname)
			call s:PNoteGenerateNewProjNote()
		end
		if filereadable(checkname)
			let g:opennote=checkname
			silent exec "vsplit " . checkname
			silent exec "wincmd L"
			silent exec "vert res 40"
			silent exec "sbuffer " . switchback
		end
	end
endfunction"}}}

function! s:PNoteAddToDo(...)"{{{
	let switchback = @%
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
	lines.insert(addat, f"t{addat-iadd}. {textto}\n")
	content = "".join(lines)

	with open(vim.eval("g:opennote"), "w") as f:
			f.write(content)
			f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent exec "sbuffer " . switchback
endfunction"}}}

function! s:PNoteAddNote(...)"{{{
	let switchback = @%
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
		lines.insert(addat, f"n{addat-start}. {textto}\n")
		content = "".join(lines)

		with open(vim.eval("g:opennote"), "w") as f:
				f.write(content)
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent exec "sbuffer " . switchback
endfunction"}}}

function! s:PNoteStrikeThroughNote(...)"{{{
	let switchback = @%
	let notetostrike = a:000[0]
	python3 << endpy
tostrike = f"{vim.eval('notetostrike')}" + "."
lines = []
with open(vim.eval("g:opennote"), "r") as f:
    lines = f.readlines()
    f.close()

tolen = len(tostrike)
for i in range(len(lines)):
    if lines[i][0:tolen] == tostrike:
        s = lines[i]
        lines[i] = "--" + s[0:len(s)-1] + "--" + s[len(s)-1:]
        break

content = "".join(lines)

with open(vim.eval("g:opennote"), "w") as f:
    f.write(content)
    f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent exec "sbuffer " . switchback
endfunction"}}}

command! PNoteOpen :call s:PNoteGetProjNote()
command! -nargs=1 PNoteAddTodo :call s:PNoteAddToDo(<f-args>)
command! -nargs=1 PNoteAddNote :call s:PNoteAddNote(<f-args>)
command! -nargs=1 PNoteStrikethrough :call s:PNoteStrikeThroughNote(<f-args>)

