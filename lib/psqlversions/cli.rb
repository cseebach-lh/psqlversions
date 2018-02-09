require 'open3'
require 'thor'
require 'daybreak'
require 'terminal-table'
require 'psqlversions'

module Psqlversions
  # The main class for the command-line interface
  class CLI < Thor
    desc 'list', 'list all local databases'
    def list
      with_preferences_db do |db|
        rows = list_dbs.each.map do |local_db_name|
          [local_db_name, db[local_db_name] == 'protected' ? 'protected' : '']
        end

        puts Terminal::Table.new(headings: %w[Database Protected?], rows: rows)
      end
    end

    desc 'drop {local_db}', 'drop a local database (following protection flags)'
    def drop(local_db_name)
      with_preferences_db do |db|
        if db[local_db_name] == 'protected'
          puts "#{local_db_name} is protected and I won't drop it."
        else
          _stdout, stderr, status = Open3.capture3('dropdb', local_db_name)
          puts "error when dropping: #{stderr}" if status != 0
        end
      end
    end

    desc 'copy {from} {to}', 'create a copy of a local database'
    def copy(from, to)
      _stdout, stderr, status = Open3.capture3('createdb', "-T#{from}", to)
      puts "error when copying: #{stderr}" if status != 0
    end

    desc 'checkpoint {local_db} {tag}', 'create a checkpoint for a local db'
    def checkpoint(db, tag)
      next_checkpoint = build_checkpoint_name(tag, last_checkpoint(tag) + 1)
      copy(db, next_checkpoint)
    end

    desc 'protect {local_db}', 'prevent psqlversions from dropping a local db'
    def protect(local_db_name)
      with_preferences_db do |db|
        db.set! local_db_name, 'protected'
      end
    end

    desc 'unprotect {local_db}', 'allow psqlversions to drop a local db'
    def unprotect(local_db_name)
      with_preferences_db do |db|
        db.set! local_db_name, 'unprotected'
      end
    end

    private

    def with_preferences_db
      db = Daybreak::DB.new "#{Dir.home}/.psqlversions.db"
      yield(db)
      db.close
    end

    def last_checkpoint(checkpoint_base)
      points = list_dbs.select { |db| db.start_with? checkpoint_base }
                       .map { |db| db.sub checkpoint_base, '' }
                       .select { |suffix| suffix =~ /-\d+/ }
                       .map { |suffix| suffix[1..-1].to_i }

      (points + [0]).max
    end

    def build_checkpoint_name(checkpoint_base_name, next_checkpoint)
      "#{checkpoint_base_name}-#{next_checkpoint.to_s.rjust 3, '0'}"
    end

    def list_dbs
      stdout, status = Open3.capture2('psql', '--list')
      return [] if status != 0

      stdout.each_line.drop(3)
            .map { |line| line.split('|')[0].strip }
            .reject { |db| db.empty? || db =~ /\(.*\)/ }
    end
  end
end
