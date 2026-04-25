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
