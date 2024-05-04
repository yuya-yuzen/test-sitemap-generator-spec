# test-sitemap-generator-spec

sitemap_generator gemで生成するサイトマップのテスト記述の検証用Repo
https://github.com/kjvarga/sitemap_generator

## 結論

`SitemapGenerator::Interpreter` を使います。
https://www.rubydoc.info/gems/airblade-sitemap_generator/0.3.5/SitemapGenerator/Interpreter

`SitemapGenerator::Interpreter.run` でXMLファイルを生成します。
それを読み込み、期待するURLが含まれているか検証します。

## 1. sitemap_generatorを導入する

### 1-1. Gemfileに追加

```:Gemfile
gem 'sitemap_generator'
```

### 1-2. install

```shell
bundle install
```

### 1-3. 初期化

`config/sitemap.rb` が作成されます。

```shell
rake sitemap:install
```

## 2. サイトマップを生成する

### 2-1. ロジックを記述する

```ruby:config/sitemap.rb
SitemapGenerator::Sitemap.default_host = "https://www.example.com"
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  add '/articles'

  Article.find_each do |article|
    add "/articles/#{article.id}", :lastmod => article.updated_at
  end
end
```

### 2-2. サイトマップが生成される

`rake sitemap:refresh` を実行すると `public/sitemap.xml` が生成されます。
上記のロジックだと、下記のような内容になります。

```xml:public/sitemap.xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
  xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
  xmlns:video="http://www.google.com/schemas/sitemap-video/1.1"
  xmlns:news="http://www.google.com/schemas/sitemap-news/0.9"
  xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0"
  xmlns:pagemap="http://www.google.com/schemas/sitemap-pagemap/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <url>
    <loc>https://www.example.com</loc>
    <lastmod>2024-05-04T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://www.example.com/articles</loc>
    <lastmod>2024-05-04T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.5</priority>
  </url>
  <url>
    <loc>https://www.example.com/articles/1</loc>
    <lastmod>2024-05-04T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.5</priority>
  </url>
  <url>
    <loc>https://www.example.com/articles/2</loc>
    <lastmod>2024-05-04T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.5</priority>
  </url>
  <url>
    <loc>https://www.example.com/articles/3</loc>
    <lastmod>2024-05-04T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.5</priority>
  </url>
</urlset>
```

## 3. テストを書く

`SitemapGenerator::Interpreter` を使います。
https://www.rubydoc.info/gems/airblade-sitemap_generator/0.3.5/SitemapGenerator/Interpreter

`SitemapGenerator::Interpreter.run` でXMLファイルを生成します。
それを読み込み、期待するURLが含まれているか検証します。

```ruby:spec/config/sitemap_spec.rb
require 'rails_helper'

RSpec.describe 'SitemapGenerator' do
  subject(:generate_sitemap) { SitemapGenerator::Interpreter.run }

  let(:file_path) { Rails.root.join('public', 'sitemap.xml') }
  let(:host) { 'https://www.example.com' }

  after { File.delete(file_path) }

  it 'generates sitemap.xml' do
    generate_sitemap

    expect(File.exist?(file_path)).to be true
  end

  it 'includes article URLs' do
    articles = create_list(:article, 3)

    generate_sitemap

    file_contents = File.read(file_path)
    expect(file_contents).to include("<loc>#{host}/articles</loc>")
    articles.each do |article|
      expect(file_contents).to include("<loc>#{host}/articles/#{article.id}</loc>")
    end
  end
end
```
