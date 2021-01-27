" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowInit")
  finish
endif
let g:barowInit = 1

let g:barowDefault = {
      \'modes': {
      \  'normal': [ ' ', 'BarowNormal' ],
      \  'insert': [ 'i', 'BarowInsert' ],
      \  'replace': [ 'r', 'BarowReplace' ],
      \  'visual': [ 'v', 'BarowVisual' ],
      \  'v-line': [ 'l', 'BarowVisual' ],
      \  'v-block': [ 'b', 'BarowVisual' ],
      \  'select': [ 's', 'BarowVisual' ],
      \  'command': [ 'c', 'BarowCommand' ],
      \  'shell-ex': [ '!', 'BarowCommand' ],
      \  'terminal': [ 't', 'BarowTerminal' ],
      \  'prompt': [ 'p', 'BarowNormal' ],
      \  'inactive': [ ' ', 'BarowModeNC' ]
      \},
      \'buf_name': {
      \  'empty': '',
      \  'highlight': [ 'BarowBufName', 'BarowBufNameNC' ]
      \},
      \'read_only': {
      \  'value': 'ro',
      \  'highlight': [ 'BarowRO', 'BarowRONC' ]
      \},
      \'buf_changed': {
      \  'value': '*',
      \  'highlight': [ 'BarowChange', 'BarowChangeNC' ]
      \},
      \'tab_changed': {
      \  'value': '*',
      \  'highlight': [ 'BarowTChange', 'BarowTChangeNC' ]
      \},
      \'line_percent': {
      \  'highlight': [ 'BarowLPercent', 'BarowLPercentNC' ]
      \},
      \'row_col': {
      \  'highlight': [ 'BarowRowCol', 'BarowRowColNC' ]
      \},
      \'modules': []
      \}

function! s:NormalizeConfig()
  if !exists("g:barow") || type(g:barow) != 4
    let g:barow = g:barowDefault
    return
  endif
	for key in keys(g:barowDefault)
	   if !has_key(g:barow, key) || type(g:barowDefault[key]) != type(g:barow[key])
       let g:barow[key] = g:barowDefault[key]
     endif
	endfor
endfunction

call s:NormalizeConfig()

augroup barow
  autocmd!
  autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call barow#update()
augroup END

function s:Hi(group, fg, ...)
  " arguments: group, fg, bg, style
  if a:0 >= 1
    let bg=a:1
  else
    let bg=s:p.null
  endif
  if a:0 >= 2 && strlen(a:2)
    let style=a:2
  else
    let style='NONE'
  endif
  let hiList = [
        \ 'hi', a:group,
        \ 'ctermfg=' . a:fg[1],
        \ 'guifg=' . a:fg[0],
        \ 'ctermbg=' . bg[1],
        \ 'guibg=' . bg[0],
        \ 'cterm=' . style,
        \ 'gui=' . style
        \ ]
  execute join(hiList)
endfunction

let s:p={
      \ 'null': ['NONE', 'NONE'],
      \ 'statusLine': ['#313335', 237],
      \ 'statusLineFg': ['#BBBBBB', 250],
      \ 'statusLineNC': ['#787878', 243],
      \ 'tabLineFg': ['#A9B7C6', 145],
      \ 'tabLineSel': ['#4E5254', 239],
      \ 'UIBlue': ['#3592C4', 67],
      \ 'UIGreen': ['#499C54', 71],
      \ 'UIRed': ['#C75450', 131],
      \ 'UIBrown': ['#93896C', 102],
      \ 'UIOrange': ['#BE9117', 136]
      \ }
call s:Hi('StatusLine', s:p.statusLineFg, s:p.statusLine)
call s:Hi('StatusLineNC', s:p.statusLineNC, s:p.statusLine)
call s:Hi('TabLine', s:p.statusLineFg, s:p.statusLine)
call s:Hi('TabLineFill', s:p.statusLine, s:p.statusLine)
call s:Hi('TabLineSel', s:p.tabLineFg, s:p.tabLineSel)
call s:Hi('BarowBufName', s:p.statusLineFg, s:p.statusLine, 'italic')
call s:Hi('BarowBufNameNC', s:p.statusLineNC, s:p.statusLine, 'italic')
call s:Hi('BarowChange', s:p.UIBrown, s:p.statusLine)
call s:Hi('BarowChangeNC', s:p.statusLineNC, s:p.statusLine)
call s:Hi('BarowTChangeNC', s:p.UIBrown, s:p.statusLine)
call s:Hi('BarowTChange', s:p.UIBrown, s:p.tabLineSel)
call s:Hi('BarowRO', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowRONC', s:p.statusLineNC, s:p.statusLine, 'bold')
hi link BarowLPercent StatusLine
hi link BarowLPercentNC StatusLineNC
hi link BarowRowCol StatusLine
hi link BarowRowColNC StatusLineNC
call s:Hi('BarowNormal', s:p.statusLineFg, s:p.statusLine, 'bold')
call s:Hi('BarowInsert', s:p.UIGreen, s:p.statusLine, 'bold')
call s:Hi('BarowReplace', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowVisual', s:p.UIBlue, s:p.statusLine, 'bold')
call s:Hi('BarowCommand', s:p.UIBrown, s:p.statusLine, 'bold')
call s:Hi('BarowTerminal', s:p.UIGreen, s:p.statusLine, 'bold')
hi link BarowMode BarowNormal
hi link BarowModeNC StatusLineNC
call s:Hi('BarowError', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowWarn', s:p.UIOrange, s:p.statusLine)
call s:Hi('BarowInfo', s:p.UIBrown, s:p.statusLine)
call s:Hi('BarowHint', s:p.statusLineNC, s:p.statusLine)

let &cpo = s:save_cpo
unlet s:save_cpo
