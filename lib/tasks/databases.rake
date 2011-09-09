# coding: UTF-8

namespace :db do
  namespace :test do
    desc "Empty the test database"
    task :purge => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs["test"]["adapter"]
        when "mysql"
          ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.recreate_database(abcs["test"]["database"])
        when "postgresql"
          ENV['PGHOST']     = abcs["test"]["host"] if abcs["test"]["host"]
          ENV['PGPORT']     = abcs["test"]["port"].to_s if abcs["test"]["port"]
          ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
          enc_option = "-E #{abcs["test"]["encoding"]}" if abcs["test"]["encoding"]

          ActiveRecord::Base.clear_active_connections!
          `dropdb -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}`
          `createdb #{enc_option} -U "#{abcs["test"]["username"]}" -T "#{abcs["test"]["template"]}" #{abcs["test"]["database"]}`
        when "sqlite","sqlite3"
          dbfile = abcs["test"]["database"] || abcs["test"]["dbfile"]
          File.delete(dbfile) if File.exist?(dbfile)
        when "sqlserver"
          dropfkscript = "#{abcs["test"]["host"]}.#{abcs["test"]["database"]}.DP1".gsub(/\\/,'-')
          `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{dropfkscript}`
          `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
        when "oci", "oracle"
          ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        when "firebird"
          ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.recreate_database!
        else
          raise "Task not supported by '#{abcs["test"]["adapter"]}'"
      end
    end
  end
end