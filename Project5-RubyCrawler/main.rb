require './crawler'
require './product'

puts("What are You looking for?: ")
search = gets
search.gsub!(" ", "+")
additional_info = true

crawler = Crawler.new(search, additional_info)
items = crawler.get_main_items

items.each do |item|
    puts item.to_string
end