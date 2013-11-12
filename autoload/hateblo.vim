let s:save_cpo = &cpo
set cpo&vim

let s:entry_api = g:hateblo_vim['api_endpoint'] . '/entry'

function! hateblo#createEntry(is_draft)
  let l:lines = getline('1', '$')

  let l:title = ''
  if l:lines[0][0:2] == '@#@'
    let l:title = l:lines[0][3:]
    call remove(l:lines, 0)

    if l:title == ''
      let l:title = '■'
    endif
  endif

  let l:content = join(l:lines, "\n")

  if exists("g:hateblo_vim['WYSIWYG_mode']") && g:hateblo_vim['WYSIWYG_mode'] == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  if l:title == ''
    let l:title = input("Enter the title: ")
  endif

  if l:title == ''
    let l:title = '■'
  endif

  " remove leading white spaces
  let l:title = substitute(l:title, "^[[:blank:]]\*", "", "")

  let l:category_str = input("Enter the categories: ")
  let l:category     = split(l:category_str, ',')

  if (exists("g:hateblo_vim['always_yes']") && g:hateblo_vim['always_yes'] == 1)
    let l:will_post = 'y'
  else
    let l:will_post = input('Post? (y/n) [n]: ')
  endif

  if l:will_post == 'y'
    call webapi#atom#createEntry(
          \ s:entry_api,
          \ g:hateblo_vim['user'],
          \ g:hateblo_vim['api_key'],
          \ {
          \   'title':        l:title,
          \   'content':      l:content,
          \   'content.type': 'text/plain',
          \   'content.mode': '',
          \   'app:control':  {
          \     'app:draft': a:is_draft
          \   },
          \   'category': l:category
          \ }
          \)
    redraw
    echo 'Done!'
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! hateblo#listEntry(...)
  let l:api_url = s:entry_api
  if exists('a:000[0]')
    let l:api_url = a:000[0]
  endif

  let l:feed = webapi#atom#getFeed(
        \ l:api_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key']
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

function! hateblo#updateEntry(...)
  if !exists('b:hateblo_entry_title') || !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  let l:lines = getline('1', '$')

  let l:content = join(l:lines, "\n")

  if exists("g:hateblo_vim['WYSIWYG_mode']") && g:hateblo_vim['WYSIWYG_mode'] == 1
    let l:content = substitute(l:content, '\n', '<br />', 'g')
  endif

  let l:title = b:hateblo_entry_title
  if exists('a:000[0]')
    let l:title = a:000[0]
  endif

  let l:default_category = ''
  if b:hateblo_category_str != '' " exist default values
    let l:default_category = b:hateblo_category_str
  endif

  let l:category_str = input("Enter the categories [" . l:default_category . "]: ")
  let l:category     = split(l:category_str, ',')

  if l:category == []
    let l:category = split(l:default_category, ',')
  endif

  if (exists("g:hateblo_vim['always_yes']") && g:hateblo_vim['always_yes'] == 1)
    let l:will_update = 'y'
  else
    let l:will_update = input('Update? (y/n) [n]: ')
  endif

  if l:will_update == 'y'
    call webapi#atom#updateEntry(
          \ b:hateblo_entry_url,
          \ g:hateblo_vim['user'],
          \ g:hateblo_vim['api_key'],
          \ {
          \   'title':        l:title,
          \   'content':      l:content,
          \   'content.type': 'text/plain',
          \   'content.mode': '',
          \   'category': l:category
          \ }
          \)
    redraw
    echo "Done!"
  else
    redraw
    echo 'Canceled!'
  endif
endfunction

function! hateblo#deleteEntry()
  if !exists('b:hateblo_entry_url')
    echohl WarningMsg
    echo 'This entry does not exist on remote!'
    echohl None
    return
  endif

  if (exists("g:hateblo_vim['always_yes']") && g:hateblo_vim['always_yes'] == 1)
    let l:will_delete = 'y'
  else
    let l:will_delete = input('Delete? (y/n) [n]: ')
  endif

  if l:will_delete == 'y'
    call webapi#atom#deleteEntry(
          \ b:hateblo_entry_url,
          \ g:hateblo_vim['user'],
          \ g:hateblo_vim['api_key'],
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

function! hateblo#detailEntry(entry_url)
  let l:entry = webapi#atom#getEntry(
        \ a:entry_url,
        \ g:hateblo_vim['user'],
        \ g:hateblo_vim['api_key']
        \ )
  let l:escaped_entry_title = substitute(l:entry['title'], ' ', '\\ ', 'g')

  let l:spacer = ''
  if l:escaped_entry_title[0] != ' '
    let l:spacer = ' '
  endif
  execute g:hateblo_vim['edit_command'] . l:spacer . l:escaped_entry_title

  if exists("g:hateblo_vim['WYSIWYG_mode']") && g:hateblo_vim['WYSIWYG_mode'] == 1
    let l:lines = substitute(l:lines, '<br />', '\n', 'g')
  endif

  let l:content_type = 'html' " TODO or text?
  if l:entry['content.type'] ==# 'text/x-markdown'
    let l:content_type = 'markdown'
  elseif l:entry['content.type'] ==# 'text/x-hatena-syntax'
    let l:content_type = 'hatena'
  endif

  let l:categories = []
  for l:category in l:entry['category']
    call add(l:categories, l:category['term'])
  endfor
  let l:hateblo_category_str = join(l:categories, ', ')

  let l:lines = split(l:entry['content'], '\n')
  call append(1, l:lines)

  let l:editor_buf_num = bufnr(l:escaped_entry_title)
  call setbufvar(l:editor_buf_num, 'hateblo_entry_title', l:entry['title'])
  call setbufvar(l:editor_buf_num, 'hateblo_entry_url', a:entry_url)
  call setbufvar(l:editor_buf_num, 'hateblo_category_str', l:hateblo_category_str)
  execute 'setlocal filetype=' . l:content_type
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
