migration 16, :create_appointments do
  up do
    create_table :appointments do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :appointments
  end
end
