let s:save_cpo = &cpo
set cpo&vim

" This script expects the following variables in ~/.hateblo.vim
" - b:hateblo_user          User ID
" - b:hateblo_api_key       API Key
" - b:hateblo_api_endpoint  Endpoint of API
" - b:hateblo_WYSIWYG_mode  ( 0 | 1 )
source $HOME/.hateblo.vim

let s:unite_hateblo_entry_list_source = {'name': 'hateblo_entry_list'}

let s:entry_api = b:hateblo_api_endpoint . '/entry'

command! -nargs=* CreateHateblo call s:createHateblo()
command! -nargs=* ListHateblo   call s:listHateblo()
command! -nargs=* UpdateHateblo call s:updateEntry()

" TODO rename
function! s:createHateblo()
  let l:lines = getline('1', '$')

  let l:title = ''
  if l:lines[0][0:2] == '*#*'
    let l:title = l:lines[0][3:]
    call remove(l:lines, 0)
  endif

  let l:content = join(l:lines, "\n")

  if b:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  if l:title == ''
    let l:title = input("Enter the title: ")
  endif

  call webapi#atom#createEntry(
        \ s:entry_api,
        \ b:hateblo_user,
        \ b:hateblo_api_key,
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

function! s:updateEntry()
  if !exists('b:hateblo_entry_title') || !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  let l:lines = getline('1', '$')

  let l:content = join(l:lines, "\n")

  if b:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  call webapi#atom#updateEntry(
        \ b:hateblo_entry_url,
        \ b:hateblo_user,
        \ b:hateblo_api_key,
        \ {
        \   'title':        b:hateblo_entry_title,
        \   'content':      l:content,
        \   'content.type': 'text/plain',
        \   'content.mode': ''
        \ }
        \)

  redraw
  echo "Done!"
endfunction

" TODO rename
function! s:listHateblo()
  let l:feed = webapi#atom#getFeed(
        \ s:entry_api,
        \ b:hateblo_user,
        \ b:hateblo_api_key
        \)
  let b:hateblo_entries = l:feed['entry']

  Unite hateblo-list
endfunction

function! b:detailEntry(entry_url)
  let l:entry = webapi#atom#getEntry(
        \ a:entry_url,
        \ b:hateblo_user,
        \ b:hateblo_api_key
        \ )
  let l:entry_title = substitute(l:entry['title'], ' ', '\\ ', 'g')
  execute 'edit' l:entry_title

  let l:lines    = split(l:entry['content'], '\n')
  let l:line_num = 1
  for l:line in l:lines
    call setline(l:line_num, l:line)
    let l:line_num = l:line_num + 1
  endfor

  let l:editor_buf_num = bufnr(l:entry_title)
  call setbufvar(l:editor_buf_num, 'hateblo_entry_title', l:entry_title)
  call setbufvar(l:editor_buf_num, 'hateblo_entry_url', a:entry_url)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
