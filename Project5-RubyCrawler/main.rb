require './crawler'
require './product'
require 'sqlite3'

DB = SQLite3::Database.new "products.db"

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    title TEXT,
    price TEXT,
    link TEXT,
    additional_info TEXT
  );
SQL

puts("What are You looking for?: ")
search = gets.chomp
search.gsub!(" ", "+")
additional_info = true

crawler = Crawler.new(search, additional_info)
items = crawler.get_main_items

items.each do |item|
    item.save_to_db
    puts item.to_string
end
