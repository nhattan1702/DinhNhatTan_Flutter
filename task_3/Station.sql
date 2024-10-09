CREATE TABLE Station (
    station_id INT PRIMARY KEY AUTO_INCREMENT,
    station_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Pump (
    pump_id INT PRIMARY KEY AUTO_INCREMENT,
    station_id INT,
    product_id INT,
    FOREIGN KEY (station_id) REFERENCES Station(station_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    station_id INT,
    pump_id INT,
    product_id INT,
    transaction_time DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    total_value DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (station_id) REFERENCES Station(station_id),
    FOREIGN KEY (pump_id) REFERENCES Pump(pump_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
