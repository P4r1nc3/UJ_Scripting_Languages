# Ruby Crawler Project

## Overview
This Ruby script crawls the website `botland.com.pl` to extract information about products. It retrieves details such as title, price, link, and additional information from the product's subpage. This data can optionally be saved to a SQLite database.

## Requirements
- Ruby
- SQLite3
- Nokogiri gem
- Open-URI

## Installation
1. Clone the repository.
2. Install required gems: `gem install sqlite3 nokogiri`

## Usage
Run the script using `ruby main.rb`. When prompted, enter the search term for the products you wish to find on `botland.com.pl`. The script will display product information, including additional details from each product's subpage, in the terminal. If the database functionality is enabled, it will also save this data to a SQLite database.

