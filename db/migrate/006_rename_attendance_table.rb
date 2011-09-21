# coding: UTF-8

class RenameAttendanceTable < ActiveRecord::Migration
  def self.up
    rename_table(:events_users, :commitments)
    change_column(:commitments, :user_id, :integer)
  end

  def self.down
    change_column(:commitments, :user_id, :string)
    rename_table(:commitments, :events_users)
  end
end
