migration 5, :create_contacts do
  up do
    create_table :contacts do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :contacts
  end
end
