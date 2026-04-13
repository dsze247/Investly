-- create tables
CREATE TABLE AppUser (
    user_id INT AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- sha256
    PRIMARY KEY (user_id)
);

CREATE TABLE Portfolio (
    portfolio_id INT AUTO_INCREMENT,
    user_id INT,
    portfolio_name VARCHAR(255) NOT NULL,
    risk_profile VARCHAR(20) NOT NULL,
    PRIMARY KEY (portfolio_id),
    FOREIGN KEY (user_id) REFERENCES AppUser(user_id)
);

CREATE TABLE Asset (
    asset_id INT AUTO_INCREMENT,
    ticker_symbol VARCHAR(10) UNIQUE,
    asset_name VARCHAR(255) NOT NULL,
    asset_type VARCHAR(40) NOT NULL,
    sector VARCHAR(40) NOT NULL,
    PRIMARY KEY (asset_id)
);

CREATE TABLE AssetTransaction (
    transaction_id INT AUTO_INCREMENT,
    portfolio_id INT,
    asset_id INT,
    transaction_type VARCHAR(10) NOT NULL,
    quantity DECIMAL(15,2) NOT NULL, -- quantity can be decimal for crypto etc
    price_per_unit DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id),
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id)
);

CREATE TABLE PortfolioHolding (
    portfolio_id INT,
    asset_id INT,
    total_quantity DECIMAL(15,3) NOT NULL,
    average_cost DECIMAL(15,3) NOT NULL,
    PRIMARY KEY (portfolio_id, asset_id),
    FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id),
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id)

);

CREATE TABLE RiskMetric (
    risk_id INT AUTO_INCREMENT,
    portfolio_id INT,
    volatility_score DECIMAL(12,3) NOT NULL,
    sharpe_ratio DECIMAL(12,3) NOT NULL,
    beta DECIMAL(12,3) NOT NULL,
    calculated_at DATETIME NOT NULL,
    PRIMARY KEY (risk_id),
    FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id)
);

CREATE TABLE PriceHistory (
    price_id INT AUTO_INCREMENT,
    asset_id INT,
    close_price DECIMAL(15,3) NOT NULL,
    open_price DECIMAL(15,3) NOT NULL,
    volume DECIMAL(15,3) NOT NULL,
    recorded_date DATETIME NOT NULL,
    PRIMARY KEY (price_id),
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id)
);

CREATE TABLE Watchlist (
    watchlist_id INT AUTO_INCREMENT,
    user_id INT,
    watchlist_type VARCHAR(40) NOT NULL,
    watchlist_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (watchlist_id),
    FOREIGN KEY (user_id) REFERENCES AppUser(user_id)
);

CREATE TABLE PortfolioHistory (
    performance_id INT AUTO_INCREMENT,
    portfolio_id INT,
    total_value DECIMAL(15,3) NOT NULL,
    unrealized_gains DECIMAL(15,3) NOT NULL,
    daily_return DECIMAL(15,3) NOT NULL,
    monthly_return DECIMAL(15,3) NOT NULL,
    recorded_at DATETIME NOT NULL,
    PRIMARY KEY (performance_id),
    FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id)
);

CREATE TABLE WatchlistHolding (
    watchlist_id INT,
    asset_id INT,
    added_date DATETIME NOT NULL,
    max_price DECIMAL(15,3) NOT NULL,
    min_price DECIMAL(15,3) NOT NULL,
    PRIMARY KEY (watchlist_id, asset_id),
    FOREIGN KEY (watchlist_id) REFERENCES Watchlist(watchlist_id),
    FOREIGN KEY (asset_id) REFERENCES Asset(asset_id)

);

