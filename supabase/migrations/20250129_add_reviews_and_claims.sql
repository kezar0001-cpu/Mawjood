-- Add verified and owner_id fields to businesses table
ALTER TABLE businesses
ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES auth.users(id);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_name TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on business_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_reviews_business_id ON reviews(business_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at DESC);

-- Create business_claims table
CREATE TABLE IF NOT EXISTS business_claims (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_email TEXT NOT NULL,
  user_phone TEXT,
  proof_documents TEXT[], -- URLs to uploaded documents
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(business_id, user_id) -- Prevent duplicate claims from same user
);

-- Create index on business_id and status for faster lookups
CREATE INDEX IF NOT EXISTS idx_claims_business_id ON business_claims(business_id);
CREATE INDEX IF NOT EXISTS idx_claims_status ON business_claims(status);
CREATE INDEX IF NOT EXISTS idx_claims_user_id ON business_claims(user_id);

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
CREATE TRIGGER update_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_business_claims_updated_at ON business_claims;
CREATE TRIGGER update_business_claims_updated_at
  BEFORE UPDATE ON business_claims
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to update business rating from reviews
CREATE OR REPLACE FUNCTION update_business_rating()
RETURNS TRIGGER AS $$
BEGIN
  -- Update the business rating to be the average of all reviews
  UPDATE businesses
  SET rating = (
    SELECT ROUND(AVG(rating)::numeric, 1)
    FROM reviews
    WHERE business_id = COALESCE(NEW.business_id, OLD.business_id)
  )
  WHERE id = COALESCE(NEW.business_id, OLD.business_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create trigger to auto-update business rating when reviews change
DROP TRIGGER IF EXISTS update_business_rating_on_review_change ON reviews;
CREATE TRIGGER update_business_rating_on_review_change
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_business_rating();

-- Enable Row Level Security (RLS)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_claims ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reviews table

-- Anyone can read reviews
CREATE POLICY "Reviews are viewable by everyone"
  ON reviews FOR SELECT
  USING (true);

-- Authenticated users can insert reviews
CREATE POLICY "Authenticated users can insert reviews"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Users can update their own reviews
CREATE POLICY "Users can update their own reviews"
  ON reviews FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete their own reviews"
  ON reviews FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for business_claims table

-- Users can view their own claims
CREATE POLICY "Users can view their own claims"
  ON business_claims FOR SELECT
  USING (auth.uid() = user_id);

-- Authenticated users can create claims
CREATE POLICY "Authenticated users can create claims"
  ON business_claims FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own pending claims
CREATE POLICY "Users can update their own pending claims"
  ON business_claims FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');

-- Note: Admin policies would need to be added separately with a service role
-- or by adding an is_admin column to users table
