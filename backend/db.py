import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv(os.path.join(os.path.dirname(__file__), "../.env"))

mysql_host = os.getenv("MYSQL_HOST")
mysql_user = os.getenv("MYSQL_USER")
mysql_pwd = os.getenv("MYSQL_PASSWORD")
mysql_db_name = os.getenv("MYSQL_DB")
mysql_port = os.getenv("MYSQL_PORT")
print(f"db.py: {mysql_port}")


def get_connection():
    connection = mysql.connector.connect(
        host=mysql_host,
        user=mysql_user,
        password=mysql_pwd,
        database=mysql_db_name,
        port=int(mysql_port)
    )
    return connection

def get_user_by_login(email, hashed_pwd):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("SELECT user_id, first_name, last_name, email FROM AppUser WHERE email = %s AND password_hash = %s;", (email, hashed_pwd))
    output = cursor.fetchone() # just fetch the first result
    cursor.close()
    connection.close()
    if output == None:  
        return -1
    return output

def create_user(email, first_name, last_name, hashed_pwd):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an insert so we wrapped it up in a try except block
        cursor.execute("""INSERT INTO AppUser (email, first_name, last_name, password_hash) VALUES (%s, %s, %s, %s);""", (email, first_name, last_name, hashed_pwd))
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def get_user_portfolios(user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT p.portfolio_name, p.risk_profile, poh.total_value, poh.daily_return, p.portfolio_id 
                   FROM Portfolio p 
                   LEFT JOIN PortfolioHistory poh 
                   ON p.portfolio_id = poh.portfolio_id AND poh.recorded_at = 
                                                        (SELECT MAX(recorded_at) FROM PortfolioHistory WHERE portfolio_id = p.portfolio_id)
                   WHERE p.user_id = %s;""", (user_id,)) # a tuple because execute requires a tuple, and left join because if a user made a watchlist without any assets in it that would hide the entire watchlist
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_user_watchlists(user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT w.watchlist_name, w.watchlist_id, COUNT(wh.asset_id) 
                   FROM Watchlist w 
                   LEFT JOIN WatchlistHolding wh 
                   ON w.watchlist_id = wh.watchlist_id 
                   WHERE w.user_id = %s 
                   GROUP BY w.watchlist_id, w.watchlist_name""", (user_id,)) # left join because if a user made a watchlist without any assets in it that would hide the entire watchlist
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output


