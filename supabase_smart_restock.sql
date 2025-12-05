-- =====================================================
-- SMART RESTOCK FEATURE - Database Schema
-- Products & Restocking Management
-- =====================================================

-- ========== TABLE: products ==========
-- Menyimpan master data produk/barang

CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    merchant_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    buy_price NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (buy_price >= 0),
    sell_price NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (sell_price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    category TEXT,
    unit TEXT DEFAULT 'pcs',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_merchant_id ON public.products(merchant_id);
CREATE INDEX IF NOT EXISTS idx_products_name ON public.products(name);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view their own products" ON public.products;
DROP POLICY IF EXISTS "Users can insert their own products" ON public.products;
DROP POLICY IF EXISTS "Users can update their own products" ON public.products;
DROP POLICY IF EXISTS "Users can delete their own products" ON public.products;

CREATE POLICY "Users can view their own products"
    ON public.products FOR SELECT
    USING (auth.uid() = merchant_id);

CREATE POLICY "Users can insert their own products"
    ON public.products FOR INSERT
    WITH CHECK (auth.uid() = merchant_id);

CREATE POLICY "Users can update their own products"
    ON public.products FOR UPDATE
    USING (auth.uid() = merchant_id)
    WITH CHECK (auth.uid() = merchant_id);

CREATE POLICY "Users can delete their own products"
    ON public.products FOR DELETE
    USING (auth.uid() = merchant_id);

-- ========== TABLE: restocks ==========
-- Menyimpan history restocking/pembelian

CREATE TABLE IF NOT EXISTS public.restocks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    merchant_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    buy_price NUMERIC(15, 2) NOT NULL CHECK (buy_price >= 0),
    total_cost NUMERIC(15, 2) NOT NULL CHECK (total_cost >= 0),
    supplier_name TEXT,
    invoice_number TEXT,
    restock_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_restocks_merchant_id ON public.restocks(merchant_id);
CREATE INDEX IF NOT EXISTS idx_restocks_product_id ON public.restocks(product_id);
CREATE INDEX IF NOT EXISTS idx_restocks_date ON public.restocks(restock_date DESC);
CREATE INDEX IF NOT EXISTS idx_restocks_supplier ON public.restocks(supplier_name);

-- Enable RLS
ALTER TABLE public.restocks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view their own restocks" ON public.restocks;
DROP POLICY IF EXISTS "Users can insert their own restocks" ON public.restocks;
DROP POLICY IF EXISTS "Users can update their own restocks" ON public.restocks;
DROP POLICY IF EXISTS "Users can delete their own restocks" ON public.restocks;

CREATE POLICY "Users can view their own restocks"
    ON public.restocks FOR SELECT
    USING (auth.uid() = merchant_id);

CREATE POLICY "Users can insert their own restocks"
    ON public.restocks FOR INSERT
    WITH CHECK (auth.uid() = merchant_id);

CREATE POLICY "Users can update their own restocks"
    ON public.restocks FOR UPDATE
    USING (auth.uid() = merchant_id)
    WITH CHECK (auth.uid() = merchant_id);

CREATE POLICY "Users can delete their own restocks"
    ON public.restocks FOR DELETE
    USING (auth.uid() = merchant_id);

-- ========== TRIGGERS ==========

-- Update updated_at on products
CREATE OR REPLACE FUNCTION update_products_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_products_updated_at_trigger ON public.products;

CREATE TRIGGER update_products_updated_at_trigger
    BEFORE UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION update_products_updated_at();

-- ========== GRANTS ==========

GRANT ALL ON public.products TO authenticated;
GRANT ALL ON public.products TO service_role;
GRANT ALL ON public.restocks TO authenticated;
GRANT ALL ON public.restocks TO service_role;

-- ========== COMMENTS ==========

COMMENT ON TABLE public.products IS 'Master data produk/barang warung';
COMMENT ON COLUMN public.products.id IS 'Primary key UUID';
COMMENT ON COLUMN public.products.merchant_id IS 'Foreign key ke auth.users';
COMMENT ON COLUMN public.products.name IS 'Nama produk';
COMMENT ON COLUMN public.products.buy_price IS 'Harga modal/beli (per unit)';
COMMENT ON COLUMN public.products.sell_price IS 'Harga jual ke customer (per unit)';
COMMENT ON COLUMN public.products.stock IS 'Jumlah stok tersedia';
COMMENT ON COLUMN public.products.category IS 'Kategori produk (optional)';
COMMENT ON COLUMN public.products.unit IS 'Satuan: pcs, kg, liter, dll';

COMMENT ON TABLE public.restocks IS 'History transaksi restocking/pembelian';
COMMENT ON COLUMN public.restocks.id IS 'Primary key UUID';
COMMENT ON COLUMN public.restocks.merchant_id IS 'Foreign key ke auth.users';
COMMENT ON COLUMN public.restocks.product_id IS 'Foreign key ke products';
COMMENT ON COLUMN public.restocks.product_name IS 'Nama produk (backup jika product dihapus)';
COMMENT ON COLUMN public.restocks.quantity IS 'Jumlah yang dibeli';
COMMENT ON COLUMN public.restocks.buy_price IS 'Harga beli per unit saat transaksi';
COMMENT ON COLUMN public.restocks.total_cost IS 'Total biaya = quantity × buy_price';
COMMENT ON COLUMN public.restocks.supplier_name IS 'Nama supplier/toko grosir';
COMMENT ON COLUMN public.restocks.invoice_number IS 'Nomor nota/invoice';
COMMENT ON COLUMN public.restocks.restock_date IS 'Tanggal pembelian';

-- ========== SAMPLE DATA (Optional for Testing) ==========

-- Uncomment untuk testing
/*
INSERT INTO public.products (merchant_id, name, buy_price, sell_price, stock, category, unit) VALUES
    ((SELECT id FROM auth.users LIMIT 1), 'Indomie Goreng', 2500, 3000, 100, 'Makanan', 'pcs'),
    ((SELECT id FROM auth.users LIMIT 1), 'Aqua 600ml', 3000, 4000, 50, 'Minuman', 'pcs'),
    ((SELECT id FROM auth.users LIMIT 1), 'Minyak Sania 2L', 28000, 32000, 20, 'Sembako', 'btl'),
    ((SELECT id FROM auth.users LIMIT 1), 'Gula Pasir 1kg', 12000, 14000, 30, 'Sembako', 'kg');
*/
