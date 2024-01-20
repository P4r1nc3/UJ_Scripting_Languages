# main.rb
require './crawler'
require './product'
require './database_manager'

additional_info = true
database = true

db_manager = DatabaseManager.new("products.db") if database

puts("What are You looking for?: ")
search = gets.chomp
search.gsub!(" ", "+")

crawler = Crawler.new(search, additional_info)
items = crawler.get_main_items

items.each do |item|
    db_manager.save_product(item) if database
    puts item.to_string
end
