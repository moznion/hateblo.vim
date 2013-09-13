" This plugin provides some functions of Hetena-Blog by using AtomPub API
" File: hateblo.vim
" Author: moznion (Taiki Kawakami) <moznion@gmail.com>
" License: MIT License

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
command! -nargs=* ListHateblo   call b:listEntry()
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

  if exists('g:hateblo_WYSIWYG_mode') && g:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  if l:title == ''
    let l:title = input("Enter the title: ")
  endif

  let l:will_post = input('Post? (y/n) [y]: ')
  if l:will_post == '' || l:will_post == 'y'
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
    echo 'Done!'
  else
    redraw
    echo 'Canceled!'
  endif
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

  if exists('g:hateblo_WYSIWYG_mode') && g:hateblo_WYSIWYG_mode == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  let l:title = b:hateblo_entry_title
  if exists('a:000[0]')
    let l:title = a:000[0]
  endif

  let l:will_post = input('Post? (y/n) [y]: ')
  if l:will_post == '' || l:will_post == 'y'
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
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! s:deleteEntry()
  if !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  let l:will_post = input('Delete? (y/n) [y]: ')
  if l:will_post == '' || l:will_post == 'y'
    call webapi#atom#deleteEntry(
          \ b:hateblo_entry_url,
          \ g:hateblo_user,
          \ g:hateblo_api_key,
          \)

    unlet b:hateblo_entry_title
    unlet b:hateblo_entry_url

    redraw
    echo "Done!"
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! b:listEntry(...)
  let l:api_url = s:entry_api
  if exists('a:000[0]')
    let l:api_url = a:000[0]
  endif

  let l:feed = webapi#atom#getFeed(
        \ l:api_url,
        \ g:hateblo_user,
        \ g:hateblo_api_key
        \)
  let b:hateblo_entries = l:feed['entry']

  let b:hateblo_next_page = ''
  let l:links = l:feed['link']
  for l:link in l:links
    if l:link['rel'] == 'next'
      let b:hateblo_next_page = l:link['href']
      break
    endif
  endfor

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

  if exists('g:hateblo_WYSIWYG_mode') && g:hateblo_WYSIWYG_mode == 1
    let l:lines = substitute(l:lines, '<br />', '\n', 'g')
  endif

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
