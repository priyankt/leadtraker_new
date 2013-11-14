migration 10, :create_lead_users do
  up do
    create_table :lead_users do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :lead_users
  end
end
