require 'ripl' # REPL
require 'hirb' # Pretty output for +ActiveRecord+ objects
require 'thor'

require_relative '../ripe'

include Ripe
include Ripe::DB
include Ripe::DSL

module Ripe
  class CLI < Thor
    desc 'init', 'Initialize ripe repository'
    def init
      puts "Initialized ripe repository in #{Dir.pwd}"
      repo = Repo.new
      repo.attach_or_create
    end

    desc 'console', 'Enter ripe console'
    def console
      repo = Repo.new
      repo.attach

      unless repo.has_repository?
        abort "Cannot launch console: ripe repo not initialized"
      end

      # Do not send arguments to the REPL
      ARGV.clear

      Ripl.config[:prompt] = proc do
        # This is the only place I could think of placing +Hirb#enable+.
        Hirb.enable unless Hirb::View.enabled?
        'ripe> '
      end

      # Launch the REPL session in the context of +WorkerController+.
      Ripl.start :binding => repo.controller.instance_eval { binding }
    end

    desc 'prepare SAMPLES', 'Prepare jobs from template workflow'
    option :workflow, :aliases => '-w', :type => :string, :required => true,
      :desc => 'Workflow to be applied'
    option :options, :aliases => '-o', :type => :string, :required => false,
      :desc => 'Options', :default => ''
    def prepare(*samples)
      repo = Repo.new
      repo.attach

      unless repo.has_repository?
        abort "Cannot launch console: ripe repo not initialized"
      end

      abort "No samples specified." if (samples.length == 0)

      params = options[:options].split(/,/).map do |pair|
        key, value = pair.split(/=/)
        { key.to_sym => value }
      end
      params = params.inject(&:merge) || {}

      repo.controller.prepare(options[:workflow], samples, params)
    end

    desc 'version', 'Retrieve ripe version'
    def version
      puts "ripe version #{Ripe::VERSION}"
    end
  end
end
