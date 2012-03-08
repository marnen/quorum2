class AddCommentToCommitments < ActiveRecord::Migration
  def self.up
    add_column :commitments, :comment, :text
  end

  def self.down
    remove_column :commitments, :comment
  end
end
