# Security Notes - Data Fundamentals Final Project

## Overview
This document outlines the security implementation for the Data Fundamentals Final Project, which uses Supabase (PostgreSQL) with Row Level Security (RLS) to manage user access and enforce least privilege principles.

---

## Authentication & Authorization

### User Roles
We implement two distinct user roles in the system:

1. **Admin Role** (`role = 'admin'`)
   - Full access to all tables (SELECT, INSERT, UPDATE, DELETE)
   - Can view and manage all users' data
   - Can execute admin-only custom functions
   - Intended for system administrators and data managers

2. **User Role** (`role = 'user'`)
   - Limited access based on data ownership
   - Can only view, insert, update, and delete their own data
   - Cannot access other users' data
   - Cannot modify their own role assignment
   - Intended for regular application users

---

## Row Level Security (RLS) Implementation

### What is RLS?
Row Level Security is a PostgreSQL feature that allows you to control which rows users can access in a table. When RLS is enabled on a table, all queries are filtered through policies that determine access.

### RLS Status
RLS is **enabled** on all three tables:
- ✅ `users` table
- ✅ `projects` table  
- ✅ `tasks` table

### How It Works
1. When a user queries a table, PostgreSQL checks all applicable policies
2. If ANY policy returns `TRUE`, the user can access that row
3. If ALL policies return `FALSE` or no policies match, access is denied
4. Different policies can apply for different operations (SELECT, INSERT, UPDATE, DELETE)

---

## Security Policies by Table

### Users Table Policies

| Policy Name | Operation | Who | Description |
|------------|-----------|-----|-------------|
| Users can view their own profile | SELECT | Regular Users | Users can only see their own user record |
| Admins can view all users | SELECT | Admins | Admins can see all user records |
| Users can update their own profile | UPDATE | Regular Users | Users can update their profile but cannot change their role |
| Admins have full access to users | ALL | Admins | Admins can perform any operation on user records |

**Security Consideration**: The update policy specifically prevents users from elevating their own privileges by checking that the role hasn't changed.

### Projects Table Policies

| Policy Name | Operation | Who | Description |
|------------|-----------|-----|-------------|
| Users can view their own projects | SELECT | Regular Users | Users can only view projects they created |
| Users can insert their own projects | INSERT | Regular Users | Users can create new projects associated with themselves |
| Users can update their own projects | UPDATE | Regular Users | Users can modify their own projects |
| Users can delete their own projects | DELETE | Regular Users | Users can delete their own projects |
| Admins have full access to projects | ALL | Admins | Admins can perform any operation on any project |

**Security Consideration**: All user operations are scoped to `auth.uid() = user_id`, ensuring users can only interact with their own data.

### Tasks Table Policies

| Policy Name | Operation | Who | Description |
|------------|-----------|-----|-------------|
| Users can view their own tasks | SELECT | Regular Users | Users can only view tasks they created |
| Users can insert their own tasks | INSERT | Regular Users | Users can create new tasks associated with themselves |
| Users can update their own tasks | UPDATE | Regular Users | Users can modify their own tasks |
| Users can delete their own tasks | DELETE | Regular Users | Users can delete their own tasks |
| Admins have full access to tasks | ALL | Admins | Admins can perform any operation on any task |

**Security Consideration**: Similar to projects, all operations are scoped to the authenticated user's ID.

---

## Admin-Only Custom Functions

### 1. delete_project(project_id UUID)
**Purpose**: Allows admins to delete any project regardless of ownership

**Security Features**:
- Uses `SECURITY DEFINER` clause to run with elevated privileges
- Should be called only by admin users (enforced at application level)
- Useful for content moderation and data management

**Usage Example**:
```sql
SELECT delete_project('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
```

### 2. get_user_statistics()
**Purpose**: Returns aggregated statistics about users and their projects/tasks

**Security Features**:
- Uses `SECURITY DEFINER` to access data across all users
- Only returns statistics for regular users (excludes admins)
- Provides useful insights for admin dashboards

**Returns**:
- User email and name
- Count of projects per user
- Count of tasks per user
- Count of completed tasks per user

