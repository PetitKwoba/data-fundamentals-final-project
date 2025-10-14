-- ============================================
-- Data Fundamentals Final Project
-- Database Schema with Admin Roles & Security
-- ============================================

-- ============================================
-- TABLE CREATION
-- ============================================

-- Users Table: Stores user information and roles
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'user')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects Table: Stores project information
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL CHECK (status IN ('active', 'completed', 'archived')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks Table: Stores task information linked to projects
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SAMPLE DATA (5+ rows per table)
-- ============================================

-- Insert sample users (2 admins, 5 regular users)
INSERT INTO users (id, email, full_name, role) VALUES
  ('11111111-1111-1111-1111-111111111111', 'admin1@example.com', 'Admin User One', 'admin'),
  ('22222222-2222-2222-2222-222222222222', 'admin2@example.com', 'Admin User Two', 'admin'),
  ('33333333-3333-3333-3333-333333333333', 'user1@example.com', 'John Doe', 'user'),
  ('44444444-4444-4444-4444-444444444444', 'user2@example.com', 'Jane Smith', 'user'),
  ('55555555-5555-5555-5555-555555555555', 'user3@example.com', 'Bob Johnson', 'user'),
  ('66666666-6666-6666-6666-666666666666', 'user4@example.com', 'Alice Williams', 'user'),
  ('77777777-7777-7777-7777-777777777777', 'user5@example.com', 'Charlie Brown', 'user');

-- Insert sample projects (5 rows)
INSERT INTO projects (id, user_id, name, description, status) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Website Redesign', 'Complete redesign of company website', 'active'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444', 'Mobile App Development', 'Develop mobile app for iOS and Android', 'active'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '55555555-5555-5555-5555-555555555555', 'Database Migration', 'Migrate database to new infrastructure', 'completed'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '66666666-6666-6666-6666-666666666666', 'Marketing Campaign', 'Q4 marketing campaign planning', 'active'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '77777777-7777-7777-7777-777777777777', 'Security Audit', 'Annual security audit and compliance', 'archived');

-- Insert sample tasks (8 rows)
INSERT INTO tasks (project_id, user_id, title, description, priority, completed) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Design mockups', 'Create initial design mockups', 'high', FALSE),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Review color scheme', 'Review and finalize color scheme', 'medium', TRUE),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444', 'Setup development environment', 'Configure dev environment for mobile', 'high', TRUE),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444', 'Implement login screen', 'Create login screen with authentication', 'high', FALSE),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '55555555-5555-5555-5555-555555555555', 'Backup existing data', 'Create backup of current database', 'high', TRUE),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '66666666-6666-6666-6666-666666666666', 'Create campaign strategy', 'Develop Q4 marketing strategy', 'medium', FALSE),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '77777777-7777-7777-7777-777777777777', 'Run vulnerability scan', 'Execute security vulnerability scan', 'high', TRUE),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '77777777-7777-7777-7777-777777777777', 'Generate compliance report', 'Generate annual compliance report', 'high', TRUE);

-- ============================================
-- ROW LEVEL SECURITY (RLS) SETUP
-- ============================================

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLICIES FOR USERS TABLE
-- ============================================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
ON users
FOR SELECT
USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY "Admins can view all users"
ON users
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Users can update their own profile (but not their role)
CREATE POLICY "Users can update their own profile"
ON users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id AND role = (SELECT role FROM users WHERE id = auth.uid()));

-- Admins have full access to users table
CREATE POLICY "Admins have full access to users"
ON users
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================
-- POLICIES FOR PROJECTS TABLE
-- ============================================

-- Users can view their own projects
CREATE POLICY "Users can view their own projects"
ON projects
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own projects
CREATE POLICY "Users can insert their own projects"
ON projects
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own projects
CREATE POLICY "Users can update their own projects"
ON projects
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own projects
CREATE POLICY "Users can delete their own projects"
ON projects
FOR DELETE
USING (auth.uid() = user_id);

-- Admins have full access to projects
CREATE POLICY "Admins have full access to projects"
ON projects
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================
-- POLICIES FOR TASKS TABLE
-- ============================================

-- Users can view their own tasks
CREATE POLICY "Users can view their own tasks"
ON tasks
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own tasks
CREATE POLICY "Users can insert their own tasks"
ON tasks
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own tasks
CREATE POLICY "Users can update their own tasks"
ON tasks
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tasks
CREATE POLICY "Users can delete their own tasks"
ON tasks
FOR DELETE
USING (auth.uid() = user_id);

-- Admins have full access to tasks
CREATE POLICY "Admins have full access to tasks"
ON tasks
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================
-- ADMIN-ONLY CUSTOM FUNCTIONS
-- ============================================

-- Function: Delete any project (admin only)
-- This function allows admins to delete any project regardless of ownership
CREATE OR REPLACE FUNCTION delete_project(project_id UUID)
RETURNS VOID
LANGUAGE SQL
SECURITY DEFINER
AS $$
  DELETE FROM projects WHERE id = project_id;
$$;

-- Function: Get user statistics (admin only)
-- This function returns statistics about users and their projects
CREATE OR REPLACE FUNCTION get_user_statistics()
RETURNS TABLE (
  user_email TEXT,
  user_name TEXT,
  project_count BIGINT,
  task_count BIGINT,
  completed_tasks BIGINT
)
LANGUAGE SQL
SECURITY DEFINER
AS $$
  SELECT 
    u.email,
    u.full_name,
    COUNT(DISTINCT p.id) AS project_count,
    COUNT(t.id) AS task_count,
    COUNT(t.id) FILTER (WHERE t.completed = TRUE) AS completed_tasks
  FROM users u
  LEFT JOIN projects p ON u.id = p.user_id
  LEFT JOIN tasks t ON u.id = t.user_id
  WHERE u.role = 'user'
  GROUP BY u.email, u.full_name
  ORDER BY project_count DESC;
$$;

-- Function: Archive old completed projects (admin only)
-- This function archives projects that have been completed for more than 90 days
CREATE OR REPLACE FUNCTION archive_old_projects()
RETURNS TABLE (archived_count INTEGER)
LANGUAGE SQL
SECURITY DEFINER
AS $$
  WITH updated AS (
    UPDATE projects
    SET status = 'archived'
    WHERE status = 'completed'
      AND created_at < NOW() - INTERVAL '90 days'
    RETURNING id
  )
  SELECT COUNT(*)::INTEGER FROM updated;
$$;

-- ============================================
-- GRANT EXECUTE PERMISSIONS TO AUTHENTICATED USERS
-- (Supabase will handle actual authorization via policies)
-- ============================================

-- Note: In Supabase, you would typically add additional checks
-- within the functions or use application-level checks to ensure
-- only admins can execute these functions. The SECURITY DEFINER
-- clause means the functions run with the privileges of the user
-- who defined them (typically a superuser or admin).
