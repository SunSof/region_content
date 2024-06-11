admin = User.find_or_initialize_by(email: 'admin@example.com')
admin.password = 'password'
admin.password_confirmation = 'password'
admin.first_name = 'Admin'
admin.last_name = 'User'
admin.middle_name = 'Exaple'
admin.role = 'admin'
admin.save!
