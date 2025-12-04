-- =====================================================
-- Tabel: debts
-- Deskripsi: Menyimpan data hutang pelanggan
-- =====================================================

-- Create table debts
CREATE TABLE IF NOT EXISTS public.debts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    merchant_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_debts_merchant_id ON public.debts(merchant_id);
CREATE INDEX IF NOT EXISTS idx_debts_customer_name ON public.debts(customer_name);
CREATE INDEX IF NOT EXISTS idx_debts_created_at ON public.debts(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own debts" ON public.debts;
DROP POLICY IF EXISTS "Users can insert their own debts" ON public.debts;
DROP POLICY IF EXISTS "Users can update their own debts" ON public.debts;
DROP POLICY IF EXISTS "Users can delete their own debts" ON public.debts;

-- Create RLS Policies
-- Policy: Users can only view their own debts
CREATE POLICY "Users can view their own debts"
    ON public.debts
    FOR SELECT
    USING (auth.uid() = merchant_id);

-- Policy: Users can only insert debts for themselves
CREATE POLICY "Users can insert their own debts"
    ON public.debts
    FOR INSERT
    WITH CHECK (auth.uid() = merchant_id);

-- Policy: Users can only update their own debts
CREATE POLICY "Users can update their own debts"
    ON public.debts
    FOR UPDATE
    USING (auth.uid() = merchant_id)
    WITH CHECK (auth.uid() = merchant_id);

-- Policy: Users can only delete their own debts
CREATE POLICY "Users can delete their own debts"
    ON public.debts
    FOR DELETE
    USING (auth.uid() = merchant_id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_debts_updated_at ON public.debts;

CREATE TRIGGER update_debts_updated_at
    BEFORE UPDATE ON public.debts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.debts TO authenticated;
GRANT ALL ON public.debts TO service_role;

-- Comments
COMMENT ON TABLE public.debts IS 'Tabel untuk menyimpan data hutang pelanggan';
COMMENT ON COLUMN public.debts.id IS 'Primary key UUID';
COMMENT ON COLUMN public.debts.merchant_id IS 'Foreign key ke auth.users - ID merchant/pemilik warung';
COMMENT ON COLUMN public.debts.customer_name IS 'Nama pelanggan yang berhutang';
COMMENT ON COLUMN public.debts.amount IS 'Jumlah hutang dalam rupiah';
COMMENT ON COLUMN public.debts.description IS 'Keterangan opsional tentang hutang';
COMMENT ON COLUMN public.debts.created_at IS 'Timestamp saat hutang dicatat';
COMMENT ON COLUMN public.debts.updated_at IS 'Timestamp saat hutang terakhir diupdate';
