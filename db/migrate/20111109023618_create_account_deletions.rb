class CreateAccountDeletions < ActiveRecord::Migration
  def self.up
    create_table :account_deletions do |t|
      t.string :Evergreen_handle
      t.integer :person_id
    end
  end

  def self.down
    drop_table :account_deletions
  end
end