-- insert data in AppUser table
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (1, 'john.doe@email.com', 'John', 'Doe', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'); -- password: password123
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (2, 'janesmith@email.com', 'Jane', 'Smith', 'a47c8fce4615590c6bf28e1ee717dbdce6b50f67ffca2bf6f0f6ef721be25635'); -- password: ilovemydog
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (3, 'ahmetmehmet@yahoo.com', 'Ahmet', 'Mehmet', 'cb753c7b04ff5a755d5fedcaf589870cc6bf8c3b68e7f836fecba095ef18a977'); -- password: arsenalfc0
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (4, 'sarajones@gmail.com', 'Sara', 'Jones', 'aa05d6b33a07f0071e667738954877da4f7c3490b68763404872453e4b35456f'); -- password: sara1990
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (5, 'alexdesouza@outlook.com', 'Alex', 'De Souza', 'd210f36ac04f81aa23691af653312892a1646e3fda5a56eeb90dedbcd7d0ed08'); -- password: fenerbahce1907
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (6, 'lisasmith@hotmail.com', 'Lisa', 'Smith', 'bf4f146285ef5088db6da58882659f84fccc849edc82958fdea40ed3f1849d65'); -- password: lisa123321
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (7, 'leodicaprio@gmail.com', 'Leo', 'DiCaprio', '6d46d6578e117390abe7754f95a328030ce0629a3ec4dfb1e436f0f6e7a5ae11'); -- password: shutter_island
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (8, 'bartsimpson@gmail.com', 'Bart', 'Simpson', 'f0e84beb9077ebc110b1b093256505a9a13f1bdeb834dea8a5f44d671dc6a663'); -- password: homermargelisa
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (9, 'ryanpatel@patel.com', 'Ryan', 'Patel', '78069a6a920929d15a3800be17ce889135675a05ac26c25af857182c39100fec'); -- password: mybankpassword
INSERT INTO AppUser (user_id, email, first_name, last_name, password_hash) VALUES (10, 'lisa.simpson@gmail.com', 'Lisa', 'Simpson', 'b38d135e3566266141b761892f5f30f6ae195476ab65e484564826b95a1014fc'); -- password: mathematics3.14

-- insert data into Asset table
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (1, 'AAPL', 'Apple Inc.', 'Stock', 'Technology');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (2, 'GOOGL', 'Alphabet Inc.', 'Stock', 'Technology');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (3, 'TSLA', 'Tesla Inc.', 'Stock', 'Automotive');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (4, 'AMZN', 'Amazon.com Inc.', 'Stock', 'Consumer');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (5, 'SPY', 'SPDR S&P 500 ETF', 'ETF', 'Index');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (6, 'QQQ', 'Invesco QQQ Trust', 'ETF', 'Index');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (7, 'BTC', 'Bitcoin', 'Crypto', 'Cryptocurrency');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (8, 'POLY', 'TandonCoin', 'Crypto', 'Cryptocurrency');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (9, 'MSFT', 'Microsoft Corp.', 'Stock', 'Technology');
INSERT INTO Asset (asset_id, ticker_symbol, asset_name, asset_type, sector) VALUES (10, 'VTI', 'Vanguard Total Stock Market ETF', 'ETF', 'Index');

-- insert data into Portfolio table
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (1, 1, 'these will grow', 'Aggressive');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (2, 1, 'John Retirement', 'Conservative');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (3, 2, 'Tech Portfolio', 'Aggressive');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (4, 3, 'Balanced (hopefully)', 'Moderate');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (5, 4, 'Safe but low return', 'Conservative');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (6, 5, 'my wife is not gonna like this one', 'Aggressive');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (7, 6, 'lisa fund', 'Moderate');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (8, 7, 'Leo DiCaprio Picks (guaranteed to go up)', 'Moderate');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (9, 8, 'ay caramba dividends', 'Conservative');
INSERT INTO Portfolio (portfolio_id, user_id, portfolio_name, risk_profile) VALUES (10, 9, 'Swing trades', 'Aggressive');

-- insert data into AssetTransaction table 
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (1, 1, 1, 'Buy', 50, 175.25, '2025-01-10 09:32:12');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (2, 1, 3, 'Buy', 30, 248.50, '2025-01-15 10:01:42');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (3, 2, 5, 'Buy', 100, 450.00, '2025-02-01 11:15:45');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (4, 3, 2, 'Buy', 20, 140.75, '2025-02-10 09:45:34');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (5, 3, 9, 'Buy', 40, 410.00, '2025-02-12 14:23:19');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (6, 7, 6, 'Buy', 80, 380.50, '2025-02-20 10:54:18');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (7, 8, 1, 'Buy', 25, 175.25, '2025-02-20 09:30:38');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (8, 8, 4, 'Buy', 20, 185.30, '2025-02-25 11:09:59');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (9, 4, 4, 'Buy', 15, 185.30, '2025-03-01 10:30:26');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (10, 9, 5, 'Buy', 50, 450.00, '2025-03-01 09:23:47');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (11, 5, 10, 'Buy', 200, 220.10, '2025-03-05 09:30:34');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (12, 9, 10, 'Buy', 40, 220.10, '2025-03-05 10:03:54');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (13, 10, 3, 'Buy', 10, 248.50, '2025-03-08 09:30:23');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (14, 6, 7, 'Buy', 2, 42000.00, '2025-03-10 12:00:42');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (15, 10, 7, 'Buy', 1, 42000.00, '2025-03-10 12:32:34');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (16, 6, 8, 'Buy', 10, 3200.00, '2025-03-12 13:30:36');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (17, 10, 3, 'Sell', 5, 255.80, '2025-03-18 14:11:35');
INSERT INTO AssetTransaction (transaction_id, portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date) VALUES (18, 1, 1, 'Sell', 10, 182.00, '2025-03-20 15:01:34');

-- insert data into PortfolioHolding table 
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (1, 1, 40, 175.25);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (1, 3, 30, 248.50);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (2, 5, 100, 450.00);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (3, 2, 20, 140.75);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (3, 9, 40, 410.00);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (4, 4, 15, 185.30);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (5, 10, 200, 220.10);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (6, 7, 2, 42000.00);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (6, 8, 10, 3200.00);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (7, 6, 80, 380.50);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (8, 1, 25, 175.25);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (8, 4, 20, 185.30);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (9, 5, 50, 450.00);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (9, 10, 40, 220.10);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (10, 3, 5, 248.50);
INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost) VALUES (10, 7, 1, 42000.00);

