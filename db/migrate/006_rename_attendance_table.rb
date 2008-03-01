class RenameAttendanceTable < ActiveRecord::Migration
  def self.up
    rename_table(:events_users, :commitments)
  end

  def self.down
    rename_table(:commitments, :events_users)
  end
end
