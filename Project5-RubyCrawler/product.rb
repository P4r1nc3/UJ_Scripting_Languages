# product.rb
class Product
    attr_reader :product_title, :product_price, :product_link, :product_info

    def initialize(title, price, link)
        @product_title = title
        @product_price = price
        @product_link = link
    end

    def add_product_info(info)
        @product_info = info
    end

    def to_string
        puts "Title: #{@product_title}"
        puts "Price: #{@product_price}"
        unless @product_info.nil?
            puts "Additional info: #{@product_info}"
        end
        puts "Link: #{@product_link}"
    end

    def save_to_db
        DB.execute("INSERT INTO products (title, price, link, additional_info) VALUES (?, ?, ?, ?)", [@product_title, @product_price, @product_link, @product_info])
    end
end