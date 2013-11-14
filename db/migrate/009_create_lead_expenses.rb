migration 9, :create_lead_expenses do
  up do
    create_table :lead_expenses do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :lead_expenses
  end
end
