/*
  # Create CRM Database Schema
  
  Creates the complete database schema for the Tiny CRM application including:
  
  1. New Tables
    - `users` - System users who can access the CRM
      - `id` (bigserial, primary key)
      - `name` (varchar)
      - `email` (varchar, unique)
      - `email_verified_at` (timestamp)
      - `password` (varchar)
      - `remember_token` (varchar)
      - `created_at`, `updated_at` (timestamps)
    
    - `accounts` - Customer/company accounts
      - `id` (bigserial, primary key)
      - `name` (varchar)
      - `phone` (varchar, nullable)
      - `email` (varchar, nullable)
      - `address` (text, nullable)
      - `total_sales` (double precision, default 0)
      - `primary_contact_id` (bigint, nullable, foreign key to contacts)
      - `created_at`, `updated_at` (timestamps)
    
    - `contacts` - Individual contacts associated with accounts
      - `id` (bigserial, primary key)
      - `name` (varchar)
      - `email` (varchar)
      - `phone` (varchar, nullable)
      - `account_id` (bigint, nullable, foreign key to accounts)
      - `created_at`, `updated_at` (timestamps)
    
    - `leads` - Sales leads/opportunities
      - `id` (bigserial, primary key)
      - `title` (varchar)
      - `customer_id` (bigint, nullable, foreign key to accounts)
      - `source` (integer, nullable)
      - `estimated_revenue` (numeric(15,2), nullable)
      - `description` (text, nullable)
      - `status` (integer, default 1)
      - `disqualification_reason` (integer, nullable)
      - `disqualification_description` (text, nullable)
      - `date_disqualified` (timestamp, nullable)
      - `date_qualified` (timestamp, nullable)
      - `created_at`, `updated_at` (timestamps)
    
    - `deals` - Qualified sales deals
      - `id` (bigserial, primary key)
      - `title` (varchar)
      - `customer_id` (bigint, nullable, foreign key to accounts)
      - `lead_id` (bigint, nullable, foreign key to leads)
      - `estimated_revenue` (numeric(15,2), nullable)
      - `actual_revenue` (numeric(15,2), nullable)
      - `description` (text, nullable)
      - `status` (integer, default 1)
      - `date_won` (timestamp, nullable)
      - `date_lost` (timestamp, nullable)
      - `created_at`, `updated_at` (timestamps)
    
    - `products` - Products/services catalog
      - `id` (bigserial, primary key)
      - `product_id` (varchar, unique)
      - `name` (varchar)
      - `type` (integer)
      - `price` (numeric(15,2))
      - `is_available` (boolean, default true)
      - `created_at`, `updated_at` (timestamps)
    
    - `deal_products` - Products associated with deals
      - `id` (bigserial, primary key)
      - `product_id` (bigint, foreign key to products)
      - `deal_id` (bigint, foreign key to deals)
      - `quantity` (integer)
      - `price_per_unit` (numeric(15,2))
      - `total_amount` (numeric(15,2))
      - `created_at`, `updated_at` (timestamps)
  
  2. Indexes
    - leads: (status, customer_id)
    - deals: (status, customer_id, lead_id)
    - products: (product_id, name)
  
  3. Security
    - All tables have RLS enabled
    - Authenticated users can perform all operations
    
  Note: This is a standard Laravel schema without RLS for local development.
  For production, implement proper RLS policies.
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  email_verified_at TIMESTAMP NULL,
  password VARCHAR(255) NOT NULL,
  remember_token VARCHAR(100) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create accounts table
CREATE TABLE IF NOT EXISTS accounts (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(255) NULL,
  email VARCHAR(255) NULL,
  address TEXT NULL,
  total_sales DOUBLE PRECISION NULL DEFAULT 0,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create contacts table
CREATE TABLE IF NOT EXISTS contacts (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(255) NULL,
  account_id BIGINT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL
);

-- Add primary_contact_id to accounts (circular reference)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'accounts' AND column_name = 'primary_contact_id'
  ) THEN
    ALTER TABLE accounts ADD COLUMN primary_contact_id BIGINT NULL;
    ALTER TABLE accounts ADD FOREIGN KEY (primary_contact_id) REFERENCES contacts(id);
  END IF;
END $$;

-- Create leads table
CREATE TABLE IF NOT EXISTS leads (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  customer_id BIGINT NULL,
  source INTEGER NULL,
  estimated_revenue NUMERIC(15,2) NULL,
  description TEXT NULL,
  status INTEGER NOT NULL DEFAULT 1,
  disqualification_reason INTEGER NULL,
  disqualification_description TEXT NULL,
  date_disqualified TIMESTAMP NULL,
  date_qualified TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES accounts(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS leads_status_customer_id_index ON leads(status, customer_id);

-- Create deals table
CREATE TABLE IF NOT EXISTS deals (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  customer_id BIGINT NULL,
  lead_id BIGINT NULL,
  estimated_revenue NUMERIC(15,2) NULL,
  actual_revenue NUMERIC(15,2) NULL,
  description TEXT NULL,
  status INTEGER NOT NULL DEFAULT 1,
  date_won TIMESTAMP NULL,
  date_lost TIMESTAMP NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES accounts(id) ON DELETE SET NULL,
  FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS deals_status_customer_lead_index ON deals(status, customer_id, lead_id);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  product_id VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  type INTEGER NOT NULL,
  price NUMERIC(15,2) NOT NULL,
  is_available BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS products_product_id_name_index ON products(product_id, name);

-- Create deal_products table
CREATE TABLE IF NOT EXISTS deal_products (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL,
  deal_id BIGINT NOT NULL,
  quantity INTEGER NOT NULL,
  price_per_unit NUMERIC(15,2) NOT NULL,
  total_amount NUMERIC(15,2) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (deal_id) REFERENCES deals(id)
);

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE deal_products ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for authenticated users (for Laravel admin panel)
CREATE POLICY "Authenticated users can view all users"
  ON users FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage accounts"
  ON accounts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can manage contacts"
  ON contacts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can manage leads"
  ON leads FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can manage deals"
  ON deals FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can manage products"
  ON products FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can manage deal_products"
  ON deal_products FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
