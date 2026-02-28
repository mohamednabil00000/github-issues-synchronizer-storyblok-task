# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.bigint :user_id, null: false, index: { unique: true }
      t.string :login
      t.string :avatar_url
      t.string :url
      t.string :type

      t.timestamps
    end
  end
end
