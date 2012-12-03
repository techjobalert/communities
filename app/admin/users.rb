ActiveAdmin.register User do
  index do
    column :email
    column :admin
    column :full_name
    column :role
  end
end
