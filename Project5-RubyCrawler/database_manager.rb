# database_manager.rb
require 'sqlite3'

class DatabaseManager
    def initialize(db_name)
        @db = SQLite3::Database.new db_name
        create_table
    end

    private

    def create_table
        @db.execute <<-SQL
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY,
                title TEXT,
                price TEXT,
                link TEXT,
                additional_info TEXT
            );
        SQL
    end

    public

    def save_product(product)
        @db.execute("INSERT INTO products (title, price, link, additional_info) VALUES (?, ?, ?, ?)",
            [product.product_title, product.product_price, product.product_link, product.product_info])
    end
end
