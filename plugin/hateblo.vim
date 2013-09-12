let s:save_cpo = &cpo
set cpo&vim

" This script expects the following variables in ~/.hateblo.vim
" - g:hateblo_user          User ID
" - g:hateblo_api_key       API Key
" - g:hateblo_api_endpoint  Endpoint of API
" - g:hateblo_WYSIWYG_mode  ( 0 | 1 )
source $HOME/.hateblo.vim

let s:unite_hateblo_entry_list_source = {'name': 'hateblo_entry_list'}

let s:entry_api = g:hateblo_api_endpoint . '/entry'

command! -nargs=* CreateHateblo call s:createEntry()
command! -nargs=* ListHateblo   call s:listEntry()
command! -nargs=* UpdateHateblo call s:updateEntry(<f-args>)
command! -nargs=* DeleteHateblo call s:deleteEntry()

function! s:createEntry()
  let l:lines = getline('1', '$')

  let l:title = ''
  if l:lines[0][0:2] == '*#*'
    let l:title = l:lines[0][3:]
    call remove(l:lines, 0)
  endif

  let l:content = join(l:lines, "\n")

  if g:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  if l:title == ''
    let l:title = input("Enter the title: ")
  endif

  call webapi#atom#createEntry(
        \ s:entry_api,
        \ g:hateblo_user,
        \ g:hateblo_api_key,
        \ {
        \   'title':        l:title,
        \   'content':      l:content,
        \   'content.type': 'text/plain',
        \   'content.mode': ''
        \ }
        \)
  redraw
  echo "Done!"
endfunction

function! s:updateEntry(...)
  if !exists('b:hateblo_entry_title') || !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  let l:lines = getline('1', '$')

  let l:content = join(l:lines, "\n")

  if g:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  let l:title = b:hateblo_entry_title
  if exists('a:000[0]')
    let l:title = a:000[0]
  endif

  call webapi#atom#updateEntry(
        \ b:hateblo_entry_url,
        \ g:hateblo_user,
        \ g:hateblo_api_key,
        \ {
        \   'title':        l:title,
        \   'content':      l:content,
        \   'content.type': 'text/plain',
        \   'content.mode': ''
        \ }
        \)

  redraw
  echo "Done!"
endfunction

function! s:deleteEntry()
  if !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  call webapi#atom#deleteEntry(
        \ b:hateblo_entry_url,
        \ g:hateblo_user,
        \ g:hateblo_api_key,
        \)

  unlet b:hateblo_entry_title
  unlet b:hateblo_entry_url

  redraw
  echo "Done!"
endfunction

function! s:listEntry()
  let l:feed = webapi#atom#getFeed(
        \ s:entry_api,
        \ g:hateblo_user,
        \ g:hateblo_api_key
        \)
  let b:hateblo_entries = l:feed['entry']

  Unite hateblo-list
endfunction

function! b:detailEntry(entry_url)
  let l:entry = webapi#atom#getEntry(
        \ a:entry_url,
        \ g:hateblo_user,
        \ g:hateblo_api_key
        \ )
  let l:escaped_entry_title = substitute(l:entry['title'], ' ', '\\ ', 'g')
  execute 'edit' l:escaped_entry_title

  let l:lines    = split(l:entry['content'], '\n')
  let l:line_num = 1
  for l:line in l:lines
    call setline(l:line_num, l:line)
    let l:line_num = l:line_num + 1
  endfor

  let l:editor_buf_num = bufnr(l:escaped_entry_title)
  call setbufvar(l:editor_buf_num, 'hateblo_entry_title', l:entry['title'])
  call setbufvar(l:editor_buf_num, 'hateblo_entry_url', a:entry_url)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
