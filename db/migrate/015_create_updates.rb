migration 15, :create_updates do
  up do
    create_table :updates do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :updates
  end
end
