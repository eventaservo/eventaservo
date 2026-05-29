# frozen_string_literal: true

# Creates an IMMUTABLE wrapper around unaccent() so it can be used in
# functional indexes. PostgreSQL requires index expressions to be IMMUTABLE,
# but unaccent() is only STABLE. The wrapper is safe because unaccent's
# output is deterministic for a fixed search_path.
class CreateImmutableUnaccentFunction < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION immutable_unaccent(text)
        RETURNS text
        LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
        AS $$ SELECT public.unaccent($1) $$;
    SQL
  end

  def down
    execute "DROP FUNCTION IF EXISTS immutable_unaccent(text);"
  end
end
