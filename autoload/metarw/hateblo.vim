let s:save_cpo = &cpo
set cpo&vim

let s:entry_api = g:hateblo_vim['api_endpoint'] . '/entry'
let s:metarw_head = 'hateblo:'
let s:new_entry_id = 'NewEntry'

function! metarw#hateblo#read(fakepath)
  let l:entry_id = substitute(a:fakepath, s:metarw_head, '', '')
  if l:entry_id == "" || l:entry_id[0] == "?"
    let l:feed = hateblo#getFeed(s:entry_api . l:entry_id)
    let l:entries = map(l:feed['entry'], '{
          \ "label": v:val["title"],
          \ "fakepath": s:metarw_head . s:getEntryID(v:val["link"][0]["href"])
          \ }')

    call insert(l:entries, {
          \ 'label': 'New Entry',
          \ 'fakepath': s:metarw_head . s:new_entry_id
          \ }, 0)

    let l:next_page = hateblo#getNextPageLink(l:feed)
    if l:next_page != ""
      call add(l:entries, {
            \ 'label': '   Next Page  >',
            \ 'fakepath': s:metarw_head . substitute(l:next_page, s:entry_api, '', '')
            \ })
    endif

    let l:first_page = s:getFirstPageLink(l:feed)
    if l:first_page != ""
      call add(l:entries, {
            \ 'label': '<< First Page',
            \ 'fakepath': s:metarw_head . substitute(l:first_page, s:entry_api, '', '')
            \ })
    endif
    return ['browse', l:entries]
  endif
  if l:entry_id ==# s:new_entry_id
    let l:entry_id = s:newEntry()
    execute ':file ' . s:metarw_head . l:entry_id
  endif
  call hateblo#readEntry(s:entry_api . '/' . l:entry_id)
  return ['done', '']
endfunction

function! metarw#hateblo#write(fakepath, l1, l2, append_p)
  " call hateblo#updateEntry(1)
endfunction

function! s:getFirstPageLink(feed)
  for l:link in a:feed['link']
    if l:link['rel'] == 'first'
      return l:link['href']
    endif
  endfor
endfunction

function! s:newEntry()
  let l:entry_url = util#hateblo#createEntry('', '', [], 'yes')
  return s:getEntryID(l:entry_url)
endfunction

function! s:getEntryID(entry_url)
  let l:sub = substitute(a:entry_url, g:hateblo_entry_api_endpoint, '', '')
  if l:sub[0] == '/'
    return l:sub[1:]
  else
    echoerr 'This is not entry url'
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set ts=2 tw=2 sw=2:
