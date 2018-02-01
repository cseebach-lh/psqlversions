require 'open3'
require 'thor'
require 'psqlversions'

module Psqlversions
  # The main class for the command-line interface
  class CLI < Thor
    desc 'list', 'list all local databases'
    def list
      list_dbs.each { |db| puts db }
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

    private

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
