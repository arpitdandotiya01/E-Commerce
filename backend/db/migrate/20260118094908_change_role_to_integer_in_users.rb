class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[8.1]
  def up
    # Map string values to integers
    execute <<-SQL
      UPDATE users SET role = CASE
        WHEN role = 'user' THEN '0'
        WHEN role = 'admin' THEN '1'
        ELSE '0'
      END
    SQL
    # Change the column type
    change_column :users, :role, :integer, using: 'role::integer'
  end

  def down
    change_column :users, :role, :string
  end
end
