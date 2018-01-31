require 'thor'
require 'psqlversions'
require 'open3'

module Psqlversions
  class CLI < Thor
    desc 'list', 'list all local databases'
    def list
      list_dbs.each {|db| puts db}
    end

    desc 'copy {from} {to}', 'create a copy of a local database'
    def copy(from, to)
      _stdout, stderr, status = Open3.capture3('createdb', "-T#{from}", to)
      if status != 0 then
        puts "error when copying: #{stderr}"
      end
    end

    desc 'checkpoint {checkpointable} tag', 'create a checkpoint for a local db'
    def checkpoint(db_to_checkpoint, checkpoint_base_name)
      next_checkpoint = build_checkpoint_name(
        checkpoint_base_name,
        last_checkpoint(checkpoint_base_name) + 1
      )
      copy(db_to_checkpoint, next_checkpoint)
    end

    private

    def last_checkpoint(checkpoint_base)
      last = 0
      list_dbs.each do |db_name|
        starts_with_base = db_name.start_with? checkpoint_base
        ends_with_number = db_name.sub(checkpoint_base, '') =~ /-\d+/
        if starts_with_base && ends_with_number
          suffix = db_name.sub checkpoint_base, ''
          last = [suffix.gsub(/[^\d]/, '').to_i, last].max
        end
      end
      last
    end

    def build_checkpoint_name(checkpoint_base_name, next_checkpoint)
      "#{checkpoint_base_name}-#{next_checkpoint.to_s.rjust 3, '0'}"
    end

    def list_dbs
      stdout, _status = Open3.capture2('psql', '--list')

      dbs = []
      stdout.each_line.drop(3).each do |line|
        db, _user, _encoding, _collate, _ctype, _privileges = line.split('|')
        db = db.strip
        unless db.empty? || db =~ /\(.*\)/
          dbs << db
        end
      end
      dbs
    end
  end
end
