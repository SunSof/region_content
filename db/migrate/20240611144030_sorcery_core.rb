class SorceryCore < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false, index: true
      t.string :middle_name, null: false
      t.references :region, foreign_key: true
      t.string :role, default: "user"
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false
    end
  end
end
