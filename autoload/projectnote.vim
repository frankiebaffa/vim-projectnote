" =======================
" Plugin: projectnote.vim
" Author: Frankie Baffa
" Last Edit: 20200724
" =======================
let s:opennote = ""
let s:prevbuf = 0

function! projectnote#NotOpen() "{{{
	if s:opennote != ""
		return 0
	else
		return 1
	endif
endfunction " }}}
function! projectnote#ToNote() " {{{
	if projectnote#NotOpen()
		return
	endif
	let s:prevbuf=bufnr('%')
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	silent exec "sbuffer " . checkname
endfunction " }}}
function! projectnote#ToPrev() " {{{
	if projectnote#NotOpen()
		return
	endif
	silent exec "sbuffer " . s:prevbuf
	let s:prevbuf=0
endfunction " }}}
function! projectnote#GetFilenameHash() " {{{
	let filepath=expand("%:p")

	python3 << endpy
import vim
import hashlib
filepath = vim.eval('filepath')
hashname = hashlib.sha256(bytes(filepath, 'ascii')).hexdigest()
vim.command(f"let hashname='{hashname}'")
endpy

return hashname
endfunction " }}}
function! projectnote#MakeView() " {{{
	if projectnote#NotOpen()
		return
	endif
	call projectnote#ToNote()
	setlocal ma buftype=
	setlocal filetype=projectnote
	let filename=projectnote#GetFilenameHash()
	let fullpath=$HOME . "/.vim/view/" . filename
	exec "mkview! " . fullpath
	setlocal buftype=nofile noma
	call projectnote#ToPrev()
endfunction " }}}
function! projectnote#LoadView() " {{{
	if projectnote#NotOpen()
		return
	endif
	call projectnote#ToNote()
	let filename=projectnote#GetFilenameHash()
	let fullpath=$HOME . "/.vim/view/" . filename
	if filereadable(fullpath)
		exec "source " . fullpath
	endif
	setlocal buftype=nofile noma
	call projectnote#ToPrev()
endfunction " }}}

function! projectnote#PNoteGenerateNewProjNote() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	exec "silent !echo \"\\# " . projname . "\\n\" >> " . checkname
	exec ':redraw!'
endfunction "}}}
function! projectnote#PNoteGenerateIfNotExist() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	let test=!filereadable(checkname)
	if !filereadable(checkname)
		call projectnote#PNoteGenerateNewProjNote()
	end
endfunction "}}}
function! projectnote#PNoteForceSize() "{{{
	if s:opennote != ""
		silent exec "sbuffer " . s:opennote . " | vert res 40 | wincmd p"
	end
endfunction
" }}}
function! projectnote#PNoteGenerateAndGetNote() "{{{
	call projectnote#PNoteGenerateIfNotExist()
	call projectnote#PNoteGetNoteIfExist()
endfunction "}}}
function! projectnote#PNoteGetNoteIfExist() "{{{
	let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
	let checkname=$HOME . "/notes/" . projname . ".pnote"
	if filereadable(checkname)
		let s:prevbuf=bufnr('%')
		silent exec "vsplit " . checkname
		let s:opennote=checkname
		silent setlocal syn=projectnote
		silent setlocal nolist
		silent setlocal breakat=" ^I!@*-+;:,./?"
		let &showbreak='+++ '
		setlocal wrap linebreak
		setlocal textwidth=0
		setlocal wrapmargin=0
		setlocal fdm=syntax
		setlocal buftype=nofile noma nonumber colorcolumn=0
		silent wincmd L
		silent vert res 40
		call projectnote#ToPrev()
		call projectnote#LoadView()
	end
endfunction "}}}
function! projectnote#PNoteExpandAll() "{{{
	if projectnote#NotOpen()
		return
	endif
	call projectnote#ToNote()
	silent exec "normal zR"
	call projectnote#ToPrev()
	call projectnote#MakeView()
endfunction "}}}
function! projectnote#PNoteCollapseAll() "{{{
	if projectnote#NotOpen()
		return
	endif
	call projectnote#ToNote()
	silent exec "normal zM"
	call projectnote#ToPrev()
	call projectnote#MakeView()
endfunction "}}}
function! projectnote#PNoteExpandCat(...) "{{{
	if projectnote#NotOpen()
		return
	endif
	let category = a:000[0]
	call projectnote#ToNote()
	silent exec "normal gg"
	silent let @/="\\[\\[" . category . "\\]\\]"
	silent exec "normal nzo"
	silent exec "noh"
	call projectnote#ToPrev()
	call projectnote#MakeView()
