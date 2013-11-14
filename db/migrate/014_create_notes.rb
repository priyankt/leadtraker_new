migration 14, :create_notes do
  up do
    create_table :notes do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :notes
  end
end
