# Investly

## Setup 

### 1. Create the MySQL Database
Create your database using your preferred MySQL client or CLI.

---

### 2. Set Up the Python Environment

1. Create a virtual environment:
   ```
   python3 -m venv venv
   ```

3. Activate the virtual environment:
   ```
   source venv/bin/activate  
   # On Windows: venv\Scripts\activate
   ```

5. Create a `requirements.txt` file containing:
   ```
   flask
   flask-mysqldb
   ```

6. Install the dependencies
   ```
   pip install -r requirements.txt
   ```

---

### 3. Running the app
To run the app, run: 
   ```
   python3 app.py
   ```