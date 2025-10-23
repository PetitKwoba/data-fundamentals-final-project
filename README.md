# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
- [💻 Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Install](#install)
  - [Usage](#usage)
  - [Database Structure](#database-structure)
- [🔐 Security Implementation](#security)
  - [User Roles](#user-roles)
  - [Row Level Security Policies](#row-level-security-policies)
  - [Admin-Only Functions](#admin-only-functions)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [❓ FAQ](#faq)
- [📝 License](#license)

---

# 📖 Data Fundamentals Final Project <a name="about-project"></a>

This is a comprehensive database security project demonstrating the implementation of **Admin Roles & Row Level Security (RLS)** in Supabase (PostgreSQL). The project showcases best practices for managing user access, enforcing least privilege principles, and implementing secure data access patterns in a modern database environment.

**Data Fundamentals Final Project** implements a complete task management system with role-based access control, demonstrating how to properly secure a multi-tenant database using PostgreSQL's Row Level Security features.

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Backend as a Service</summary>
  <ul>
    <li><a href="https://supabase.com/">Supabase</a></li>
  </ul>
</details>

<details>
<summary>Database</summary>
  <ul>
    <li><a href="https://www.postgresql.org/">PostgreSQL 15+</a></li>
  </ul>
</details>

<details>
<summary>Security</summary>
  <ul>
    <li>Row Level Security (RLS)</li>
    <li>Role-Based Access Control (RBAC)</li>
    <li>Supabase Auth</li>
  </ul>
</details>

### Key Features <a name="key-features"></a>

- **🔐 Row Level Security (RLS)**: Comprehensive database-level security ensuring users can only access their own data
- **👥 Role-Based Access Control**: Distinct Admin and User roles with appropriate permissions
- **🛡️ Admin-Only Functions**: Custom PostgreSQL functions with elevated privileges for administrative tasks
- **📊 Multi-Table Schema**: Well-structured database with Users, Projects, and Tasks tables
- **🔒 Least Privilege Principle**: Security implementation following industry best practices

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 💻 Getting Started <a name="getting-started"></a>

This project is designed to be deployed on Supabase. Follow these steps to set up your own instance.

### Prerequisites

To run this project you need:

- A [Supabase](https://supabase.com/) account (free tier available)
- Basic understanding of SQL and PostgreSQL
- A SQL client or the Supabase SQL Editor

### Setup

1. **Create a Supabase Project**
   - Go to [Supabase Dashboard](https://app.supabase.com/)
   - Click "New Project"
   - Choose an organization and fill in project details

2. **Clone this repository** (optional, for reference):
   ```sh
   git clone https://github.com/PetitKwoba/data-fundamentals-final-project.git
   cd data-fundamentals-final-project
   ```

### Install

1. **Execute the Database Schema**
   - Open your Supabase project
   - Navigate to the SQL Editor
   - Copy the entire contents of `schema.sql`
   - Paste and execute the SQL commands

2. **Verify Table Creation**
   - Go to Table Editor in Supabase
   - Confirm you see: `users`, `projects`, and `tasks` tables
   - Check that sample data is populated (5+ rows per table)

3. **Enable Authentication**
   - Navigate to Authentication settings
   - Enable Email/Password or Magic Link authentication
   - Configure email templates as needed

### Usage

#### For Regular Users:
- Sign up through Supabase Auth
- Your user record will be created with `role = 'user'`
- You can view, create, update, and delete your own projects and tasks
- You cannot access other users' data

#### For Administrators:
- Users with `role = 'admin'` in the users table have full access
- Can view and manage all users, projects, and tasks
- Can execute admin-only functions:
  ```sql
  -- Delete any project
  SELECT delete_project('project-uuid-here');
  
  -- Get user statistics
  SELECT * FROM get_user_statistics();
  
  -- Archive old completed projects
  SELECT * FROM archive_old_projects();
  ```

### Database Structure

#### Users Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | TEXT | User email (unique) |
| full_name | TEXT | User's full name |
| role | TEXT | 'admin' or 'user' |
| created_at | TIMESTAMP | Creation timestamp |

#### Projects Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | Foreign key to users |
| name | TEXT | Project name |
| description | TEXT | Project description |
| status | TEXT | 'active', 'completed', or 'archived' |
| created_at | TIMESTAMP | Creation timestamp |

#### Tasks Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| project_id | UUID | Foreign key to projects |
| user_id | UUID | Foreign key to users |
| title | TEXT | Task title |
| description | TEXT | Task description |
| priority | TEXT | 'low', 'medium', or 'high' |
| completed | BOOLEAN | Completion status |
| created_at | TIMESTAMP | Creation timestamp |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🔐 Security Implementation <a name="security"></a>

This project demonstrates comprehensive database security using PostgreSQL Row Level Security (RLS) and role-based access control.

### User Roles

#### Admin Role
- **Full Access**: Can view, insert, update, and delete all data in all tables
- **Administrative Functions**: Can execute admin-only custom functions
- **User Management**: Can manage user accounts and roles

#### User Role  
- **Restricted Access**: Can only view and modify their own data
- **Data Isolation**: Cannot access other users' projects or tasks
- **Role Protection**: Cannot change their own role to admin

### Row Level Security Policies

All tables have RLS enabled with specific policies:

#### Users Table Policies
- ✅ Users can view their own profile
- ✅ Users can update their own profile (except role)
- ✅ Admins can view all users
- ✅ Admins have full access to manage users

#### Projects Table Policies
- ✅ Users can view/create/update/delete their own projects
- ✅ Admins have full access to all projects

#### Tasks Table Policies
- ✅ Users can view/create/update/delete their own tasks
- ✅ Admins have full access to all tasks

### Admin-Only Functions

1. **delete_project(project_id UUID)**
   - Deletes any project regardless of ownership
   - Uses SECURITY DEFINER for elevated privileges

2. **get_user_statistics()**
   - Returns aggregated statistics about users and their activity
   - Useful for admin dashboards and reporting

3. **archive_old_projects()**
   - Automatically archives projects completed over 90 days ago
   - Returns count of archived projects

For detailed security documentation, see [security_notes.md](./security_notes.md).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 👥 Authors <a name="authors"></a>

👤 **PetitKwoba**

- GitHub: [@PetitKwoba](https://github.com/PetitKwoba)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🔭 Future Features <a name="future-features"></a>

Potential enhancements for this project:

- [ ] **Audit Logging**: Add database triggers to track all admin actions for compliance
- [ ] **Two-Factor Authentication**: Implement 2FA requirement for admin accounts
- [ ] **Advanced Reporting**: Create additional statistical functions for project analytics
- [ ] **Data Export**: Add admin functions to export data in various formats
- [ ] **Email Notifications**: Set up automated notifications for project updates

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](../../issues/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## ⭐️ Show your support <a name="support"></a>

If you found this project helpful in understanding database security and Row Level Security implementation, please give it a ⭐️!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGEMENTS -->

## 🙏 Acknowledgments <a name="acknowledgements"></a>

- Thanks to the Supabase team for excellent documentation on RLS
- PostgreSQL community for robust security features
- Data Fundamentals course instructors for project guidance

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FAQ -->

## ❓ FAQ <a name="faq"></a>

**How do I make a user an admin?**

Update the user's role in the users table (requires admin access):
```sql
UPDATE users SET role = 'admin' WHERE email = 'user@example.com';
```

**Why can't I see other users' data?**

This is by design! Row Level Security ensures users can only access their own data. Only admin users can see all data.

**How do I test the security policies?**

Sign in as different users (admin and regular user) and try to access various data. Regular users should only see their own projects and tasks.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## 📝 License <a name="license"></a>

This project is [MIT](./LICENSE) licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
