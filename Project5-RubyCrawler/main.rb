# main.rb
require './crawler'
require './product'
require './database_manager'

db_manager = DatabaseManager.new("products.db")

puts("What are You looking for?: ")
search = gets.chomp
search.gsub!(" ", "+")
additional_info = true

crawler = Crawler.new(search, additional_info)
items = crawler.get_main_items

items.each do |item|
    db_manager.save_product(item)
    puts item.to_string
end
