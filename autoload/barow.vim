" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowAutoload")
  finish
endif
let g:barowAutoload = 1

function! Bufname()
  let bufname = bufname("%")
  if bufname("%") == ""
    return get(g:barow.buf_name, "empty", g:barowDefault.buf_name.empty)
  endif
  return split(bufname, "/")[-1]
endfunction

function! ReadOnly()
  let filetype = getbufvar("%", "&filetype")
  if (&readonly || !&modifiable) && filetype !~? 'help\|man'
    return get(g:barow.read_only, "value", g:barowDefault.read_only.value)
  endif
  return ""
endfunction

function! BufChanged()
  let bufinfo = get(getbufinfo("%"), 0, { 'changed': 0 })
  if bufinfo.changed
    return get(g:barow.buf_changed, "value", g:barowDefault.buf_changed.value)
  endif
  return ""
endfunction

function! Mode()
  let mode = mode()
  let modeMap = g:barow.modes
  if mode =~? '^n'
    return get(modeMap, "normal", g:barowDefault.modes.normal)
  elseif mode =~? '^i'
    return get(modeMap, "insert", g:barowDefault.modes.insert)
  elseif mode =~# '^R'
    return get(modeMap, "replace", g:barowDefault.modes.replace)
  elseif mode ==# 'v'
    return get(modeMap, "visual", g:barowDefault.modes.visual)
  elseif mode ==# 'V'
    return get(modeMap, "v-line", g:barowDefault.modes["v-line"])
  elseif mode == ''
    return get(modeMap, "v-block", g:barowDefault.modes["v-block"])
  elseif mode =~? '^c'
    return get(modeMap, "command", g:barowDefault.modes.command)
  elseif mode == 't'
    return get(modeMap, "terminal", g:barowDefault.modes.terminal)
  elseif mode == '!'
    return get(modeMap, "shell-ex", g:barowDefault.modes["shell-ex"])
  elseif mode =~? '^r'
    return get(modeMap, "prompt", g:barowDefault.modes.prompt)
  elseif mode =~? '^s\|'
    return get(modeMap, "select", g:barowDefault.modes.select)
  endif
  return mode
endfunction

function! SetModeHi()
  let [mode, higroup] = Mode()
  execute("hi link BarowMod ".higroup)
  return ""
endfunction

function! s:IsTabChanged(n)
  let buflist = tabpagebuflist(a:n)
  for i in buflist
    let bufinfo = get(getbufinfo(i), 0, { 'changed': 0 })
    if bufinfo.changed
      return 1
    endif
  endfor
  return 0
endfunction

function! TabLabel(n)
  let winnr = tabpagewinnr(a:n)
  let winid = win_getid(winnr, a:n)
  let bufname = bufname(winbufnr(winid))
  if empty(bufname)
    return a:n
  endif
  return split(bufname, "/")[-1]
endfunction

function! SetTabLine()
  let s = ''
  for i in range(1, tabpagenr('$'))
    if i == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= ' %'.i.'T%1.20{TabLabel('.i.')}'
    if s:IsTabChanged(i)
      let symbol = get(g:barow.tab_changed, "value", g:barowDefault.tab_changed.value)
      if i == tabpagenr()
        let s .= '%#BarowTChange#'.symbol
      else
        let s .= '%#BarowTChangeNC#'.symbol
      endif
    else
      let s.= ' '
    endif
    let s .= '%T'
  endfor
  let s .= '%#TabLineFill#'
  return s
endfunction

function! s:Modules()
  let index = len(g:barow.modules) - 1
  let modules = ""
  while index >= 0
    let [function, hi] = g:barow.modules[index]
    try
      let output = eval(function."()")
      let modules .= "%#".hi."#%-1.20(".output."%<%)%*"
      if index >= 0 && len(output) > 0
        let modules .= " "
      endif
    catch
    endtry
    let index = index - 1
  endwhile
  return modules
endfunction

function! barow#update()
  let inactive = get(g:barow.modes, "inactive", g:barowDefault.modes.inactive)
  let mode = "%{SetModeHi()}%#BarowMod#%1.1{Mode()[0]}%*"
  let modeInactive = "%#BarowModeNC#".get(inactive, 0, g:barowDefault.modes.inactive[0])."%*"
  let spacer = "%="
  let modules = s:Modules()
  for n in range(1, winnr('$'))
    if n == winnr()
      let bufName = "%#BarowBufName#%2.40{Bufname()}%*"
      let ro = "%#BarowRO#%{ReadOnly()}%*"
      let bufChanged = "%#BarowChange#%1.1{BufChanged()}%*"
      let rowCol = "%#BarowRowCol#%4.9l:%-3.9c%*"
      let linePercent = "%#BarowLPercent#%3.3p%%%*"
      call setwinvar(n, '&statusline', " ".mode." ".bufName." ".ro." ".bufChanged.spacer.modules." ".rowCol." ".linePercent." ")
    else
      let bufName = "%#BarowBufNameNC#%2.50{Bufname()}%*"
      let ro = "%#BarowRONC#%{ReadOnly()}%*"
      let bufChanged = "%#BarowChangeNC#%1.1{BufChanged()}%*"
      let rowCol = "%#BarowRowColNC#%4.9l:%-3.9c%*"
      let linePercent = "%#BarowLPercentNC#%3.3p%%%*"
      call setwinvar(n, '&statusline', " ".modeInactive." ".bufName." ".ro." ".bufChanged.spacer.rowCol." ".linePercent." ")
    endif
    call setwinvar(n, "&tabline", "%!SetTabLine()")
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