**Usage Example**:
```sql
SELECT * FROM get_user_statistics();
```

### 3. archive_old_projects()
**Purpose**: Automatically archives projects that have been completed for more than 90 days

**Security Features**:
- Uses `SECURITY DEFINER` for batch operations
- Only affects completed projects
- Returns count of archived projects

**Usage Example**:
```sql
SELECT * FROM archive_old_projects();
```

---

## Least Privilege Principle

Our implementation follows the **principle of least privilege**:

1. **Default Deny**: With RLS enabled, users have NO access by default
2. **Explicit Grants**: Access is explicitly granted through policies
3. **Ownership-Based Access**: Regular users can only access their own data
4. **Role Separation**: Clear distinction between admin and user capabilities
5. **Immutable Roles**: Users cannot self-promote to admin status

---

## Security Best Practices Implemented

### ✅ Row Level Security Enabled
All tables have RLS enabled, ensuring no data can be accessed without explicit policy approval.

### ✅ Authentication Required
All policies use `auth.uid()` which requires users to be authenticated via Supabase Auth.

### ✅ Role-Based Access Control (RBAC)
Different policies apply based on user role, providing flexibility and security.

### ✅ Ownership Validation
Regular users can only access data where `user_id = auth.uid()`.

### ✅ Secure Functions
Admin functions use `SECURITY DEFINER` but should be wrapped in application-level checks.

### ✅ Cascade Deletions
Foreign key constraints with `ON DELETE CASCADE` ensure data integrity.

### ✅ Input Validation
CHECK constraints on tables ensure data validity (e.g., role must be 'admin' or 'user').

---

## Supabase Auth Integration

### Setup Requirements
1. Enable **Supabase Auth** in your project
2. Configure authentication provider (email/password or magic link)
3. Ensure `auth.uid()` is properly populated on authentication
4. Map authenticated users to the `users` table

### Authentication Flow
1. User signs up/signs in through Supabase Auth
2. Supabase generates a JWT token with user ID
3. User ID becomes available as `auth.uid()` in database queries
4. RLS policies use `auth.uid()` to enforce access control

---

## Testing Security

### Test Scenarios

1. **Test Regular User Access**
   - Log in as a regular user
   - Verify they can only see their own projects and tasks
   - Attempt to access another user's data (should fail)

2. **Test Admin Access**
   - Log in as an admin user
   - Verify they can see all users' data
   - Test admin functions execution

3. **Test Privilege Escalation Prevention**
   - Log in as a regular user
   - Attempt to change own role to 'admin' (should fail)

4. **Test Data Isolation**
   - Create data as User A
   - Log in as User B
   - Verify User B cannot access User A's data

---

## Potential Improvements

1. **Audit Logging**: Add triggers to log admin actions for compliance
2. **Time-Based Access**: Implement policies that expire after certain times
3. **IP Restrictions**: Add IP-based access control for sensitive operations
4. **Two-Factor Authentication**: Require 2FA for admin accounts
5. **Rate Limiting**: Implement rate limits on sensitive operations
6. **Data Encryption**: Add column-level encryption for sensitive fields
7. **Backup Policies**: Ensure regular backups with RLS enforcement

---

## Troubleshooting

### Common Issues

**Issue**: "permission denied for table users"
- **Cause**: RLS is enabled but no policy matches
- **Solution**: Verify user is authenticated and policies are correctly defined

**Issue**: Users can see other users' data
- **Cause**: RLS not enabled or policy too permissive
- **Solution**: Check `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` was executed

**Issue**: Admins cannot access data
- **Cause**: Admin policy not matching correctly
- **Solution**: Verify admin role is set correctly in users table and auth.uid() matches

---

## References

- [PostgreSQL Row Level Security Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [OWASP Access Control Guidelines](https://owasp.org/www-project-top-ten/)

---

## Conclusion

This security implementation provides a robust foundation for access control in the Data Fundamentals project. By leveraging PostgreSQL's Row Level Security and Supabase's authentication system, we ensure that:

- Data is protected at the database level
- Users can only access their own data
- Admins have necessary privileges for management
- The principle of least privilege is enforced
- Security policies are transparent and maintainable