endfunction "}}}
function! projectnote#PNoteCollapseCat(...) "{{{
	if projectnote#NotOpen()
		return
	endif
	let category = a:000[0]
	call projectnote#ToNote()
	silent exec "normal gg"
	silent let @/="\\[\\[" . category . "\\]\\]"
	silent exec "normal nzc"
	silent exec "noh"
	call projectnote#ToPrev()
	call projectnote#MakeView()
endfunction "}}}
function! projectnote#PNoteToggleNote() "{{{
	if s:opennote == ""
		call projectnote#PNoteGetNoteIfExist()
	elseif s:opennote != ""
		call projectnote#PNoteCloseNote()
	end
endfunction "}}}
function! projectnote#PNoteCloseNote() "{{{
	if projectnote#NotOpen()
		return
	endif
	call projectnote#ToNote()
	let notename=expand('%:t')
	silent exec "au BufWinLeave " . notename . " let s:opennote = \"\""
	silent exec "au BufWinLeave " . notename . " call projectnote#MakeView()"
	silent exec "q!"
	call projectnote#ToPrev()
endfunction "}}}
function! projectnote#PNoteAddNote(...) "{{{
	let notetext = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("notetext")
cat = nt[0:nt.index(" ")]
nt = nt.replace(cat+" ", "")
with open(vim.eval("s:opennote"), "r") as f:
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

		with open(vim.eval("s:opennote"), "w") as f:
				f.write(content)
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteAddCat(...) "{{{
	let newcat = a:000[0]
	python3 << endpy
import vim
lines = []
newcat = vim.eval("newcat")
if " " not in newcat and len(newcat) > 0:
	with open(vim.eval("s:opennote"), "r") as f:
		lines = f.readlines()
		f.close()

	alreadyexists = False
	for line in lines:
		if "[["+newcat+"]]" in line:
			alreadyexists = True
			break

	if not alreadyexists:
		with open(vim.eval("s:opennote"), "a") as f:
				f.write("[["+newcat+"]]\n\n")
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteEdit(...) "{{{
	let noteedit = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("noteedit")
cat = nt[0:nt.index(" ")]
nt = nt.replace(cat+" ", "")
num = nt[0:nt.index(" ")]
nt = nt.replace(num+" ", "")
num = f"{num}."

