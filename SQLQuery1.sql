-- Create the tasks table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'tasks')
BEGIN
    CREATE TABLE dbo.tasks (
        id INT NOT NULL IDENTITY(1,1),
        user_id INT NULL,
        assigned_user_id INT NULL,
        order_id INT NULL,
        status_id CHAR(1) NOT NULL CONSTRAINT DF_tasks_status_id DEFAULT ('Q'),
        description VARCHAR(MAX) NULL,
        date_due DATETIME NULL,  -- Change to DATETIME
        date_completed DATETIME NULL,  -- Change to DATETIME
        created_at DATETIME NULL,  -- Change to DATETIME
        updated_at DATETIME NULL,  -- Change to DATETIME
        CONSTRAINT PK_tasks PRIMARY KEY (id)
    );
END;
GO

-- Create indexes on tasks
CREATE INDEX IX_tasks_user_id ON dbo.tasks(user_id);
CREATE INDEX IX_tasks_assigned_user_id ON dbo.tasks(assigned_user_id);
CREATE INDEX IX_tasks_order_id ON dbo.tasks(order_id);
CREATE INDEX IX_tasks_status_id ON dbo.tasks(status_id);
GO

-- Insert data into the tasks table with converted UNIX timestamps
SET IDENTITY_INSERT dbo.tasks ON;
INSERT INTO dbo.tasks (id, user_id, assigned_user_id, order_id, status_id, description, date_due, date_completed, created_at, updated_at)
VALUES 
    (1, 1, 751, 4000, 'Q', 'TASK A', DATEADD(SECOND, 0, '1970-01-01'), NULL, DATEADD(SECOND, 0, '1970-01-01'), DATEADD(SECOND, 0, '1970-01-01')),
    (2, 1, 751, 4000, 'C', 'TASK B', DATEADD(SECOND, 0, '1970-01-01'), NULL, DATEADD(SECOND, 0, '1970-01-01'), DATEADD(SECOND, 0, '1970-01-01')),
    (3, 1, 751, 4000, 'Q', 'TASK C', DATEADD(SECOND, 0, '1970-01-01'), NULL, DATEADD(SECOND, 0, '1970-01-01'), DATEADD(SECOND, 0, '1970-01-01')),
    (4, 1, 751, 4000, 'Q', 'TASK D', DATEADD(SECOND, 0, '1970-01-01'), NULL, DATEADD(SECOND, 0, '1970-01-01'), DATEADD(SECOND, 0, '1970-01-01')),
    (5, 1, 751, 4000, 'Q', 'TASK E', DATEADD(SECOND, 0, '1970-01-01'), NULL, DATEADD(SECOND, 0, '1970-01-01'), DATEADD(SECOND, 0, '1970-01-01'));
SET IDENTITY_INSERT dbo.tasks OFF;
GO

-- Create the task_dependencies table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'task_dependencies')
BEGIN
    CREATE TABLE dbo.task_dependencies (
        id INT NOT NULL IDENTITY(1,1),
        task_id INT NOT NULL,
        dependent_task_id INT NOT NULL,
        CONSTRAINT PK_task_dependencies PRIMARY KEY (id)
    );
END;
GO

-- Create indexes on task_dependencies
CREATE INDEX IX_task_dependencies_task_id ON dbo.task_dependencies(task_id);
CREATE INDEX IX_task_dependencies_dependent_task_id ON dbo.task_dependencies(dependent_task_id);
GO

-- Insert data into the task_dependencies table
SET IDENTITY_INSERT dbo.task_dependencies ON;
INSERT INTO dbo.task_dependencies (id, task_id, dependent_task_id)
VALUES
    (1, 3, 2),
    (2, 5, 3),
    (3, 5, 4);
SET IDENTITY_INSERT dbo.task_dependencies OFF;
GO

-- Add a foreign key constraint on task_dependencies referencing tasks
ALTER TABLE dbo.task_dependencies
ADD CONSTRAINT FK_task_dependencies_task
FOREIGN KEY (task_id)
REFERENCES dbo.tasks (id)
ON DELETE CASCADE;
GO

-- Example SELECT query (converted from MySQL)
-- This query selects tasks assigned to user 751, with status 'Q', 
-- that do not have any dependencies on tasks still in status 'Q'.
SELECT 
    t.*,
    t.date_due AS due_date  -- Already a DATETIME field
FROM dbo.tasks t
WHERE t.assigned_user_id = 751
  AND t.status_id = 'Q'
  AND t.id NOT IN (
      SELECT td.task_id
      FROM dbo.task_dependencies td
      INNER JOIN dbo.tasks t2 ON td.dependent_task_id = t2.id
      WHERE t2.status_id = 'Q'
  )
ORDER BY t.date_due;
GO
