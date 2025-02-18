from flask import Flask, render_template, request, redirect, url_for
import pyodbc
from datetime import datetime

app = Flask(__name__)

# Database connection settings
DB_SERVER = 'localhost\\SQLEXPRESS'
DB_DATABASE = 'master'
DB_USERNAME = 'sa'
DB_PASSWORD = ''  # Your password here

def get_db_connection():
    conn = pyodbc.connect(f'DRIVER={{SQL Server}};SERVER={DB_SERVER};DATABASE={DB_DATABASE};UID={DB_USERNAME};PWD={DB_PASSWORD}')
    return conn

# READ - Show all tasks
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, description, status_id, date_due FROM tasks ORDER BY date_due")
    tasks = cursor.fetchall()
    conn.close()
    return render_template('index.html', tasks=tasks)

# CREATE - Add a new task
@app.route('/add', methods=['GET', 'POST'])
def add_task():
    if request.method == 'POST':
        description = request.form['description']
        status_id = request.form['status_id']
        date_due = request.form['date_due']  # This is the date from the date picker
        
        # Assuming the default values for other fields:
        user_id = 1  # Set this to your value or take it from session
        assigned_user_id = 751  # Default or dynamic
        order_id = 4000  # Default value
        
        # Check if date_due is provided
        if date_due:
            # Convert date_due to a proper datetime format
            date_due = datetime.strptime(date_due, '%Y-%m-%dT%H:%M')  # Convert the string to datetime object
        else:
            # Set date_due to None (SQL NULL) if it's empty
            date_due = None
        
        # Set created_at and updated_at to current time
        created_at = updated_at = datetime.now()
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO tasks (user_id, assigned_user_id, order_id, description, status_id, date_due, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (user_id, assigned_user_id, order_id, description, status_id, date_due, created_at, updated_at))
        conn.commit()
        conn.close()
        
        return redirect(url_for('index'))
    
    return render_template('add_task.html')

# UPDATE - Edit a task
@app.route('/edit/<int:id>', methods=['GET', 'POST'])
def edit_task(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, description, status_id, date_due FROM tasks WHERE id = ?", (id,))
    task = cursor.fetchone()
    conn.close()

    if request.method == 'POST':
        description = request.form['description']
        status_id = request.form['status_id']
        date_due = request.form['date_due']  # This is the date from the date picker

        # Check if date_due is provided
        if date_due:
            # Convert date_due to a proper datetime format
            date_due = datetime.strptime(date_due, '%Y-%m-%dT%H:%M')  # Convert the string to datetime object
        else:
            # Set date_due to None (SQL NULL) if it's empty
            date_due = None
        
        updated_at = datetime.now()

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE tasks 
            SET description = ?, status_id = ?, date_due = ?, updated_at = ?
            WHERE id = ?
        """, (description, status_id, date_due, updated_at, id))
        conn.commit()
        conn.close()
        
        return redirect(url_for('index'))
    
    return render_template('edit_task.html', task=task)

# DELETE - Delete a task
@app.route('/delete/<int:id>', methods=['POST'])
def delete_task(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM tasks WHERE id = ?", (id,))
    conn.commit()
    conn.close()
    
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
