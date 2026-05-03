class ChangeGoogleUidNullOnUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :google_uid, true
  end
end