-- insert data into RiskMetric table
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (1, 1, 0.25, 1.45, 1.20, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (2, 2, 0.10, 0.95, 0.85, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (3, 3, 0.30, 1.60, 1.35, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (4, 4, 0.18, 1.10, 1.00, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (5, 5, 0.08, 0.80, 0.70, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (6, 6, 0.55, 1.80, 1.50, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (7, 7, 0.12, 1.00, 0.95, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (8, 8, 0.20, 1.25, 1.10, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (9, 9, 0.09, 0.85, 0.75, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (10, 10, 0.35, 1.70, 1.40, '2025-03-01 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (11, 1, 0.27, 1.50, 1.22, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (12, 2, 0.09, 0.92, 0.83, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (13, 3, 0.32, 1.65, 1.38, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (14, 4, 0.19, 1.15, 1.02, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (15, 5, 0.07, 0.78, 0.68, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (16, 6, 0.58, 1.85, 1.53, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (17, 7, 0.13, 1.05, 0.97, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (18, 8, 0.22, 1.30, 1.12, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (19, 9, 0.08, 0.82, 0.73, '2025-03-20 00:00:00');
INSERT INTO RiskMetric (risk_id, portfolio_id, volatility_score, sharpe_ratio, beta, calculated_at) VALUES (20, 10, 0.37, 1.75, 1.43, '2025-03-20 00:00:00');

-- insert data into PriceHistory table 
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (1, 1, 176.30, 174.50, 48000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (2, 2, 141.50, 140.00, 25000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (3, 3, 252.00, 249.00, 42000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (4, 4, 187.80, 185.50, 35000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (5, 5, 452.50, 449.00, 70000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (6, 6, 382.00, 379.50, 39000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (7, 7, 42800.00, 42100.00, 15000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (8, 8, 3280.00, 3210.00, 110000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (9, 9, 413.00, 410.50, 28000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (10, 10, 222.90, 220.50, 55000000, '2025-03-15 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (11, 1, 178.50, 175.00, 52000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (12, 2, 143.20, 141.00, 28000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (13, 3, 255.80, 250.00, 45000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (14, 4, 190.10, 186.00, 38000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (15, 5, 455.30, 451.00, 75000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (16, 6, 385.00, 380.00, 42000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (17, 7, 43500.00, 42000.00, 15000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (18, 8, 3350.00, 3200.00, 120000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (19, 9, 415.60, 410.00, 31000000, '2025-03-20 16:00:00');
INSERT INTO PriceHistory (price_id, asset_id, close_price, open_price, volume, recorded_date) VALUES (20, 10, 224.80, 221.00, 60000000, '2025-03-20 16:00:00');

-- insert data into Watchlist table
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (1, 1, 'Tech', 'Johns tech watch');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (2, 2, 'Growth', 'growth  guaranteed');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (3, 3, 'Crypto', 'wallet is gone');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (4, 4, 'ETF', 'ETF Tracker1');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (5, 5, 'Tech', 'random');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (6, 6, 'Value', 'Value');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (7, 7, 'Dividend', 'dividends');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (8, 8, 'Growth', 'ay caramba stocks');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (9, 9, 'Crypto', 'cryptos');
INSERT INTO Watchlist (watchlist_id, user_id, watchlist_type, watchlist_name) VALUES (10, 10, 'Index', 'my index watch');

-- insert data into PortfolioHistory table 
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (1, 1, 16375.00, 157.50, 0.008, 0.032, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (2, 2, 45250.00, 250.00, 0.002, 0.008, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (3, 3, 19350.00, 135.00, 0.010, 0.040, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (4, 4, 2817.00, 37.50, 0.005, 0.020, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (5, 5, 44580.00, 560.00, 0.001, 0.006, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (6, 6, 118400.00, 2400.00, 0.018, 0.060, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (7, 7, 30560.00, 120.00, 0.003, 0.014, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (8, 8, 8163.50, 76.25, 0.004, 0.018, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (9, 9, 31541.00, 237.00, 0.002, 0.009, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (10, 10, 45320.00, 835.00, 0.015, 0.055, '2025-03-15 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (11, 1, 14814.00, 349.00, 0.012, 0.045, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (12, 2, 45530.00, 530.00, 0.003, 0.012, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (13, 3, 19488.00, 273.00, 0.015, 0.058, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (14, 4, 2851.50, 72.00, 0.008, 0.030, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (15, 5, 44960.00, 940.00, 0.002, 0.010, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (16, 6, 120500.00, 4500.00, 0.025, 0.085, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (17, 7, 30800.00, 360.00, 0.005, 0.020, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (18, 8, 8264.50, 177.25, 0.007, 0.028, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (19, 9, 31757.00, 453.00, 0.003, 0.011, '2025-03-20 16:00:00');
INSERT INTO PortfolioHistory (performance_id, portfolio_id, total_value, unrealized_gains, daily_return, monthly_return, recorded_at) VALUES (20, 10, 44779.00, 1536.50, 0.018, 0.065, '2025-03-20 16:00:00');

-- insert data into WatchlistHolding table 
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (1, 1, '2025-01-05 10:53:12', 182.00, 168.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (1, 9, '2025-01-05 10:46:32', 420.00, 395.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (2, 3, '2025-01-10 14:12:42', 260.00, 230.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (3, 7, '2025-01-12 09:21:23', 45000.00, 38000.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (3, 8, '2025-01-12 09:45:31', 3500.00, 2900.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (4, 5, '2025-02-01 11:32:34', 460.00, 440.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (5, 2, '2025-02-05 13:22:56', 148.00, 135.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (6, 4, '2025-02-10 10:11:11', 195.00, 178.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (7, 1, '2025-02-15 09:43:02', 180.00, 170.00);
INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) VALUES (9, 7, '2025-03-01 08:34:06', 44000.00, 40000.00);
