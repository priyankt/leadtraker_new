migration 6, :create_phone_numbers do
  up do
    create_table :phone_numbers do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :phone_numbers
  end
end
