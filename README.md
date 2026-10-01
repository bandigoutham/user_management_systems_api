# User Management System API

A beginner-friendly backend project using:

- Python
- FastAPI
- MySQL
- SQLAlchemy ORM
- JWT authentication
- Pydantic
- Swagger UI

## 1. Project structure

```text
user_management_system_api/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── dependencies.py
│   ├── models.py
│   ├── schemas.py
│   ├── security.py
│   └── routers/
│       ├── __init__.py
│       ├── auth.py
│       └── users.py
├── .env.example
├── .gitignore
├── database.sql
├── requirements.txt
└── README.md
```

## 2. Prerequisites

Install:

1. Python 3.10 or newer
2. MySQL 8.x (or a compatible MySQL server)
3. pip

Check:

```bash
python --version
mysql --version
```

On Windows, you can also use `py --version`.

## 3. Create the MySQL database

Start MySQL and create the database.

### Option A - MySQL command line

```bash
mysql -u root -p
```

Then:

```sql
CREATE DATABASE user_management_db;
EXIT;
```

### Option B - Use the included SQL file

```bash
mysql -u root -p < database.sql
```

The application also creates the required tables automatically when it starts.

## 4. Create a virtual environment

From the project folder:

### Windows

```bash
python -m venv .venv
.venv\Scripts\activate
```

If PowerShell blocks activation, use Command Prompt or run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.venv\Scripts\Activate.ps1
```

### macOS/Linux

```bash
python3 -m venv .venv
source .venv/bin/activate
```

## 5. Install dependencies

```bash
pip install -r requirements.txt
```

## 6. Configure MySQL and JWT

Copy `.env.example` to `.env`.

### Windows CMD

```cmd
copy .env.example .env
```

### Windows PowerShell / macOS / Linux

```bash
cp .env.example .env
```

Open `.env` and change the MySQL password.

Example:

```env
DATABASE_URL=mysql+pymysql://root:MyPassword@localhost:3306/user_management_db
JWT_SECRET_KEY=put-a-long-random-secret-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

If your MySQL username is not `root`, change it too.

If your MySQL server uses another port, change `3306`.

## 7. Run the server

With the virtual environment activated:

```bash
uvicorn app.main:app --reload
```

You should see a message similar to:

```text
Uvicorn running on http://127.0.0.1:8000
```

Open Swagger UI:

```text
http://127.0.0.1:8000/docs
```

ReDoc is also available at:

```text
http://127.0.0.1:8000/redoc
```

## 8. Test all APIs in Swagger UI

### Step 1 - Register

Open:

`POST /auth/register`

Click **Try it out** and use:

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "Password123"
}
```

Expected:

- HTTP `201 Created`
- JSON containing `access_token`
- `token_type` = `bearer`

Copy the access token.

> This project returns a token immediately after registration so you can test protected endpoints without doing a second login. You should still test `/auth/login` separately.

### Step 2 - Login

Open:

`POST /auth/login`

Use:

```json
{
  "email": "john@example.com",
  "password": "Password123"
}
```

Expected:

- HTTP `200 OK`
- JWT access token

Copy the token.

### Step 3 - Authorize Swagger

Click the **Authorize** button near the top right of Swagger UI.

Enter:

```text
Bearer YOUR_ACCESS_TOKEN
```

or, depending on Swagger's bearer input behavior, paste only:

```text
YOUR_ACCESS_TOKEN
```

Click **Authorize**, then **Close**.

Swagger will now send the token to protected endpoints.

### Step 4 - Create profile

Open:

`POST /users/profile`

Example:

```json
{
  "phone": "9876543210",
  "address": "Hyderabad, Telangana",
  "date_of_birth": "1998-05-15",
  "bio": "Backend developer"
}
```

Expected: `201 Created`.

### Step 5 - Get your own profile

Open:

`GET /users/me`

Expected: `200 OK` with your user and profile data.

### Step 6 - List users

Open:

`GET /users`

Expected: `200 OK` with registered users.

This endpoint requires authentication.

### Step 7 - Update your profile

Open:

`PUT /users/profile`

Example:

```json
{
  "phone": "9999999999",
  "address": "Hyderabad",
  "date_of_birth": "1998-05-15",
  "bio": "Updated bio"
}
```

Expected: `200 OK`.

Only the authenticated user's profile is updated.

### Step 8 - Delete your profile

Open:

`DELETE /users/profile`

Expected:

- HTTP `204 No Content`

The user account remains in the `users` table; only the profile row is deleted.

### Step 9 - Verify missing profile

Call:

`GET /users/me`

Expected:

```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "...",
  "profile": null
}
```

Then try `PUT /users/profile` or `DELETE /users/profile`.

Expected:

- HTTP `404 Not Found`
- Appropriate profile-not-found message

## 9. Error/validation tests

### Duplicate registration

Register the same email again.

Expected:

```text
409 Conflict
```

### Invalid login

Use a wrong password.

Expected:

```text
401 Unauthorized
```

### Missing token

Call:

`GET /users/me`

without clicking Swagger's Authorize button.

Expected:

```text
401 Unauthorized
```

### Invalid date

For example:

```json
{
  "date_of_birth": "not-a-date"
}
```

Expected:

```text
422 Unprocessable Entity
```

### Password validation

A password shorter than 8 characters is rejected by Pydantic.

Expected:

```text
422 Unprocessable Entity
```

## 10. Verify data in MySQL

Login:

```bash
mysql -u root -p
```

Then:

```sql
USE user_management_db;

SELECT id, name, email, created_at FROM users;

SELECT
    id,
    user_id,
    phone,
    address,
    date_of_birth,
    bio
FROM user_profiles;
```

Passwords are not stored as plain text. The `password_hash` column contains a bcrypt hash.

To inspect it:

```sql
SELECT id, email, password_hash FROM users;
```

## 11. API summary

| Method | Endpoint | Auth | Purpose |
|---|---|---|---|
| POST | `/auth/register` | No | Register user |
| POST | `/auth/login` | No | Login and receive JWT |
| POST | `/users/profile` | Yes | Create own profile |
| GET | `/users/me` | Yes | Get own profile |
| GET | `/users` | Yes | List registered users |
| PUT | `/users/profile` | Yes | Update own profile |
| DELETE | `/users/profile` | Yes | Delete own profile |

## 12. HTTP status codes used

- `200 OK` - successful read/update/login
- `201 Created` - successful registration/profile creation
- `204 No Content` - successful profile deletion
- `401 Unauthorized` - missing/invalid/expired JWT or invalid login
- `404 Not Found` - profile does not exist
- `409 Conflict` - duplicate email or profile already exists
- `422 Unprocessable Entity` - invalid request data

## 13. Security notes

This is an educational beginner project.

For production, additionally consider:

- HTTPS
- a strong secret stored outside source control
- database migrations with Alembic
- refresh tokens and token revocation
- rate limiting
- stronger password policies
- restricted CORS
- database least-privilege accounts
- centralized logging
- automated tests
- environment-specific configuration

Never commit `.env` or real JWT secrets to Git.

## 14. Quick start

After MySQL is running and `.env` is configured:

```bash
python -m venv .venv
```

Activate the environment, then:

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Open:

```text
http://127.0.0.1:8000/docs
```

## 15. Notes about screenshots

This package is source code and documentation; it does not include fabricated Swagger screenshots. Run the application against your local MySQL database, perform the tests in `/docs`, and capture screenshots from your actual results for submission.
