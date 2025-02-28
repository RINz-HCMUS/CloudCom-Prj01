from flask import Flask, request, jsonify, redirect
from flask_cors import CORS
import pymysql

app = Flask(__name__)
CORS(app)  # Bật CORS để cho phép frontend S3 gọi API

# Cấu hình đường dẫn S3
S3_BUCKET_URL = ""

# Cấu hình kết nối MySQL trên AWS RDS
DB_HOST = ""
DB_USERNAME = ""
DB_PASSWORD = ""
DB_DATABASE = ""

# Hàm kết nối MySQL
def get_db_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USERNAME,
        password=DB_PASSWORD,
        database=DB_DATABASE,
        cursorclass=pymysql.cursors.DictCursor
    )

# Chuyển hướng đến giao diện frontend trên S3
@app.route('/')
def index():
    return redirect(f"{S3_BUCKET_URL}/index.html")

@app.route('/add')
def add_task_page():
    return redirect(f"{S3_BUCKET_URL}/add_task.html")

@app.route('/edit/<int:id>')
def edit_task_page(id):
    return redirect(f"{S3_BUCKET_URL}/edit_task.html?id={id}")

# API lấy danh sách task
@app.route('/tasks', methods=['GET'])
def get_tasks():
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM tasks ORDER BY date_due")
                tasks = cursor.fetchall()
        return jsonify(tasks)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# API lấy task theo ID
@app.route('/task/<int:id>', methods=['GET'])
def get_task(id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM tasks WHERE id = %s", (id,))
                task = cursor.fetchone()
        if task:
            return jsonify(task)
        return jsonify({"error": "Task not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# API thêm task
@app.route('/add_task', methods=['POST'])
def add_task():
    data = request.get_json()
    if not data or "description" not in data or "status_id" not in data or "date_due" not in data:
        return jsonify({"error": "Invalid data"}), 400

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                sql = "INSERT INTO tasks (description, status_id, date_due) VALUES (%s, %s, %s)"
                cursor.execute(sql, (data["description"], data["status_id"], data["date_due"]))
                conn.commit()
        return jsonify({"message": "Task added successfully!"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# API cập nhật task
@app.route('/task/<int:id>', methods=['PUT'])
def update_task(id):
    data = request.get_json()
    if not data or "description" not in data or "status_id" not in data or "date_due" not in data:
        return jsonify({"error": "Invalid data"}), 400

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                sql = "UPDATE tasks SET description = %s, status_id = %s, date_due = %s WHERE id = %s"
                cursor.execute(sql, (data["description"], data["status_id"], data["date_due"], id))
                conn.commit()
        return jsonify({"message": "Task updated successfully!"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# API xóa task
@app.route('/delete_task/<int:id>', methods=['DELETE'])
def delete_task(id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM tasks WHERE id = %s", (id,))
                conn.commit()
        return jsonify({"message": "Task deleted successfully!"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