def get_portfolio_holdings(portfolio_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT
        a.ticker_symbol, a.asset_name, a.asset_type,
        ph_hold.total_quantity, ph_hold.average_cost,
        ph_price.close_price,
        ROUND(ph_price.close_price * ph_hold.total_quantity, 2) AS current_value,
        ROUND((ph_price.close_price - ph_hold.average_cost) * ph_hold.total_quantity, 2) AS unrealized_gain
        FROM PortfolioHolding ph_hold
        INNER JOIN Asset a ON ph_hold.asset_id = a.asset_id
        INNER JOIN PriceHistory ph_price ON a.asset_id = ph_price.asset_id
        WHERE ph_hold.portfolio_id = %s AND ph_price.recorded_date = (
        SELECT MAX(recorded_date) FROM PriceHistory WHERE asset_id = a.asset_id);""", (portfolio_id,)) 
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_portfolio_risk_metrics(portfolio_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT volatility_score, sharpe_ratio, beta, calculated_at
                    FROM RiskMetric
                    WHERE portfolio_id = %s
                    AND calculated_at = (SELECT MAX(calculated_at) FROM RiskMetric WHERE portfolio_id = %s);""", (portfolio_id, portfolio_id)) # we pass it twice because there are two placeholders execute has to iterate
    output = cursor.fetchone() # fetch one
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_portfolio_transactions(portfolio_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT a.ticker_symbol, a.asset_name, t.transaction_type, t.quantity, t.price_per_unit,
                    ROUND(t.quantity * t.price_per_unit, 2) AS total_cost, t.transaction_date
                    FROM AssetTransaction t
                    INNER JOIN Asset a ON t.asset_id = a.asset_id
                    WHERE t.portfolio_id = %s
                    ORDER BY t.transaction_date DESC;""", (portfolio_id,)) 
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_portfolio_history(portfolio_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT total_value, unrealized_gains, daily_return, monthly_return, recorded_at 
                   FROM PortfolioHistory 
                   WHERE portfolio_id = %s 
                   ORDER BY recorded_at DESC""", (portfolio_id,)) 
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_watchlist_holdings(watchlist_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT a.ticker_symbol, a.asset_name, wh.max_price, wh.min_price, ph.close_price, wh.added_date,
                    ((ph.close_price - ph_prev.close_price) / ph_prev.close_price) AS change24hr
                    FROM WatchlistHolding wh
                    INNER JOIN Asset a ON wh.asset_id = a.asset_id
                    INNER JOIN PriceHistory ph ON a.asset_id = ph.asset_id
                    INNER JOIN PriceHistory ph_prev ON a.asset_id = ph_prev.asset_id
                    WHERE wh.watchlist_id = %s
                    AND ph.recorded_date = (SELECT MAX(recorded_date) FROM PriceHistory WHERE asset_id = a.asset_id) -- get most recent pricehistory
                    AND ph_prev.recorded_date = 
                        (SELECT MAX(recorded_date) 
                        FROM PriceHistory 
                        WHERE asset_id = a.asset_id AND recorded_date < ph.recorded_date); -- get the most second recent price history""", (watchlist_id,)) 
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_all_assets():
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT * FROM Asset;""") 
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def search_assets(searched_term):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    searched_term = f"%{searched_term}%" # wrap it up in modulo symbol
    cursor.execute("""SELECT asset_id, ticker_symbol, asset_name, asset_type, sector
                        FROM Asset
                        WHERE ticker_symbol LIKE %s OR asset_name LIKE %s;""", (searched_term, searched_term))  # dont put extra modulo symbols because if we hadt wrapped it up it would conflict with the %s of mysql
    output = cursor.fetchall() # fetch all the results
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def add_transaction(portfolio_id, asset_id, transaction_type, quantity, price):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an insert so we wrapped it up in a try except block
        cursor.execute("""INSERT INTO AssetTransaction (portfolio_id, asset_id, transaction_type, quantity, price_per_unit, transaction_date)
                            VALUES (%s, %s, %s, %s, %s, NOW());""", (portfolio_id, asset_id, transaction_type, quantity, price))
        cursor.execute("""CALL record_portfolio_snapshot(%s, NOW())""", (portfolio_id,)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def get_portfolio_info(portfolio_id, user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT portfolio_name, risk_profile 
                   FROM Portfolio 
                   WHERE portfolio_id = %s AND user_id = %s""", (portfolio_id, user_id)) 
    output = cursor.fetchone() # fetch the result
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output

def get_watchlist_info(watchlist_id, user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    cursor.execute("""SELECT watchlist_name, watchlist_type 
                   FROM Watchlist 
                   WHERE watchlist_id = %s AND user_id = %s""", (watchlist_id, user_id)) 
    output = cursor.fetchone() # fetch the result
    cursor.close()
    connection.close()
    if not output:  
        return -1
    return output


def add_to_watchlist(watchlist_id, asset_id, max_price, min_price):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an insert so we wrapped it up in a try except block
        cursor.execute("""INSERT INTO WatchlistHolding (watchlist_id, asset_id, added_date, max_price, min_price) 
                            VALUES (%s, %s, NOW(), %s, %s)""", (watchlist_id, asset_id, max_price, min_price)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()


def update_portfolio(portfolio_id, new_name, new_risk_profile, user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an update so we wrapped it up in a try except block
        cursor.execute("""UPDATE Portfolio
                            SET portfolio_name = %s, risk_profile = %s
                            WHERE portfolio_id = %s AND user_id = %s;""", (new_name, new_risk_profile, portfolio_id, user_id)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def delete_portfolio(portfolio_id, user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its a delete so we wrapped it up in a try except block
        cursor.execute("""DELETE FROM AssetTransaction WHERE portfolio_id = %s;""", (portfolio_id,)) 
        cursor.execute("""DELETE FROM RiskMetric WHERE portfolio_id = %s;""", (portfolio_id,))
        cursor.execute("""DELETE FROM PortfolioHistory WHERE portfolio_id = %s;""", (portfolio_id,))
        cursor.execute("""DELETE FROM PortfolioHolding WHERE portfolio_id = %s""", (portfolio_id,))
        cursor.execute("""DELETE FROM Portfolio WHERE portfolio_id = %s AND user_id = %s;""", (portfolio_id,user_id))
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def delete_watchlist(watchlist_id, user_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its a delete so we wrapped it up in a try except block
        cursor.execute("""DELETE FROM WatchlistHolding
                       WHERE watchlist_id = %s;""", (watchlist_id,))
        cursor.execute("""DELETE FROM Watchlist
                       WHERE watchlist_id = %s AND user_id = %s;""", (watchlist_id, user_id))
        connection.commit() # save the changes 
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def remove_from_watchlist(watchlist_id, asset_id):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its a delete so we wrapped it up in a try except block
        cursor.execute("""DELETE FROM WatchlistHolding
                       WHERE watchlist_id = %s AND asset_id = %s;""", (watchlist_id, asset_id)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()


def create_portfolio(user_id, name, risk_profile):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an insert so we wrapped it up in a try except block
        cursor.execute("""INSERT INTO Portfolio (user_id, portfolio_name, risk_profile)
                        VALUES (%s, %s, %s);""", (user_id, name, risk_profile)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()

def get_holding_quantity(portfolio_id, asset_id):
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("""SELECT total_quantity FROM PortfolioHolding
                   WHERE portfolio_id = %s AND asset_id = %s""", (portfolio_id, asset_id))
    output = cursor.fetchone()
    cursor.close()
    connection.close()
    if not output:
        return 0
    return float(output[0])

def create_watchlist(user_id, name, watchlist_type):
    connection = get_connection() # connect to railway (our mysql db server)
    cursor = connection.cursor() # a cursor is a pointer that allows us to go through query results
    try: ## we wont confirm this with select etc since its an insert so we wrapped it up in a try except block
        cursor.execute("""INSERT INTO Watchlist (user_id, watchlist_type, watchlist_name) 
                            VALUES (%s, %s, %s)""", (user_id, watchlist_type, name)) 
        connection.commit() # save the changes
    except:
        cursor.close()
        connection.close()
        return -1
    cursor.close()
    connection.close()