CREATE DATABASE IF NOT EXISTS user_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE user_management_db;

-- SQLAlchemy will create these tables automatically when the application starts.
-- The definitions below are included so you can inspect/create the schema manually.

CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email),
    KEY ix_users_id (id),
    KEY ix_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_profiles (
    id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    phone VARCHAR(30) NULL,
    address VARCHAR(500) NULL,
    date_of_birth DATE NULL,
    bio TEXT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_user_profiles_user_id (user_id),
    KEY ix_user_profiles_id (id),
    KEY ix_user_profiles_user_id (user_id),
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;
