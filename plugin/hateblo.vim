let s:save_cpo = &cpo
set cpo&vim

" This script expects the following variables in ~/.hateblo.vim
" - b:hateblo_user          User ID
" - b:hateblo_api_key       API Key
" - b:hateblo_api_endpoint  Endpoint of API
source $HOME/.hateblo.vim

let s:unite_hateblo_entry_list_source = {'name': 'hateblo_entry_list'}

let s:entry_api = b:hateblo_api_endpoint . '/entry'

command! -nargs=* CreateHateblo call s:createHateblo()
command! -nargs=* ListHateblo   call s:listHateblo()

function! s:createHateblo()
  let l:lines = getline('1', '$')

  let l:title = ''
  if l:lines[0][0] == '*'
    let l:title = l:lines[0][1:]
    call remove(l:lines, 0)
  endif

  let l:content = join(l:lines, "\n")

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

function! s:listHateblo()
  let l:feed = webapi#atom#getFeed(
        \ s:entry_api,
        \ b:hateblo_user,
        \ b:hateblo_api_key
        \)
  let b:hateblo_entries = l:feed['entry']

  Unite hateblo-list
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
