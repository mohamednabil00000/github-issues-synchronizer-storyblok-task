# frozen_string_literal: true

class Change < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
    ALTER TABLE issues
      ALTER COLUMN id TYPE bigint
      USING id::bigint;
    SQL
  end
  def down
    execute <<~SQL
    ALTER TABLE issues
      ALTER COLUMN id TYPE integer
      USING id::integer;
    SQL
  end
end
