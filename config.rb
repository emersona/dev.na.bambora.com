require "lib/custom_markdown"
require "lib/custom_helpers"

# Markdown
set :markdown_engine, :redcarpet
set :markdown,
    renderer: CustomMarkdown,
    fenced_code_blocks: true,
    smartypants: true,
    disable_indented_code_blocks: true,
    prettify: true,
    tables: true,
    with_toc_data: true,
    no_intra_emphasis: true



# Assets
set :css_dir,   'stylesheets'
set :js_dir,    'javascripts'
set :images_dir,'images'
set :fonts_dir, 'fonts'

# Activate the syntax highlighter
activate :syntax

# Activate directory style pretty urls
activate :directory_indexes

activate :autoprefixer do |config|
  config.browsers = ['last 2 version', 'Firefox ESR']
  config.cascade  = false
  config.inline   = true
end

# Active middleman-search
activate :search do |search|
  search.language = 'es' # TODO: Bug workaround. Gem doesn't work for english lang. Fix.
  search.resources = ['docs/'] # The folder containing the docs to index
  search.fields = {
    title:   {boost: 100, store: true, required: true},
    content: {boost: 50},
    url:     {index: false, store: true},
    summary: {boost: 25, store: true},
    breadcrumbs: {index:false, store: true}
  }

  # customize content to be indexed and stored per resource
  search.before_index = Proc.new do |to_index, to_store, resource|

    # Add the breadcrumb trail for each resource to the index.
    # (To display in search results)
    breadcrumbs = get_breadcrumbs(resource.path)
    to_store[:breadcrumbs] = format_breadcrumb_trail(breadcrumbs, div_class: 'search-breadcrumbs')

    # Add 'includes' for each page to the index.
    if resource.data.includes
      resource.data.includes.each do |include|
        partial_html = partial("/includes/#{include}")
        partial_text = Nokogiri::HTML(partial_html).xpath("//text()").to_s
        to_index[:content] += " " + partial_text
      end
    end

  end
end

# Activate asset hash and enable for .json (search index)
# activate :asset_hash do |asset_hash|
#   asset_hash.exts << '.json'
# end

# Edit on Github variables
set :github_repo_url, "https://github.com/bambora/dev.na.bambora.com"
set :github_branch, "test"

# Helpers
helpers CustomHelpers

# Github pages require relative links
activate :relative_assets
set :relative_links, true


MERCHANT_HOST = ENV['MERCHANT_HOST'] || 'api.na.bambora.com'

# Download merchant swagger specs:
#get_all_swagger_specs "https://" + MERCHANT_HOST + "/v1/swagger", "/data/autodownload/na/API_spec/merchant"

# TEMPORARY until we fix the swagger endpoint WEB-770
#get_swagger_spec "https://" + MERCHANT_HOST + "/v1/swagger/1-0-4", "/data/autodownload/na/API_spec/merchant", "1-0-4.yaml"


ONBOARDING_HOST = ENV['ONBOARDING_HOST'] || 'onboardingapi'

# Download onboarding swagger specs
get_swagger_spec "https://" + ONBOARDING_HOST + ".na.bambora.com/v1/boarding/swagger/2016-08-18", "/data/autodownload/na/API_spec/onboarding", "2016-08-18.yaml"
get_swagger_spec "https://" + ONBOARDING_HOST + ".na.bambora.com/v1/boarding/swagger/2016-06-11", "/data/autodownload/na/API_spec/onboarding", "2016-06-11.yaml"
get_swagger_spec "https://" + ONBOARDING_HOST + ".na.bambora.com/v1/boarding/swagger/terms/2016-08-18", "/data/autodownload/na/API_spec/onboarding", "terms_2016-08-18.yaml"

# Build Configuration
configure :build do
  activate :minify_css
  # activate :minify_javascript # TODO: Tocbot breaks when js minimized. fix.
  activate :asset_hash, :ignore => 'stylesheets/fonts/'
  # activate :relative_assets
  # activate :gzip
end
