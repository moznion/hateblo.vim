" This plugin provides some functions of Hetena-Blog by using AtomPub API
" File: hateblo.vim
" Author: moznion (Taiki Kawakami) <moznion@gmail.com>
" License: MIT License

if exists('g:loaded_hateblo')
  finish
endif

let s:config_file_exists = 1
try
  execute 'source $HOME/.hateblo.vim'
catch
  let s:config_file_exists = 0 " .hateblo.vim doesn't exist
endtry

if s:config_file_exists == 1
  source $HOME/.hateblo.vim
endif

if !exists('g:hateblo_vim')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" This script expects the following variables in ~/.hateblo.vim
" - g:hateblo_vim['user']           User ID
" - g:hateblo_vim['api_key']        API Key
" - g:hateblo_vim['api_endpoint']   Endpoint of API
" - g:hateblo_vim['WYSIWYG_mode']   ( 0 | 1 )
" - g:hateblo_vim['always_yes']     ( 0 | 1 )
" - g:hateblo_vim['edit_command']   Command to open the entry

let g:hateblo_vim['edit_command'] = get(g:hateblo_vim, 'edit_command', 'edit')
let g:hateblo_entry_api_endpoint = g:hateblo_vim['api_endpoint'] . '/entry'

let g:hateblo_title_prefix = 'TITLE:'
let g:hateblo_category_prefix = 'CATEGORY:'

command! -nargs=0 HatebloCreate      call hateblo#createEntry('no')
command! -nargs=0 HatebloCreateDraft call hateblo#createEntry('yes')
command! -nargs=0 HatebloList        Unite hateblo-list
command! -nargs=0 HatebloUpdate      call hateblo#updateEntry()
command! -nargs=0 HatebloDelete      call hateblo#deleteEntry()

augroup hateblo_metarw_autosave
  autocmd!
  autocmd BufUnload hateblo:[0-9]* call metarw#hateblo#autosave()
augroup END

let g:loaded_hateblo = 1

let &cpo = s:save_cpo
unlet s:save_cpo
