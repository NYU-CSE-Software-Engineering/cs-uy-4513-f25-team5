class RenamePasswordToPasswordDigestInUsers < ActiveRecord::Migration[7.1]
  def up
    rename_column :users, :password, :password_digest

    # Rehash any existing plaintext passwords to BCrypt
    User.reset_column_information
    User.find_each do |user|
      next if user.password_digest.blank?

      # Check if password_digest looks like a BCrypt hash (starts with $2a$, $2b$, etc.)
      # If not, it's likely plaintext and needs to be rehashed
      unless user.password_digest.start_with?('$2')
        plaintext_password = user.password_digest
        user.password = plaintext_password
        user.save!(validate: false)
      end
    end
  end

  def down
    rename_column :users, :password_digest, :password
  end
end
