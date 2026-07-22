class AddConfirmedAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :confirmed_at, :datetime

    # Existing accounts predate the confirmation requirement — treat them as
    # already confirmed rather than locking everyone out on deploy.
    execute "UPDATE users SET confirmed_at = created_at"
  end

  def down
    remove_column :users, :confirmed_at
  end
end
