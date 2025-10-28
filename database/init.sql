DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_code') THEN
    CREATE TYPE currency_code AS ENUM ('KRW', 'USD');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'billing_cycle') THEN
    CREATE TYPE billing_cycle AS ENUM ('weekly', 'monthly', 'yearly', 'custom');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status') THEN
    CREATE TYPE subscription_status AS ENUM ('active', 'archived');
  END IF;
END $$;

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