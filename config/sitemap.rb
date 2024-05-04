# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.example.com"
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  add '/articles'

  Article.find_each do |article|
    add "/articles/#{article.id}", :lastmod => article.updated_at
  end
end
