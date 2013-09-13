hateblo.vim
===========

This plugin provides some functions of Hatena-Blog by using AtomPub API.

Getting started
---------------

1. Put the `.hateblo.vim` file on your home directory.

        $ touch ~/.hateblo.vim

2. Write some configurations into `.hateblo.vim`, like so:

        let g:hateblo_user         = 'user_name'
        let g:hateblo_api_key      = 'api_key'
        let g:hateblo_api_endpoint = 'api_endpoint_url'
        let g:hateblo_WYSIWYG_mode = 0 | 1

Sample of `.hateblo.vim` is included in this repository.

3. Install dependent plugins. If you are using NeoBundle, please write down like the following into .vimrc;

        NeoBundle 'mattn/webapi-vim'
        NeoBundle 'Shougo/unite.vim'

after execute `NeoBundleInstall`.

Provided commands
-----------------

- :HatebloCreate

    Creates the new entry to your blog.

- :HatebloList

    Show entries list in your blog.

Dependencies
------------

- webapi-vim
- unite.vim

License
-------

MIT
