-- table_init.sql

USE `rasa_bot`;

-- Create the 'orders' table
CREATE TABLE IF NOT EXISTS `orders` (
    `order_id` INT AUTO_INCREMENT PRIMARY KEY,
    `menu_item` VARCHAR(255) NOT NULL,
    `quantity` INT NOT NULL,
    `preparation_time` INT NOT NULL,
    `total_price` DECIMAL(10, 2) NOT NULL,
    `special_request` VARCHAR(255),
    `personal_details` VARCHAR(255),
    `delivery_address` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
