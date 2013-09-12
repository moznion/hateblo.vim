let s:save_cpo = &cpo
set cpo&vim

let s:unite_hateblo_list_source = {
      \ 'name': 'hateblo-list',
      \ 'description': 'Entry list of HatenaBlog',
      \ 'action_table': {
      \   'edit_entry': {
      \     'description': 'edit entry'
      \   }
      \ },
      \ 'default_action': 'edit_entry'
\ }

function! s:unite_hateblo_list_source.action_table.edit_entry.func(candidate)
  echo a:candidate.action__url
endfunction

function! s:unite_hateblo_list_source.gather_candidates(args, context)
  let l:entries = b:hateblo_entries

  let l:entry_list = []
  for l:entry in l:entries
    let l:entry_title      = l:entry['title']
    let l:entry_updated_at = l:entry['updated']
    let l:entry_url = l:entry['link'][0]['href'] " XXX <= I think not good way...
    call add(l:entry_list, {
      \   'word':        l:entry_title . ' (' . l:entry_updated_at . ')',
      \   'source':      'hateblo-list',
      \   'kind':        'file',
      \   'action__url': l:entry_url
      \})
  endfor

  return l:entry_list
endfunction

function! unite#sources#hateblo_list#define()
  return s:unite_hateblo_list_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
