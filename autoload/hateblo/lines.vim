let s:save_cpo = &cpo
set cpo&vim

function! hateblo#lines#analyse(lines)
  let result = {}
  let header_position = 0

  let title_line = a:lines[header_position]
  let title_top = stridx(title_line, g:hateblo_title_prefix)
  if title_top >= 0
    let result['title_line'] = header_position
    let result['title'] = hateblo#string#strip_whitespace(
          \ title_line[title_top + len(g:hateblo_title_prefix):])
    let header_position += 1
  endif

  let category_line = a:lines[header_position]
  let category_top = stridx(category_line, g:hateblo_category_prefix)
  if category_top >= 0
    let result['category_line'] = header_position
    let category_str = hateblo#string#strip_whitespace(
          \ category_line[category_top + len(g:hateblo_category_prefix) :])
    let result['category'] = map(split(category_str, ','), 
                                 \ 'hateblo#string#strip_whitespace(v:val)')
    let header_position += 1
  endif

  return result
endfunction

function! hateblo#lines#format(lines)
  let l:lines = a:lines
  if exists("g:hateblo_vim['WYSIWYG_mode']") && g:hateblo_vim['WYSIWYG_mode'] == 1
    let l:lines = map(l:lines, 'substitute(v:val, "<br />", "\n", "g")')
  endif
  let l:lines = map(l:lines, 'substitute(v:val, "$", "", "")') " Remove 'CR' newline characters
  return l:lines
endfunction

function! hateblo#lines#parse(lines)
  let result = {}
  let res = hateblo#lines#analyse(a:lines)

  " あるとすればタイトル、カテゴリの順と仮定する
  if has_key(res, 'category_line') && has_key(res, 'category')
    call remove(a:lines, res['category_line'])
    let result['category'] = res['category']
  endif
  if has_key(res, 'title_line') && has_key(res, 'title')
    call remove(a:lines, res['title_line'])
    let result['title'] = res['title']
  endif
  let result['contents'] = join(hateblo#lines#format(a:lines), '\n')
  return result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set tw=2 ts=2 sw=2:
