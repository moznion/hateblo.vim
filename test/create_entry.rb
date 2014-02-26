require 'atomutil'
require 'tempfile'
require 'yaml'

describe '記事の作成を行う' do
  let (:config)       {YAML.load_file(File.dirname(__FILE__) << '/hateblo.yml')}
  let (:api_endpoint) {config['api_endpoint']}
  let (:user_name)    {config['user']}
  let (:api_key)      {config['api_key']}

  let (:collection_uri)    {api_endpoint + '/entry'}
  let (:g_hateblo_vim_obj) {"{'user':#{user_name}, 'api_key':#{api_key}, 'api_endpoint':#{api_endpoint}}"}

  let (:auth)   {Atompub::Auth::Wsse.new :username => user_name, :password => api_key}
  let (:client) {Atompub::Client.new :auth => auth}

  let (:article_title)      {(('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).shuffle[0..7].join}
  let (:article_content)    {'foo bar'}
  let (:article_categories) {['vi', 'vim']}

  it 'TITLEとCATEGORYを本文に指定して投稿する' do
    article_str = <<-"--"
TITLE: #{article_title}
CATEGORY: #{article_categories.join(',')}
#{article_content}
    --
    create_vim_str = <<-"--"
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate
y
:quit!
    --
    test_create_entry(article_title, article_categories, article_str, create_vim_str)
  end

  it "TITLEだけ本文に指定して投稿する" do
    article_str = <<-"--"
TITLE: #{article_title}
#{article_content}
    --
    create_vim_str = <<-"--"
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate
#{article_categories.join(',')}
y
:quit!
    --
    test_create_entry(article_title, article_categories, article_str, create_vim_str)
  end

  it "CATEGORYだけ本文に指定して投稿する" do
    article_str = <<-"--"
CATEGORY: #{article_categories.join(',')}
#{article_content}
    --
    create_vim_str = <<-"--"
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate
#{article_title}
y
:quit!
    --
    test_create_entry(article_title, article_categories, article_str, create_vim_str)
  end

  it "TITLE/CATEGORYどちらもインタラクティブに指定して投稿する" do
    article_str    = article_content
    create_vim_str = <<-"--"
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate
#{article_title}
#{article_categories.join(',')}
y
:quit!
    --
    test_create_entry(article_title, article_categories, article_str, create_vim_str)
  end

  it "TITLE/CATEGORYどちらも空で投稿する" do
    article_str    = article_content
    create_vim_str = <<-"--"
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate


y
:quit!
    --
    test_create_entry('■', [], article_str, create_vim_str)
  end
end

def test_create_entry(article_title, article_categories, article_str, create_vim_str)
  article_tmp_file = Tempfile::new(article_title)
  article_tmp_file.write article_str
  article_tmp_file.rewind

  create_vim_tmp_file = Tempfile::new('create.vim')
  create_vim_tmp_file.write create_vim_str
  create_vim_tmp_file.rewind

  `vim -s #{create_vim_tmp_file.path} #{article_tmp_file.path} > /dev/null 2>&1`

  entry = client.get_feed(collection_uri).entry
  categories = article_categories
  entry.categories.each do |category|
    term = category.term
    expect(categories.delete(term)).to eq(term)
  end
  expect(entry.title).to eq(article_title)
  expect(categories).to eq([])
  expect(entry.content.body).to eq(article_content)

  article_tmp_file.close!
  create_vim_tmp_file.close!

  delete_article(entry.link.href)
end

def delete_article(article_uri)
  tmp_file = Tempfile::new('tmp')
  delete_vim_tmp_file = Tempfile::new('delete.vim')
  delete_vim_tmp_file.write <<-"--"
:let g:hateblo_vim['always_yes'] = 1
:let b:hateblo_entry_title = '#{article_title}'
:let b:hateblo_entry_url = '#{article_uri}'
:HatebloDelete
:quit!
  --
  delete_vim_tmp_file.rewind

  `vim -s #{delete_vim_tmp_file.path} #{tmp_file.path} > /dev/null 2>&1`

  # ここでテストするの責務的におかしそう
  # entry = client.get_feed(collection_uri).entry
  # expect(entry.title).not_to eq(article_title)

  tmp_file.close!
  delete_vim_tmp_file.close!
end
