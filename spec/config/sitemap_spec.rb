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
