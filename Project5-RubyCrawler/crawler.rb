require 'nokogiri'
require 'open-uri'

class Crawler
    BOTLAND_URL = 'https://botland.com.pl/szukaj?s='

    def initialize(phrase, additional_info)
        @phrase = phrase
        @additional_info = additional_info
    end

    def get_main_items
        items_array = []
        full_url = @phrase.start_with?('http://', 'https://') ? @phrase : BOTLAND_URL + @phrase
        page_with_items = Nokogiri::HTML5.parse(URI(full_url).open('User-Agent' => 'ruby-agent-first'))

        page_with_items.css('.product-miniature.js-product-miniature').each do |item|
            item_title = item.css('.product-miniature__title a').text.strip
            item_price = item.css('.product-miniature-price .price').text.strip
            item_link = item.css('.card-img-top a').map { |link| link['href'].start_with?('http://', 'https://') ? link['href'] : "https://botland.com.pl" + link['href'] }.first

            unless item_title.empty? && item_price.empty? && item_link.nil?
                product = Product.new(item_title, item_price, item_link)
                if @additional_info
                    item_info = get_additional_info(item_link)
                    product.add_product_info(item_info)
                end
                items_array.push(product)
            end
        end
        items_array
    end

    def get_additional_info(item_link)
        sub_page = Nokogiri::HTML5.parse(URI(item_link).open('User-Agent' => 'ruby-agent'))
        additional_info = sub_page.at_css('div.product-page__short-description').text.strip
        additional_info
    end
end