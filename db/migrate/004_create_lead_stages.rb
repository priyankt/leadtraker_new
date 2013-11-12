migration 4, :create_lead_stages do
  up do
    create_table :lead_stages do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :lead_stages
  end
end
