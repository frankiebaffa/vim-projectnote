" =======================
" Plugin: projectnote.vim
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================

function! projectnote#PNoteGenerateNewProjNote() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if !filereadable(checkname)
		exec "silent !echo \"\\# " . projname . "\\n\" >> " . checkname
		exec ':redraw!'
	end
endfunction "}}}

function! projectnote#PNoteGenerateIfNotExist() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if !filereadable(checkname)
		call projectnote#PNoteGenerateNewProjNote()
	end
endfunction "}}}

function! projectnote#PNoteGenerateAndGetNote() "{{{
	if g:opennote == ""
		call projectnote#PNoteGenerateIfNotExist()
		call projectnote#PNoteGetNoteIfExist()
	end
endfunction "}}}

function! projectnote#PNoteGetNoteIfExist() "{{{
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
		setlocal fdm=syntax
		silent setlocal noma
		setlocal buftype=nofile
		silent wincmd L
		silent vert res 40
		silent wincmd p
	end
endfunction "}}}

function! projectnote#PNoteToggleNote() "{{{
	if g:opennote == ""
		call projectnote#PNoteGetNoteIfExist()
	elseif g:opennote != ""
		call projectnote#PNoteCloseNote()
	end
endfunction "}}}

function! projectnote#PNoteCloseNote() "{{{
	if g:opennote != ""
		silent exec "sbuffer " . g:opennote
		let notename=expand('%:t')
		silent exec "au BufWinLeave *" . notename . " let g:opennote = \"\""
		silent exec "q!"
		silent wincmd p
	end
endfunction "}}}

function! projectnote#PNoteAddNote(...) "{{{
	let notetext = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("notetext")
cat = nt[0:nt.index(" ")]
nt = nt.replace(cat+" ", "")
with open(vim.eval("g:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

if start > 0:
	addat = -1
	for i in range(start, len(lines)):
			if lines[i] == "\n":
					addat = i
					break

	if addat > -1:
		lines.insert(addat, f"{addat-start}. {nt}\n")
		content = "".join(lines)

		with open(vim.eval("g:opennote"), "w") as f:
				f.write(content)
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! projectnote#PNoteAddCat(...) "{{{
	let newcat = a:000[0]
	python3 << endpy
import vim
lines = []
newcat = vim.eval("newcat")
if " " not in newcat and len(newcat) > 0:
	with open(vim.eval("g:opennote"), "r") as f:
		lines = f.readlines()
		f.close()

	alreadyexists = False
	for line in lines:
		if "[["+newcat+"]]" in line:
			alreadyexists = True
			break

	if not alreadyexists:
		with open(vim.eval("g:opennote"), "a") as f:
				f.write("[["+newcat+"]]\n\n")
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! projectnote#PNoteSortCat() "{{{
	python3 << endpy
import vim
lines = []
with open(vim.eval("g:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

notes={
	"title":"",
	"categories":[],
	"catnotes":{}
}

activecat = None
for line in lines:
	if line == "\n":
		pass
	elif line[0:1] == "#":
		notes["title"] = line
	elif line[0:1] == "[[":
		activecat = line
		notes["categories"].append(line)
		notes["catnotes"][line] = []
		print(notes)
	elif line[0:1].isdigit():
		print(activecat)
		notes["catnotes"][activecat].append(line)

content = f"{notes['title']}\n\n"
notes["categories"].sort()
for cat in notes["categories"]:
	content += f"{cat}\n"
	for note in notes["catnotes"][cat]:
		content += f"{note}\n"
content += "\n"
print(content)
endpy
endfunction "}}}

function! projectnote#PNoteStrikeThroughNote(...) "{{{
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

function! projectnote#PNoteStrikeThroughTodo(...) "{{{
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

" Vim Folder {{{
" vim:fdm=marker
" }}}
