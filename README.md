## Deksripsi
Skema basis data ini dirancang untuk mengelola sebuah toko ponsel bernama StellaGadget. Skema mencakup manajemen stok dan penjualan. 

## Kebutuhan Fungsional
Berikut adalah spesifikasi/ kebutuhan dari sistem StellaGadget:
- Menyimpan informasi mengenai merek ponsel, nama, warna, kapasitas memori, dan harga.
- Melacak stok/ jumlah dari setiap model ponsel
- Memastikan integritas data melalui foreign key dengan tabel phones.
- Menyimpan spesifikasi detail untuk setiap ponsel, termasuk ukuran layar, berat, chipset, kemampuan 5G (ENUM), dan informasi baterai.
- Menyimpan informasi pelanggan, termasuk nama dan nomor telepon.
- Melacak detail pesanan, termasuk tanggal pemesanan, pelanggan yang melakukan pemesanan, dan total jumlah pembayaran.
- Menampilkan detail pesanan seperti tipe hp, jumlah yang dibeli, dan harga total untuk setiap item.

## Relationships
![ERD sistem StellaGadget](/StellaGadget.drawio.png)
- Seorang customer/ pelanggan dapat melakukan banyak pesanan, minimum satu pesanan (1:N)
- Sebuah order/ pesanan dapat memiliki banyak item pesanan dengan minimum satu item (1:N)
- sebuah model hp dapat tertera di banyak item pesanan (1:N)
- sebuah model hp dapat tertera sebanyak 1 entry stok (1:1)
- sebuah model hp dapat memiliki banyak spesifikasi (1:N)

## Uraian Entitas
Bagian ini menjelaskan atribut-atribut dari entitas utama dan entitas asosiatif/ _junction table_

### Entitas Utama
**phones**
> CREATE TABLE phones(
    phone_id INT AUTO_INCREMENT PRIMARY KEY,
    brand ENUM('Samsung', 'Xiaomi') NOT NULL,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(255) NOT NULL,
    memory VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
- phone_id sebagai primary key
- brand menggunakan tipe ENUM agar pilihan merek valid
- name, color, memory menggunakan VARCHAR karena merupakan tipe data string
- price menggunakan DECIMAL untuk menunjukkan keakuratan harga

**customers**
> CREATE TABLE customers(
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);
- customer_id sebagai primary key
- name menggunakan VARCHAR karena merupakan tipe data string
- phone_number menggunakan VARCHAR karena merupakan data kualitatif

### Entitas Asosiatif
**phone_stocks**
> CREATE TABLE phone_stocks (
    phone_id INT,
    stock INT NOT NULL,
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);
- phone_id sebagai foreign key untuk menghubungkan model hp tertentu dengan stock
- stok menggunakan INT karena merupakan data kuantitatif

**phone_specs**
> CREATE TABLE phone_specs(
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    phone_id INT,
    display VARCHAR(255) NOT NULL,
    weight INT NOT NULL,
    chipset VARCHAR(255) NOT NULL,
    5G ENUM('yes', 'no') NOT NULL,
    battery VARCHAR(255) NOT NULL,
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);
- spec_id sebagai primary key
- phone_id sebagai foreign key untuk menghubungkan model hp tertentu dengan stock
- display, chipset, dan battery menggunakan VARCHAR karena memiliki data kualitatif
- weight menggunakan INT karena merupakan data kuantitatif
- 5G menggunakan ENUM karena memiliki nilai yang valid antara mendukung 5G dan tidak mendukung 5G

**orders**
> CREATE TABLE orders(
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT,
    total_payment DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
- order_id sebagai primary key
- order_date menampilkan waktu dari terjadinya pemesanan oleh customer, sehingga menggunakan DATE
- customer_id foreign key yang menghubungkan customer yang melakukan pemesanan
- total_payment menggunakan DECIMAL untuk menunjukkan keakuratan harga dari pesanan

**order_items**
> CREATE TABLE order_items(
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    phone_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (phone_id) REFERENCES phones(phone_id)
);
- detail_id sebagai primary key
- order_id sebagai foreign key yang berguna sebagai indeks penghubung dengan tabel order
- phone_id sebagai foreign key untuk menghubungkan detail order dengan model hp yang dipesan
- quantity menggunakan INT karena merupakan data kuantitatif
- total_price menggunakan DECIMAL untuk menunjukkan keakuratan harga dari pesanan

## Optimasi
### Trigger
#### 1. reduce_stock_on_order, berfungsi untuk mengurangi stok di tabel phone_stocks saat adanya proses penambahan di tabel order_items. Stock akan diperbarui setelah adanya hp yang terjual.

### Index
#### 1. index_name, kolom name di tabel phones dijadikan index karena sering dipanggil saat melihat view.
#### 2. index_total_price, kolom total_price di tabel order_items dijadikan index untuk mempermudah proses pencarian yang melibatkan kolom tersebut.

### View
#### 1. view_order_details, berfungsi melihat nama customer dan nama hp yang dibeli beserta kuantitas, total harga per tipe hp dan, total pemesanan.
#### 2. view_brand_sells, berfungsi melihat total penjualan berdasarkan brand/ merk hp.
#### 3. view_sd_sells, berfungsi melihat total penjualan model hp yang memiliki chipset Snapdragon