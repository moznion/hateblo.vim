require 'atomutil'
require 'tempfile'
require 'yaml'

describe '記事の作成・削除を行う' do
  config = YAML.load_file(File.dirname(__FILE__) << '/hateblo.yml')
  api_endpoint  = config['api_endpoint']
  user_name     = config['user']
  api_key       = config['api_key']
  collection_uri    = api_endpoint + '/entry'
  g_hateblo_vim_obj = "{'user':#{user_name}, 'api_key':#{api_key}, 'api_endpoint':#{api_endpoint}}"
  article_uri = ''

  # Atompubのクライアント取得
  auth = Atompub::Auth::Wsse.new :username => user_name, :password => api_key
  client = Atompub::Client.new :auth => auth

  article_title = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).shuffle[0..7].join

  it '新しい記事を作成する' do
    article_content    = 'foo bar'
    article_categories = ['vi', 'vim']

    article_tmp_file = Tempfile::new(article_title)
    article_tmp_file.write <<-"..."
TITLE: #{article_title}
CATEGORY: #{article_categories.join(',')}
#{article_content}
    ...
    article_tmp_file.rewind

    create_vim_tmp_file = Tempfile::new('create.vim')
    create_vim_tmp_file.write <<-"..."
:let g:hateblo_vim = #{g_hateblo_vim_obj}
:HatebloCreate
y
:quit!
    ...
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

    article_uri = entry.link.href # XXX あんまり良くないやり方

    article_tmp_file.close!
    create_vim_tmp_file.close!
  end

  it "記事を削除する" do
    tmp_file = Tempfile::new('tmp');
    delete_vim_tmp_file = Tempfile::new('delete.vim')
    delete_vim_tmp_file.write <<-"..."
:let g:hateblo_vim['always_yes'] = 1
:let b:hateblo_entry_title = '#{article_title}'
:let b:hateblo_entry_url = '#{article_uri}'
:HatebloDelete
:quit!
    ...
    delete_vim_tmp_file.rewind

    `vim -s #{delete_vim_tmp_file.path} #{tmp_file.path} > /dev/null 2>&1`

    entry = client.get_feed(collection_uri).entry
    expect(entry.title).not_to eq(article_title)

    tmp_file.close!
    delete_vim_tmp_file.close!
  end
end
