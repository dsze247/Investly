from flask import Flask, render_template, request, redirect, session
import hashlib
import os
from dotenv import load_dotenv
load_dotenv()
from backend.db import *

secretkey = os.getenv("FLASK_SECRET_KEY")

if secretkey:
    print(f"successfully retrieved key: {secretkey} FOR DEBUG PURPOSES. REMOVE THIS LINE LATER.")
else:
    print("secret key not found. check your .env file.")

app = Flask(__name__)
app.secret_key = secretkey

# main page - screen 0 
@app.route("/")
def app_main():
    if "user_id" in session:
        return redirect("/dashboard")
    else:
        return render_template("main.html")

# login page - screen 0
@app.route("/login", methods=['GET', "POST"])
def app_login():
    if request.method == 'GET':
        return render_template("login.html")
    else:
        result = get_user_by_login(request.form["email"], hashlib.sha256(request.form["password"].encode()).hexdigest())
        if result == -1:
            return render_template("login.html", error="Invalid email or password.")
        session["user_id"] = result[0]
        session["first_name"] = result[1]
        session["last_name"] = result[2]
        session["email"] = result[3]
        return redirect("/dashboard")

# signup page - screen 0
@app.route("/signup", methods=['GET', "POST"])
def app_signup():
    if request.method == 'GET':
        return render_template("signup.html")
    else:
        hashed = hashlib.sha256(request.form["password"].encode()).hexdigest()
        result = create_user(request.form["email"], request.form["first_name"], request.form["last_name"], hashed)
        if result == -1:
            return render_template("signup.html", error="An account with that email already exists.")
        return redirect("/login")

# dashboard - screen 1
@app.route("/dashboard")
def app_dashboard():
    if "user_id" in session:
        portfolios = get_user_portfolios(session["user_id"])
        watchlists = get_user_watchlists(session["user_id"])
        if portfolios == -1:
            portfolios = []
        if watchlists == -1:
            watchlists = []
        return render_template("dashboard.html", portfolios=portfolios, watchlists=watchlists)
    else:
        return redirect("/login")

# logout
@app.route("/logout")
def app_logout():
    session.clear()
    return redirect("/")

# portfolio details - screen 2
@app.route("/portfoliodetails/<int:portfolio_id>")
def app_portfolio_details(portfolio_id):
    if "user_id" in session:
        user_id = session["user_id"]
        portfolio_info = get_portfolio_info(portfolio_id, user_id)
        if portfolio_info == -1:
            return redirect("/dashboard")
        portfolio_risk_metrics = get_portfolio_risk_metrics(portfolio_id)
        portfolio_holdings = get_portfolio_holdings(portfolio_id)
        portfolio_transactions = get_portfolio_transactions(portfolio_id)
        portfolio_history = get_portfolio_history(portfolio_id)
        return render_template("portfoliodetails.html",
                                info=portfolio_info,
                                holdings=portfolio_holdings,
                                risk=portfolio_risk_metrics,
                                transactions=portfolio_transactions,
                                history=portfolio_history,
                                portfolio_id=portfolio_id)
    else:
        return redirect("/login")

# watchlist details - screen 2
@app.route("/watchlistdetails/<int:watchlist_id>")
def app_watchlist_details(watchlist_id):
    if "user_id" in session:
        user_id = session["user_id"]
        watchlist_info = get_watchlist_info(watchlist_id, user_id)
        if watchlist_info == -1:
            return redirect("/dashboard")
        watchlist_holdings = get_watchlist_holdings(watchlist_id)
        return render_template("watchlistdetails.html",
                                info=watchlist_info,
                                holdings=watchlist_holdings,
                                watchlist_id=watchlist_id)
    else:
        return redirect("/login")

# buy/sell trade form - screen 3
@app.route("/assetaction", methods=["GET", "POST"])
def app_assetaction():
    if "user_id" not in session:
        return redirect("/login")
    portfolios = get_user_portfolios(session["user_id"])
    if portfolios == -1:
        portfolios = []
    assets = get_all_assets()
    if assets == -1:
        assets = []
    if request.method == "GET":
        preselected = request.args.get("portfolio_id", "")
        return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected)
    # POST
    portfolio_id = request.form.get("portfolio_id")
    asset_id = request.form.get("asset_id")
    transaction_type = request.form.get("transaction_type")
    quantity = request.form.get("quantity")
    price = request.form.get("price")
    preselected = portfolio_id or ""
    if not all([portfolio_id, asset_id, transaction_type, quantity, price]):
        return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected, error="All fields are required.")
    try:
        quantity = float(quantity)
        price = float(price)
    except ValueError:
        return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected, error="Invalid quantity or price.")
    if quantity <= 0 or price <= 0:
        return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected, error="Quantity and price must be greater than 0.")
    if transaction_type == "Sell":
        current_qty = get_holding_quantity(int(portfolio_id), int(asset_id))
        if quantity > current_qty:
            return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected,
                                   error=f"Cannot sell {quantity} — you only hold {current_qty}.")
    result = add_transaction(int(portfolio_id), int(asset_id), transaction_type, quantity, price)
    if result == -1:
        return render_template("assetaction.html", portfolios=portfolios, assets=assets, preselected=preselected, error="Transaction failed. Please try again.")
    return redirect(f"/portfoliodetails/{portfolio_id}")

# portfolio/watchlist action form, create portfolio/watchlist etc
@app.route("/listaction")
def app_listaction():
    return "<p> list action form. should facilitate creating portfolios and watchlists</p>"


if __name__ == "__main__":
    app.run(debug=True)