" This plugin provides some functions of Hetena-Blog by using AtomPub API
" File: hateblo.vim
" Author: moznion (Taiki Kawakami) <moznion@gmail.com>
" License: MIT License

if exists('g:loaded_hateblo')
  finish
endif

try
  execute 'source $HOME/.hateblo.vim'
catch
  " DO NOTHING
endtry

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

let g:hateblo_vim['edit_command'] = get(g:hateblo_vim, 'edit_command', 'edit')

command! -nargs=0 HatebloCreate      call hateblo#createEntry('no')
command! -nargs=0 HatebloCreateDraft call hateblo#createEntry('yes')
command! -nargs=0 HatebloList        call hateblo#listEntry()
command! -nargs=? HatebloUpdate      call hateblo#updateEntry(<f-args>)
command! -nargs=0 HatebloDelete      call hateblo#deleteEntry()

let g:loaded_hateblo = 1

let &cpo = s:save_cpo
unlet s:save_cpo
