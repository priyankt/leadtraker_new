migration 18, :create_user_invites do
  up do
    create_table :user_invites do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :user_invites
  end
end
