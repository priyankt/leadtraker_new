migration 2, :create_lead_types do
  up do
    create_table :lead_types do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :lead_types
  end
end
