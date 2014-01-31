let s:save_cpo = &cpo
set cpo&vim

let g:hateblo_entry_api_endpoint = g:hateblo_vim['api_endpoint'] . '/entry'

function! hateblo#createEntry(is_draft)
  let b:hateblo_contents_beginning_line = 1 " XXX suxxs!

  let l:title    = s:get_title()
  let l:category = s:get_category()
  let l:lines    = s:format_lines(getline(b:hateblo_contents_beginning_line, '$'))
  let l:content  = join(l:lines, "\n")

  if s:ask('Post?')
    call hateblo#webapi#createEntry(l:title, l:content, l:category, a:is_draft)
    redraw
    echo 'Done!'
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! hateblo#updateEntry()
  let b:hateblo_contents_beginning_line = 1 " XXX suxxs!

  call s:does_remote_article_exist()

  let l:title    = s:get_title()
  let l:category = s:get_category()
  let l:lines    = s:format_lines(getline(b:hateblo_contents_beginning_line, '$'))
  let l:content  = join(l:lines, "\n")

  call s:confirm_publish() " If it returns 'no', article will be updated as still draft
  if s:ask('Update?')
    call hateblo#webapi#updateEntry(b:hateblo_entry_url, l:title, l:content, l:category, b:hateblo_is_draft)
    redraw
    echo "Done!"
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! hateblo#deleteEntry()
  call s:does_remote_article_exist()
  if s:ask('Delete?')
    call hateblo#webapi#deleteEntry(b:hateblo_entry_url)
    unlet b:hateblo_entry_title
    unlet b:hateblo_entry_url
    redraw
    echo "Done!"
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! hateblo#readEntry(entry_url)
  let l:entry = hateblo#webapi#getEntry(a:entry_url)
  let l:lines = s:get_lines(l:entry)
  call append(1, l:lines)
  call append(1, s:title_prefix . l:entry['title'])
  call append(2, s:category_prefix . join(s:get_entry_category(l:entry), ', '))
  call s:save_entry_meta_to_buffer(a:entry_url, l:entry)
endfunction

function! hateblo#detailEntry(entry_url)
  let l:entry = hateblo#webapi#getEntry(a:entry_url)
  let l:escaped_entry_title = hateblo#string#escape_space(l:entry['title'])
  execute g:hateblo_vim['edit_command'] . hateblo#string#prepend_space(l:escaped_entry_title)
  let l:lines = s:get_lines(l:entry)
  call append(0, l:lines)
  call s:save_entry_meta_to_buffer(a:entry_url, l:entry)
endfunction

function! hateblo#listEntry(...)
  if exists('a:000[0]')
    let l:feed = hateblo#webapi#getFeed(a:000[0])
  else
    let l:feed = hateblo#webapi#getFeed(g:hateblo_entry_api_endpoint)
  endif
  call s:save_feed_meta_to_buffer(l:feed)
  Unite hateblo-list
endfunction

function! hateblo#getNextPageLink(feed)
  for l:link in a:feed['link']
    if l:link['rel'] == 'next'
      return l:link['href']
    endif
  endfor
endfunction

let s:title_prefix = 'TITLE:'
let s:category_prefix = 'CATEGORY:'

function! s:ask(comment)
  if (exists("g:hateblo_vim['always_yes']") && g:hateblo_vim['always_yes'] == 1)
    return 1
  else
    let l:will_update = input(a:comment . ' (y/n) [n]: ')
    if l:will_update == 'y'
      return 1
    else
      return 0
    endif
  endif
endfunction

function! s:does_remote_article_exist()
  " XXX Uggggggg... I think this way is pretty damn...
  if !exists('b:hateblo_entry_title') || !exists('b:hateblo_entry_url')
    throw 'This entry does not exist on remote!'
  endif
endfunction

function! s:get_title()
  let l:title_line = getline(1)

  if l:title_line[0:len(s:title_prefix)-1] ==# s:title_prefix
    " `TITLE: foobar` is on the top of line
    let b:hateblo_contents_beginning_line += 1
    let l:title = hateblo#string#strip_whitespace(l:title_line[len(s:title_prefix):])
  elseif exists('b:hateblo_entry_title') && b:hateblo_entry_title != ''
    let l:title = b:hateblo_entry_title
  else
    let l:title = hateblo#string#strip_whitespace(input("Enter the title: "))
    if len(l:title) <= 0
      let l:title = '■'
    endif
  endif

  let b:hateblo_entry_title = l:title
  return l:title
endfunction

function! s:get_category()
  let l:category_line = getline(b:hateblo_contents_beginning_line)

  if l:category_line[0:len(s:category_prefix)-1] ==# s:category_prefix
    " `CATEGORY: Perl, Ruby` is on the top of line
    let b:hateblo_contents_beginning_line += 1
    let l:category_str = hateblo#string#strip_whitespace(l:category_line[len(s:category_prefix):])
  elseif exists("b:hateblo_category_str") && b:hateblo_category_str != ''
    let l:category_str = b:hateblo_category_str
  else
    let l:category_str = hateblo#string#strip_whitespace(input("Enter the categories: "))
  endif

  let b:hateblo_category_str = l:category_str
  return map(split(l:category_str, ','), 'hateblo#string#strip_whitespace(v:val)')
endfunction

function! s:confirm_publish()
  if b:hateblo_is_draft ==# 'yes'
    let l:publish_draft = input('Publish this draft? (y/n) [n]: ')
    if (l:publish_draft == 'y')
      let b:hateblo_is_draft = 'no'
    endif
  endif
endfunction

function! s:format_lines(lines)
  let l:lines = a:lines
  if exists("g:hateblo_vim['WYSIWYG_mode']") && g:hateblo_vim['WYSIWYG_mode'] == 1
    let l:lines = map(l:lines, 'substitute(v:val, "<br />", "\n", "g")')
  endif
  let l:lines = map(l:lines, 'substitute(v:val, "$", "", "")') " Remove 'CR' newline characters
  return l:lines
endfunction

function! s:get_lines(entry)
  let l:lines = split(a:entry['content'], '\n')
  return s:format_lines(l:lines)
endfunction

function! s:get_content_type(entry)
  if a:entry['content.type'] ==# 'text/x-markdown'
    return 'markdown'
  elseif a:entry['content.type'] ==# 'text/x-hatena-syntax'
    return 'hatena'
  else
    return 'html' " TODO or text?
  endif
endfunction

function! s:get_entry_category(entry)
  let l:categories = []
  for l:category in a:entry['category']
    call add(l:categories, l:category['term'])
  endfor
  return l:categories
endfunction

function! s:save_entry_meta_to_buffer(entry_url, entry)
  let b:hateblo_entry_url = a:entry_url
  let b:hateblo_category_str = join(s:get_entry_category(a:entry), ', ')
  let b:hateblo_entry_title = a:entry['title']
  let b:hateblo_is_draft = a:entry['app:control']['app:draft']
  execute 'setlocal filetype=' . s:get_content_type(a:entry)
endfunction

function! s:save_feed_meta_to_buffer(feed)
  let b:hateblo_entries = a:feed['entry']
  let b:hateblo_next_page = hateblo#getNextPageLink(a:feed)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set tw=2 ts=2 sw=2:
