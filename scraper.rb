require 'awesome_print'
require 'fileutils'
require 'nokogiri'

def create_path(path)
  path.sub('www.example.com', 'wp.example.com').downcase.sub(/\.html?$/, '.html')
end

def create_dir(path)
  FileUtils.mkdir_p(File.dirname(path))
end

def parse_page(path)
  page = Nokogiri::HTML(File.open(path))
  {}.tap do |data|
    data[:title] = page.at_css('title').text
    data[:content] = page.at_css('.maincol').inner_html if page.at_css('.maincol')
  end
end

def create_page(data)
  %Q{
    <html>
      <head><title>#{data[:title]}</title></head>
      <body>
        #{data[:content]}
      </body>
    </html>
  }
end

Dir['www.example.com/**/*.htm*'].each do |path|
  new_path  = create_path(path)
  page      = create_page(parse_page(path))
  
  create_dir(new_path)
  File.open(new_path, 'w') do |file|
    file.puts page
  end
end
