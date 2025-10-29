CREATE TABLE IF NOT EXISTS subscription (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) UNIQUE NOT NULL,
  cost DECIMAL(10, 2) NOT NULL CHECK (cost > 0),
  currency currency_code NOT NULL,
  billing_cycle billing_cycle NOT NULL,
  cycle_value INTEGER,
  next_billing_date DATE NOT NULL,
  first_billing_date DATE NOT NULL,
  status subscription_status NOT NULL DEFAULT 'active',
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_cycle_value_for_custom
  CHECK (
    (billing_cycle = 'custom' AND cycle_value IS NOT NULL) OR
    (billing_cycle != 'custom' AND cycle_value IS NULL)
  )
);

COMMENT ON COLUMN subscription.cycle_value IS 'Required only if the billing_cycle value is custom.'
