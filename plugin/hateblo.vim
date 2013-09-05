" This script expects the following variables in ~/.hateblo.vim
" - b:hateblo_user          User ID
" - b:hateblo_wsse_pass     WSSE Pass
" - b:hateblo_api_endpoint  Endpoint of API
source $HOME/.hateblo.vim

let s:unite_hateblo_entry_list_source = {'name': 'hateblo_entry_list'}

let s:entry_api = b:hateblo_api_endpoint . '/entry'

command! -nargs=* CreateHateblo call s:createHateblo()
command! -nargs=* ListHateblo   call s:listHateblo()

function! s:createHateblo()
  let l:content = ''
  for l:line in readfile(expand("%:p"))
    let l:content = l:content . l:line . "\n"
  endfor

  let l:title = input("Enter the title: ")

  call webapi#atom#createEntry(
        \ s:entry_api,
        \ b:hateblo_user,
        \ b:hateblo_wsse_pass,
        \ {
        \   'title':        l:title,
        \   'content':      l:content,
        \   'content.type': 'text/plain',
        \   'content.mode': ''
        \ }
        \)
  redraw
  echo "Success!"
endfunction

function! s:listHateblo()
  let l:feed = webapi#atom#getFeed(
        \ s:entry_api,
        \ b:hateblo_user,
        \ b:hateblo_wsse_pass
        \)
  let b:hateblo_entries = l:feed['entry']

  Unite hateblo-list
endfunction
