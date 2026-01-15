class RenameProjectOwnerToCreator < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :owner_id, :creator_id
  end
end
