" Unite source for hateblo.vim
" File: hateblo_list.vim
" Author: moznion (Taiki Kawakami) <moznion@gmail.com>
" License: MIT License

let s:save_cpo = &cpo
set cpo&vim

let s:unite_hateblo_list_source = {
      \ 'name': 'hateblo-list',
      \ 'description': 'Entry list of HatenaBlog',
      \ 'action_table': {
      \   'on_choose': {
      \   }
      \ },
      \ 'default_action': 'on_choose'
\ }

function! s:unite_hateblo_list_source.action_table.on_choose.func(candidate)
  if a:candidate.action__action == 'edit_entry'
    call b:detailEntry(a:candidate.action__url)
  elseif a:candidate.action__action == 'next_page'
    call b:listEntry(a:candidate.action__url)
  endif
endfunction

function! s:unite_hateblo_list_source.gather_candidates(args, context)
  let l:entries = b:hateblo_entries

  let l:entry_list = []
  for l:entry in l:entries
    let l:entry_title      = l:entry['title']
    let l:entry_updated_at = l:entry['updated']
    let l:entry_url = l:entry['link'][0]['href'] " XXX <= I think not good way...
    call add(l:entry_list, {
      \   'word':           l:entry_title . ' (' . l:entry_updated_at . ')',
      \   'source':         'hateblo-list',
      \   'kind':           'file',
      \   'action__action': 'edit_entry',
      \   'action__url':    l:entry_url
      \})
  endfor

  if b:hateblo_next_page != ''
    call add(l:entry_list, {
      \   'word':           '### NEXT PAGE ###',
      \   'source':         'hateblo-list',
      \   'kind':           'file',
      \   'action__action': 'next_page',
      \   'action__url':    b:hateblo_next_page
      \ })
  endif

  return l:entry_list
endfunction

function! unite#sources#hateblo_list#define()
  return s:unite_hateblo_list_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
