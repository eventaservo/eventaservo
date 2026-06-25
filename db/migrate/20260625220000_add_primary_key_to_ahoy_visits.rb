# frozen_string_literal: true

# Ensures the ahoy_visits table has a primary key.
#
# The production database was found to be missing the primary key constraint on
# the +id+ column of +ahoy_visits+, causing +ActiveRecord::UnknownPrimaryKey+
# errors (Sentry EVENTA-SERVO-1Y0). The +id+ column and its sequence exist — only
# the +PRIMARY KEY+ constraint is missing, likely due to a legacy schema issue.
#
# This migration idempotently adds the constraint if absent.
class AddPrimaryKeyToAhoyVisits < ActiveRecord::Migration[8.1]
  def up
    # Use ntuples to avoid PG boolean type ambiguity (can be "t"/"f" string
    # or Ruby true/false depending on driver configuration — comparing with
    # == "t" fails when the driver returns true/false).
    existing = execute(<<~SQL)
      SELECT 1
      FROM pg_constraint
      WHERE conrelid = 'ahoy_visits'::regclass
        AND contype = 'p'
      LIMIT 1
    SQL

    if existing.ntuples == 0
      # The id column exists and is NOT NULL; only the constraint is missing.
      # Adding PRIMARY KEY is safe — it validates existing data.
      execute("ALTER TABLE ahoy_visits ADD PRIMARY KEY (id);")
    end
  end

  def down
    # Not reversible: removing a primary key would break referential integrity
    # and there's no scenario where we'd want to remove it.
    raise ActiveRecord::IrreversibleMigration
  end
end
