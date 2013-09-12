hateblo.vim
===========

はてなブログAtomPub APIを用いて，エントリの投稿等の機能を提供するVimプラグインです

Getting started
---------------

1. `.hateblo.vim` というファイルをホームディレクトリに設置してください

        $ touch ~/.hateblo.vim

2. `.hateblo.vim` に以下のように設定を記述します (`.hateblo.vim` のサンプルは本リポジトリに含まれているので参考にして下さい)

 ```vim
 let g:hateblo_user         = 'user_name'        " はてなのユーザid
 let g:hateblo_api_key      = 'api_key'          " はてなブログの設定画面で確認できるAPIキー
 let g:hateblo_api_endpoint = 'api_endpoint_url' " はてなブログの設定画面で確認できるルートエンドポイント
 let g:hateblo_WYSIWYG_mode = 0 | 1              " 見たままモードを利用している場合は1に．それ以外は0に．
 ```

3. 本モジュールの依存モジュールをインストールして下さい. もしもNeoBundleを利用しているなら, `.vimrc`に以下の記述を追加するとよいでしょう．

        NeoBundle 'mattn/webapi-vim'
        NeoBundle 'Shougo/unite.vim'

4. このモジュールをインストールしてください．もしもNeoBundleを利用しているなら，`.vimrc`に以下の記述を追加するとよいでしょう．

        NeoBundle 'moznion/hateblo.vim'

 あるいは手順3と手順4を組み合わせて以下のように書いてもよいでしょう．

        NeoBundle 'moznion/hateblo.vim', {
                \ 'depends': ['mattn/webapi-vim', 'Shougo/unite.vim']
        \ }

Provided commands
-----------------

- :CreateHateblo

新しいブログエントリを投稿します．
1行目に`\*#\*`から始まる文を記述すると，その行はタイトルとして扱われます．
もしも1行目でタイトルを指定しなかった場合は，インタラクティブにタイトルが要求されます．

- :ListHateblo

ブログエントリのリストを unite source 形式で表示します．
エントリを選択すると，そのエントリを編集することができます．
後述する`UpdateHateblo`や`DeleteHateblo`といったコマンドは，`ListHateblo`で選択したエントリ上でしか実行することができません．

- :UpdateHateblo [new_entry_title]

ブログエントリを更新します．
引数の`new\_entry\_title`はオプショナルです．もしもタイトルを変更したい場合は指定してください．
引数が指定されなかった場合，タイトルは変更されません．
また，`CreateHateblo`とは異なり，1行目に`\*#\*`から始まる文を記述してもタイトルとしては扱われません．

- :DeleteHateblo

ブログエントリを削除します．

Dependencies
------------

- [webapi-vim](https://github.com/mattn/webapi-vim)
- [unite.vim](https://github.com/Shougo/unite.vim)

License
-------

MIT
