let s:save_cpo = &cpo
set cpo&vim

function! hateblo#string#strip_whitespace(str)
  let l:str = substitute(a:str, '^\s\+', '', '')
  return substitute(l:str, '\s\+$', '', '')
endfunction

function! hateblo#string#escape_space(title_str)
  return substitute(a:title_str, ' ', '\\ ', 'g')
endfunction

function! hateblo#string#prepend_space(str)
  if a:str[0] == ' '
    return a:str
  else
    return ' ' . a:str
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set tw=2 ts=2 sw=2:
