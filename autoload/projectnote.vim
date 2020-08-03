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

function! projectnote#PNoteForceSize() "{{{
	if g:opennote != ""
		silent exec "sbuffer " . g:opennote . " | vert res 40 | wincmd p"
	end
endfunction
" }}}

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

function! projectnote#PNoteExpandAll() "{{{
	if g:opennote != ""
		let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
		let checkname=$HOME . "/notes/" . projname . ".pnote"
		silent exec "sbuffer " . checkname
		silent exec "normal zR"
		silent exec "wincmd p"
	end
endfunction "}}}

function! projectnote#PNoteCollapseAll() "{{{
	if g:opennote != ""
		let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
		let checkname=$HOME . "/notes/" . projname . ".pnote"
		silent exec "sbuffer " . checkname
		silent exec "normal zM"
		silent exec "wincmd p"
	end
endfunction "}}}

function! projectnote#PNoteExpandCat(...) "{{{
	if g:opennote != ""
		let category = a:000[0]
		let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
		let checkname=$HOME . "/notes/" . projname . ".pnote"
		silent exec "sbuffer " . checkname
		silent exec "normal gg"
		silent let @/="\\[\\[" . category . "\\]\\]"
		silent exec "normal nzo"
		silent exec "noh"
		silent exec "wincmd p"
	end
endfunction "}}}

function! projectnote#PNoteCollapseCat(...) "{{{
	if g:opennote != ""
		let category = a:000[0]
		let projname=split(getcwd(), "/")[len(split(getcwd(), "/"))-1]
		let checkname=$HOME . "/notes/" . projname . ".pnote"
		silent exec "sbuffer " . checkname
		silent exec "normal gg"
		silent let @/="\\[\\[" . category . "\\]\\]"
		silent exec "normal nzc"
		silent exec "noh"
		silent exec "wincmd p"
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

with open(vim.eval("g:opennote"), "r") as f:
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
		with open(vim.eval("g:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
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
	with open(vim.eval("g:opennote"), "r") as f:
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
			with open(vim.eval("g:opennote"), "w") as f:
					f.write("".join(lines))
					f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! projectnote#PNoteDeleteCat(...) "{{{
	let cat = a:000[0]
	python3 << endpy
import vim
lines = []
cat = vim.eval("cat")

with open(vim.eval("g:opennote"), "r") as f:
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
		with open(vim.eval("g:opennote"), "w") as f:
			f.write("".join(lines))
			f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
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
	with open(vim.eval("g:opennote"), "r") as f:
		lines = f.readlines()
		f.close()

	ischanged = False
	for i in range(len(lines)):
		if lines[i] == "[["+oldcat+"]]\n":
			lines[i] = "[["+newcat+"]]\n"
			ischanged = True
			break

	if ischanged:
		with open(vim.eval("g:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

function! projectnote#PNoteSort() "{{{
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

with open(vim.eval("g:opennote"), "w") as f:
		f.write(content)
		f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
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

with open(vim.eval("g:opennote"), "r") as f:
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
		with open(vim.eval("g:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
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

with open(vim.eval("g:opennote"), "r") as f:
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
		with open(vim.eval("g:opennote"), "w") as f:
				f.write("".join(lines))
				f.close()
endpy
	silent exec "sbuffer " . g:opennote
	silent exec "e"
	silent wincmd p
endfunction "}}}

" Vim Folder {{{
" vim:fdm=marker
" }}}
