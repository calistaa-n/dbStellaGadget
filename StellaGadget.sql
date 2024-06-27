-- table 
-- - phones: brand, name, color, memory, price
-- - phone_stocks: phone_id(foreign key), stock
-- - phone_specs: phone_id(foreign key), display, weight, chipset, memory, 5g
-- - customers: name, phone_number
-- - orders: order_date, customer_id(foreign key), total_payment
-- - order_items: order_id(foreign key), phone_id(foreign key), quantity, total_price


CREATE DATABASE dbStellaGadget;

use dbStellaGadget;

-- Membuat tabel
CREATE TABLE phones(
    phone_id INT AUTO_INCREMENT PRIMARY KEY,
    brand ENUM('Samsung', 'Xiaomi', 'Iphone') NOT NULL,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    memory VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
CREATE TABLE phone_stocks (
    phone_id INT,
    stock INT NOT NULL,
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);
CREATE TABLE phone_specs(
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    phone_id INT,
    display VARCHAR(255) NOT NULL,
    weight INT NOT NULL,
    chipset VARCHAR(255) NOT NULL,
    5G ENUM('yes', 'no') NOT NULL,
    battery VARCHAR(255) NOT NULL,
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);
CREATE TABLE customers(
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);
CREATE TABLE orders(
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT,
    total_payment DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items(
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    phone_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);

--Membuat trigger untuk mengurangi stock
DELIMITER //
CREATE TRIGGER reduce_stock_on_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  UPDATE phone_stocks
  SET stock = stock - NEW.quantity
  WHERE phone_id = NEW.phone_id;
END;
//

-- Membuat view untuk melihat detail order
CREATE VIEW view_order_details AS
SELECT 
  c.name AS customer_name,
  ph.name AS phone_name,
  oi.quantity,
  oi.total_price,
  o.total_payment
FROM orders AS o
INNER JOIN customers AS c ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN phones AS ph ON oi.phone_id = ph.phone_id;

-- Membuat view untuk melihat total penjualan berdasarkan brand
CREATE VIEW view_brand_sells AS
SELECT
    ph.brand,
    SUM(oi.total_price) AS earnings
FROM phones AS ph
LEFT JOIN order_items AS oi ON ph.phone_id = oi.phone_id
GROUP BY ph.brand;

-- membuat view untuk melihat total penjualan hp dengan chipset Snapdragon
CREATE VIEW view_sd_sells AS
SELECT
    ph.name AS phone_name,
    COUNT(ph.name) AS sold
FROM order_items AS oi
INNER JOIN phones AS ph ON oi.phone_id = ph.phone_id
WHERE ph.phone_id IN (
    SELECT phone_id
    FROM phone_specs
    WHERE chipset LIKE 'Snapdragon%'
)
GROUP BY ph.name 
HAVING COUNT(ph.name) > 0;

-- Memasukkan data
INSERT INTO phones(brand, name, color, memory, price) VALUES 
('Xiaomi', 'Redmi Note 13', 'Midnight Black, Ice Blue, Ocean Sunset', '8/128', 2399000),
('Xiaomi', 'Redmi Note 13', 'Midnight Black, Ice Blue, Ocean Sunset', '8/256', 2799000),
('Xiaomi', 'Mi 14', 'Black, White, Jade Green', '12/256', 11749000),
('Samsung', 'Galaxy S24 Ultra', 'Titanium Black, Titanium Violet, Titanium Gray', '12/256', 19999000),
('Samsung', 'Galaxy A55', 'Awesome Ice Blue, Awesome Navy, Awesome Lilac', '8/256', 5999000),
('Samsung', 'Galaxy A55', 'Awesome Ice Blue, Awesome Navy, Awesome Lilac', '12/256', 6699000);

INSERT INTO phone_stocks(phone_id, stock) VALUES (1, 50), (2, 50), (3, 25), (4, 25), (5, 50), (6, 50);

INSERT INTO phone_specs(phone_id, display, weight, chipset, 5G, battery) VALUES
((SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'), 'AMOLED 6.67', 175, 'Mediatek Dimensity 6080', 'yes', '5000mAh'),
((SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/256'), 'AMOLED 6.67', 175, 'Mediatek Dimensity 6080', 'yes', '5000mAh'),
((SELECT phone_id FROM phones WHERE name = 'Mi 14'), 'OLED 6.36', 188, 'Snapdragon 8 Gen 3', 'yes', '4060mAh'),
((SELECT phone_id FROM phones WHERE name = 'Galaxy S24 Ultra'), 'Dynamic AMOLED 6.8', 232, 'Snapdragon 8 Gen 3', 'yes', '5000mAh'),
((SELECT phone_id FROM phones WHERE name = 'Galaxy A55' AND memory = '8/256'), 'Super AMOLED 6.6', 213, 'Exynos 1480', 'yes', '5000mAh'),
((SELECT phone_id FROM phones WHERE name = 'Galaxy A55' AND memory = '12/256'), 'Super AMOLED 6.6', 213, 'Exynos 1480', 'yes', '5000mAh');

INSERT INTO customers (name, phone_number) VALUES
  ('John Doe', '123-456-7890'),
  ('Jane Smith', '098-765-4321'),
  ('Michael Lee', '555-121-2323'),
  ('Olivia Jones', '987-654-3210'),
  ('William Brown', '321-098-7654'),
  ('Emily Garcia', '212-555-1234'),
  ('David Miller', '415-789-0654'),
  ('Sarah Hernandez', '800-555-1212');

INSERT INTO orders(order_date, customer_id, total_payment) VALUES
('2024-05-07', 2, 4798000),
('2024-05-07', 1, 19999000),
('2024-05-08', 6, 18448000),
('2024-05-13', 3, 2399000),
('2024-05-15', 5, 2399000),
('2024-05-26', 4, 5999000),
('2024-06-01', 7, 5999000),
('2024-06-01', 8, 9098000);

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  1,
  (SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'),
  2,
  (phones.price * 2) AS total_price
FROM phones
WHERE name = 'Redmi Note 13' AND memory = '8/128';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  2,
  (SELECT phone_id FROM phones WHERE name = 'Galaxy S24 Ultra'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Galaxy S24 Ultra';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  3,
  (SELECT phone_id FROM phones WHERE name = 'Mi 14'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Mi 14';
INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  3,
  (SELECT phone_id FROM phones WHERE name = 'Galaxy A55' AND memory = '12/256'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Galaxy A55' AND memory = '12/256';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  4,
  (SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Redmi Note 13' AND memory = '8/128';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  5,
  (SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Redmi Note 13' AND memory = '8/128';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  6,
  (SELECT phone_id FROM phones WHERE name = 'Galaxy A55' AND memory = '8/256'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Galaxy A55' AND memory = '8/256';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  7,
  (SELECT phone_id FROM phones WHERE name = 'Galaxy A55' AND memory = '8/256'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Galaxy A55' AND memory = '8/256';

INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  8,
  (SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Redmi Note 13' AND memory = '8/128';
INSERT INTO order_items(order_id, phone_id, quantity, total_price)
SELECT
  8,
  (SELECT phone_id FROM phones WHERE name = 'Redmi Note 13' AND memory = '8/128'),
  1,
  (phones.price * 1) AS total_price
FROM phones
WHERE name = 'Galaxy A55' AND memory = '12/256';


-- membuat index pada kolom yang sering ditampilkan pada view
CREATE INDEX index_name ON phones(name);
CREATE INDEX index_total_price ON order_items(total_price);


