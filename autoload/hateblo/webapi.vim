let s:save_cpo = &cpo
set cpo&vim

function! hateblo#webapi#getEntry(entry_url)
  return webapi#atom#getEntry(
        \ a:entry_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key']
        \ )
endfunction

function! hateblo#webapi#createEntry(title, content, category, is_draft)
  return webapi#atom#createEntry(
        \ g:hateblo_entry_api_endpoint,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key'],
        \ {
        \   'title': a:title,
        \   'content': a:content,
        \   'content.type': 'text/plain',
        \   'content.mode': '',
        \   'app:control':  {
        \     'app:draft': a:is_draft
        \   },
        \   'category': a:category
        \ }
        \)
endfunction

function! hateblo#webapi#updateEntry(entry_url, title, content, category, is_draft)
  call webapi#atom#updateEntry(
        \ a:entry_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key'],
        \ {
        \   'title':        a:title,
        \   'content':      a:content,
        \   'content.type': 'text/plain',
        \   'content.mode': '',
        \   'app:control':  {
        \     'app:draft': a:is_draft
        \   },
        \   'category': a:category
        \ }
        \)
endfunction

function! hateblo#webapi#getFeed(api_url)
  return webapi#atom#getFeed(
        \ a:api_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key']
        \)
endfunction

function! hateblo#webapi#deleteEntry(entry_url)
  call webapi#atom#deleteEntry(
        \ a:entry_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key'],
        \)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set tw=2 ts=2 sw=2:
