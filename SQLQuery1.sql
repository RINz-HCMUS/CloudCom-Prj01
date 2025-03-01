-- Tạo database nếu chưa có (bạn có thể bỏ qua nếu đã có database)
CREATE DATABASE IF NOT EXISTS TaskManager;
USE TaskManager;

-- Tạo bảng tasks
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    assigned_user_id INT NOT NULL,
    order_id INT NOT NULL,
    status_id VARCHAR(10) NOT NULL,
    description VARCHAR(255) NOT NULL,
    date_due DATETIME NOT NULL,
    date_completed DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tạo bảng task_dependencies
CREATE TABLE IF NOT EXISTS task_dependencies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    dependent_task_id INT NOT NULL,
    CONSTRAINT FK_task_dependencies_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- Tạo index trên bảng task_dependencies để tối ưu truy vấn
CREATE INDEX IX_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX IX_task_dependencies_dependent_task_id ON task_dependencies(dependent_task_id);

-- Chèn dữ liệu vào bảng tasks
INSERT INTO tasks (id, user_id, assigned_user_id, order_id, status_id, description, date_due, date_completed, created_at, updated_at)
VALUES 
    (1, 1, 751, 4000, 'Q', 'TASK A', FROM_UNIXTIME(0), NULL, FROM_UNIXTIME(0), FROM_UNIXTIME(0)),
    (2, 1, 751, 4000, 'C', 'TASK B', FROM_UNIXTIME(0), NULL, FROM_UNIXTIME(0), FROM_UNIXTIME(0)),
    (3, 1, 751, 4000, 'Q', 'TASK C', FROM_UNIXTIME(0), NULL, FROM_UNIXTIME(0), FROM_UNIXTIME(0)),
    (4, 1, 751, 4000, 'Q', 'TASK D', FROM_UNIXTIME(0), NULL, FROM_UNIXTIME(0), FROM_UNIXTIME(0)),
    (5, 1, 751, 4000, 'Q', 'TASK E', FROM_UNIXTIME(0), NULL, FROM_UNIXTIME(0), FROM_UNIXTIME(0));

-- Chèn dữ liệu vào bảng task_dependencies
INSERT INTO task_dependencies (id, task_id, dependent_task_id)
VALUES
    (1, 3, 2),
    (2, 5, 3),
    (3, 5, 4);

-- Truy vấn kiểm tra dữ liệu đã chèn thành công
SELECT * FROM tasks;
SELECT * FROM task_dependencies;
