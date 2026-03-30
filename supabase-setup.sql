-- TASHA BEVERAGES SUPABASE SQL SETUP
-- Run in Supabase SQL Editor (dashboard.supabase.co → SQL)

-- Enable RLS later for production
-- Tables + sample data for admin/products/announcements

-- 1. ADMINS TABLE (hr/gm/sm roles)
CREATE TABLE IF NOT EXISTS admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL, -- bcrypt hash from backend
  role TEXT CHECK (role IN ('hr', 'gm', 'sm')) NOT NULL DEFAULT 'sm',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  volume TEXT,
  description TEXT,
  image_url TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ANNOUNCEMENTS TABLE
CREATE TABLE IF NOT EXISTS announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT CHECK (type IN ('announcement', 'news')) NOT NULL DEFAULT 'announcement',
  author TEXT,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SAMPLE DATA

-- Admin users (passwords bcrypt hashed: 'password123')
INSERT INTO admins (username, email, password_hash, role) VALUES
('hr_admin', 'hr@tashibeverages.bt', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr'),
('gm_admin', 'gm@tashibeverages.bt', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gm'),
('sm_admin', 'sm@tashibeverages.bt', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'sm');

-- Products
INSERT INTO products (name, category, price, volume, description, image_url, status) VALUES
('Coca-Cola', 'soft-drinks', 25.00, '330ml', 'Original cola taste', 'image/cola.png', 'active'),
('Fanta Orange', 'soft-drinks', 22.00, '330ml', 'Refreshing orange', 'image/F2.jpg', 'active'),
('Sprite', 'soft-drinks', 22.00, '330ml', 'Lemon-lime refreshment', 'image/sprite-logo.webp', 'active'),
('Charge Energy', 'energy-drinks', 60.00, '250ml', 'Energy boost', 'image/charge-bottel.png', 'active'),
('Kinley Water', 'packaged-water', 5.00, '1L', 'Pure mineral water', 'image/kinley.jpg', 'active'),
('Soda Water', 'packaged-water', 25.00, '1L', 'Carbonated mineral', 'image/kinley.jpg', 'active');

-- Announcements
INSERT INTO announcements (title, content, type, author, category) VALUES
('New Product Launch', 'Introducing Sparkling Water line!', 'announcement', 'Marketing', 'Products'),
('Sustainability Award', 'Tashi Beverages wins green award!', 'news', 'HR', 'Awards'),
('Market Expansion', 'New distribution regions opening', 'news', 'GM', 'Business');

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_announcements_type ON announcements(type);
CREATE INDEX IF NOT EXISTS idx_admins_role ON admins(role);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- View for dashboard
CREATE VIEW dashboard_stats AS
SELECT 
  (SELECT COUNT(*) FROM admins WHERE is_active = true) as active_admins,
  (SELECT COUNT(*) FROM products WHERE status = 'active') as active_products,
  (SELECT COUNT(*) FROM announcements WHERE created_at > NOW() - INTERVAL '30 days') as recent_announcements;

-- Test query
SELECT * FROM dashboard_stats;

-- SUCCESS! Backend APIs will now populate these tables
-- Login: username=sm_admin password=password123 → admin-dashboard.html