with open(vim.eval("s:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

if start > 0:
	ischanged = False
	for i in range(start, len(lines)):
		if lines[i][0:len(num)] == num:
			lines[i] = f"{num} {nt}\n"
			ischanged = True
			break
		elif lines[i][0:2] == "[[" and lines[i] != "[["+cat+"]]\n":
			break

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteInsert(...) "{{{
	let noteedit = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("noteedit")
cat = nt[0:nt.index(" ")]
nt = nt.replace(cat+" ", "")
num = nt[0:nt.index(" ")]
nt = nt.replace(num+" ", "")
num = f"{num}."

with open(vim.eval("s:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

if start > 0:
	ischanged = False
	for i in range(start, len(lines)):
		if lines[i][0:len(num)] == num:
			lines.insert(i, f"{num} {nt}\n")
			ischanged = True
		elif lines[i][0:2] == "[[" and lines[i] != "[["+cat+"]]\n":
			break
		elif ischanged:
			iofnan = 1
			s = ''
			while lines[i][0:iofnan].isdigit():
				s = lines[i][0:iofnan]
				print(s)
				iofnan += 1
			iofnan -= 1
			orig = s
			sint = int(s)+1
			s = str(sint)
			print(s)
			lines[i] = lines[i].replace(orig, s, 1)

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteDelete(...) "{{{
	let catnum = a:000[0]
	python3 << endpy
import vim
lines = []
cn = vim.eval("catnum")
cat = cn[0:cn.index(" ")]
cn = cn.replace(cat+" ", "")
num = cn[0:len(cn)]
num = f"{num}."

if num != None and len(num) > 0 and num[0:num.index(".")].isdigit():
	with open(vim.eval("s:opennote"), "r") as f:
		lines = f.readlines()
		f.close()
	
	start = -1
	for i in range(len(lines)):
		if lines[i] == "[["+cat+"]]\n":
			start = i
			break

	if start > 0:
		ischanged = True
		lines_cp = lines.copy()
		for i in range(start, len(lines_cp)):
			line = lines_cp[i]
			if line[0:len(num)] == num:
				lines.pop(i)
				ischanged = True
			elif line[0:2] == "[[" and line != "[["+cat+"]]\n":
				break
			elif ischanged and line[0:1].isdigit():
				numstop = line.index(".")
				integer = int(line[0:numstop])
				integer -= 1
				lines[i-1] = lines[i-1].replace(line[0:numstop], f"{integer}")

		if ischanged:
			with open(vim.eval("s:opennote"), "w") as f:
					f.write("".join(lines))
					f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteDeleteCat(...) "{{{
	let cat = a:000[0]
	python3 << endpy
import vim
lines = []
cat = vim.eval("cat")

with open(vim.eval("s:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

ischanged = False
dcount = 0
if start > 0:
	lines_cp = lines.copy()
	for i in range(start, len(lines_cp)):
		line = lines_cp[i]
		ischanged = True
		if line[0:1].isdigit() or line == "[["+cat+"]]\n" or line == "\n":
			lines.pop(i-dcount)
			dcount += 1
			if line == "\n":
				break

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
			f.write("".join(lines))
			f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteEditCat(...) "{{{
	let catedit = a:000[0]
	python3 << endpy
import vim
lines = []
catedit = vim.eval("catedit")
oldcat = nt[0:nt.index(" ")]
catedit = catedit.replace(oldcat+" ", "")
newcat = catedit[0:len(catedit)]

if newcat != None and len(newcat) > 0:
	with open(vim.eval("s:opennote"), "r") as f:
		lines = f.readlines()
		f.close()

	ischanged = False
	for i in range(len(lines)):
		if lines[i] == "[["+oldcat+"]]\n":
			lines[i] = "[["+newcat+"]]\n"
			ischanged = True
			break

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteSort() "{{{
	python3 << endpy
import vim
lines = []
with open(vim.eval("s:opennote"), "r") as f:
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
	elif line[0:2] == "[[":
		activecat = line
		notes["categories"].append(line)
		notes["catnotes"][line] = []
	elif line[0:1].isdigit():
		notes["catnotes"][activecat].append(line)

content = f"{notes['title']}\n"
notes["categories"].sort()
for cat in notes["categories"]:
	content += f"{cat}"
	for note in notes["catnotes"][cat]:
		content += f"{note}"
	content += "\n"
content += ""

with open(vim.eval("s:opennote"), "w") as f:
		f.write(content)
		f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteStrike(...) "{{{
	let noteedit = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("noteedit")
cat = nt[0:nt.index(" ")]
nt = nt.replace(cat+" ", "")
num = nt[0:len(nt)]
num = f"{num}."

with open(vim.eval("s:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

if start > 0:
	ischanged = False
	for i in range(start, len(lines)):
		if lines[i][0:len(num)] == num:
			lines[i] = lines[i].replace(f"{num} ", f"{num} --").replace("\n", "--\n")
			ischanged = True
			break
		elif lines[i][0:2] == "[[" and lines[i] != "[["+cat+"]]\n":
			break

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
function! projectnote#PNoteUndoStrike(...) "{{{
	let noteedit = a:000[0]
	python3 << endpy
import vim
lines = []
nt = vim.eval("noteedit")
cat = None
num = None
try:
	cat = nt[0:nt.index(" ")]
	nt = nt.replace(cat+" ", "")
	num = nt[0:len(nt)]
	num = f"{num}."
except:
	print("Arguments <Category> <Number> must be included")
	return

with open(vim.eval("s:opennote"), "r") as f:
	lines = f.readlines()
	f.close()

start = -1
for i in range(len(lines)):
	if lines[i] == "[["+cat+"]]\n":
		start = i
		break

if start > 0:
	ischanged = False
	for i in range(start, len(lines)):
		if lines[i][0:len(num)] == num:
			lines[i] = lines[i].replace(f"{num} --", f"{num} ").replace("--\n", "\n")
			ischanged = True
			break
		elif lines[i][0:2] == "[[" and lines[i] != "[["+cat+"]]\n":
			break

	if ischanged:
		with open(vim.eval("s:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	call projectnote#ToNote()
	silent exec "e"
	call projectnote#ToPrev()
	call projectnote#LoadView()
endfunction "}}}
" Vim Folder {{{
" vim:fdm=marker
" }}}
