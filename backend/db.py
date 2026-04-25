import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv("../.env")

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

def get_user_by_login(username, hashed_pwd):
    print("1 - about to connect")
    connection = get_connection()
    print("2 - connected")
    cursor = connection.cursor()
    print("3 - cursor created")
    cursor.execute("SELECT user_id, first_name, last_name, email FROM AppUser WHERE email = %s AND password_hash = %s;", (username, hashed_pwd))
    print("4 - query executed")
    output = cursor.fetchone()
    print("5 - fetched result")
    cursor.close()
    connection.close()
    if output == None:  
        return -1
    return output
