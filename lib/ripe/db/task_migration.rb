module Ripe
  module DB
    class TaskMigration < ActiveRecord::Migration
      def self.up
        create_table :tasks do |t|
          t.belongs_to :worker
          t.string     :sample
          t.string     :block
        end
      end

      def self.down
        drop_table :tasks
      end
    end
  end
end
