class CreateBase < ActiveRecord::Migration[5.1]
    def change
        create_table :users do |t|
            t.string :username
            t.string :email
            t.string :password_digest
        end

        create_table :tasks do |t|
            t.string :content
            t.boolean :done
            t.belongs_to :user, index: true
        end

    end
end
