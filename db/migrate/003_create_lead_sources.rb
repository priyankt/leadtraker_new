migration 3, :create_lead_sources do
  up do
    create_table :lead_sources do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :lead_sources
  end
end
