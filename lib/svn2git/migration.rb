require 'optparse'
require 'pp'
require 'timeout'
require 'thread'

module Svn2Git
  DEFAULT_AUTHORS_FILE = "~/.svn2git/authors"

  class Migration

    attr_reader :dir

    def initialize(args)
      @options = parse(args)
      if @options[:rebase]
         show_help_message('Too many arguments') if args.size > 0
         verify_working_tree_is_clean
      elsif @options[:rebasebranch]
         show_help_message('Too many arguments') if args.size > 0
         verify_working_tree_is_clean
      else
         show_help_message('Missing SVN_URL parameter') if args.empty?
         show_help_message('Too many arguments') if args.size > 1
         @url = args.first.gsub(' ', "\\ ")
      end
    end

    def run!
      if @options[:rebase]
        get_branches
      elsif @options[:rebasebranch]
        get_rebasebranch
      else
        clone!
      end
      fix_branches
      fix_tags
      fix_trunk
      optimize_repos
    end

    def parse(args)
      # Set up reasonable defaults for options.
      options = {}
      options[:verbose] = false
      options[:metadata] = false
      options[:nominimizeurl] = false
      options[:rootistrunk] = false
      options[:trunk] = 'trunk'
      options[:branches] = []
      options[:tags] = []
      options[:exclude] = []
      options[:revision] = nil
      options[:username] = nil
      options[:rebasebranch] = false

      if File.exists?(File.expand_path(DEFAULT_AUTHORS_FILE))
        options[:authors] = DEFAULT_AUTHORS_FILE
      end


      # Parse the command-line arguments.
      @opts = OptionParser.new do |opts|
        opts.banner = 'Usage: svn2git SVN_URL [options]'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--rebase', 'Instead of cloning a new project, rebase an existing one against SVN') do
          options[:rebase] = true
        end

        opts.on('--username NAME', 'Username for transports that needs it (http(s), svn)') do |username|
          options[:username] = username
        end

        opts.on('--trunk TRUNK_PATH', 'Subpath to trunk from repository URL (default: trunk)') do |trunk|
          options[:trunk] = trunk
        end

        opts.on('--branches BRANCHES_PATH', 'Subpath to branches from repository URL (default: branches); can be used multiple times') do |branches|
          options[:branches] << branches
        end

        opts.on('--tags TAGS_PATH', 'Subpath to tags from repository URL (default: tags); can be used multiple times') do |tags|
          options[:tags] << tags
        end

        opts.on('--rootistrunk', 'Use this if the root level of the repo is equivalent to the trunk and there are no tags or branches') do
          options[:rootistrunk] = true
          options[:trunk] = nil
          options[:branches] = nil
          options[:tags] = nil
        end

        opts.on('--notrunk', 'Do not import anything from trunk') do
          options[:trunk] = nil
        end

        opts.on('--nobranches', 'Do not try to import any branches') do
          options[:branches] = nil
        end

        opts.on('--notags', 'Do not try to import any tags') do
          options[:tags] = nil
        end

        opts.on('--no-minimize-url', 'Accept URLs as-is without attempting to connect to a higher level directory') do
          options[:nominimizeurl] = true
        end

        opts.on('--revision START_REV[:END_REV]', 'Start importing from SVN revision START_REV; optionally end at END_REV') do |revision|
          options[:revision] = revision
        end

        opts.on('-m', '--metadata', 'Include metadata in git logs (git-svn-id)') do
          options[:metadata] = true
        end

        opts.on('--authors AUTHORS_FILE', "Path to file containing svn-to-git authors mapping (default: #{DEFAULT_AUTHORS_FILE})") do |authors|
          options[:authors] = authors
        end

        opts.on('--exclude REGEX', 'Specify a Perl regular expression to filter paths when fetching; can be used multiple times') do |regex|
          options[:exclude] << regex
        end

        opts.on('-v', '--verbose', 'Be verbose in logging -- useful for debugging issues') do
          options[:verbose] = true
        end

        opts.on('--rebasebranch REBASEBRANCH', 'Rebase specified branch.') do |rebasebranch|
          options[:rebasebranch] = rebasebranch
        end

        opts.separator ""

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      @opts.parse! args
      options
    end

    def self.escape_quotes(str)
      str.gsub(/'|"/) { |c| "\\#{c}" }
    end

    def escape_quotes(str)
      Svn2Git::Migration.escape_quotes(str)
    end

    def self.checkout_svn_branch(branch)
      "git checkout -b \"#{branch}\" \"remotes/svn/#{branch}\""
    end

  private

    def clone!
      trunk = @options[:trunk]
      branches = @options[:branches]
      tags = @options[:tags]
      metadata = @options[:metadata]
      nominimizeurl = @options[:nominimizeurl]
      rootistrunk = @options[:rootistrunk]
      authors = @options[:authors]
      exclude = @options[:exclude]
      revision = @options[:revision]
      username = @options[:username]

      if rootistrunk
        # Non-standard repository layout.  The repository root is effectively 'trunk.'
        cmd = "git svn init --prefix=svn/ "
        cmd += "--username='#{username}' " unless username.nil?
        cmd += "--no-metadata " unless metadata
        if nominimizeurl
          cmd += "--no-minimize-url "
        end
        cmd += "--trunk='#{@url}'"
        run_command(cmd, true, true)

      else
        cmd = "git svn init --prefix=svn/ "

        # Add each component to the command that was passed as an argument.
        cmd += "--username='#{username}' " unless username.nil?
        cmd += "--no-metadata " unless metadata
        if nominimizeurl
          cmd += "--no-minimize-url "
        end
        cmd += "--trunk='#{trunk}' " unless trunk.nil?
        unless tags.nil?
          # Fill default tags here so that they can be filtered later
          tags = ['tags'] if tags.empty?
          # Process default or user-supplied tags
          tags.each do |tag|
            cmd += "--tags='#{tag}' "
          end
        end
        unless branches.nil?
          # Fill default branches here so that they can be filtered later
          branches = ['branches'] if branches.empty?
          # Process default or user-supplied branches
          branches.each do |branch|
            cmd += "--branches='#{branch}' "
          end
        end

        cmd += @url

        run_command(cmd, true, true)
      end

      run_command("#{git_config_command} svn.authorsfile #{authors}") unless authors.nil?

      cmd = "git svn fetch "
      unless revision.nil?
        range = revision.split(":")
        range[1] = "HEAD" unless range[1]
        cmd += "-r #{range[0]}:#{range[1]} "
      end
      unless exclude.empty?
        # Add exclude paths to the command line; some versions of git support
        # this for fetch only, later also for init.
        regex = []
        unless rootistrunk
          regex << "#{trunk}[/]" unless trunk.nil?
          tags.each{|tag| regex << "#{tag}[/][^/]+[/]"} unless tags.nil? or tags.empty?
          branches.each{|branch| regex << "#{branch}[/][^/]+[/]"} unless branches.nil? or branches.empty?
        end
        regex = '^(?:' + regex.join('|') + ')(?:' + exclude.join('|') + ')'
        cmd += "--ignore-paths='#{regex}' "
      end
      run_command(cmd, true, true)

      get_branches
    end

    def get_branches
      # Get the list of local and remote branches, taking care to ignore console color codes and ignoring the
      # '*' character used to indicate the currently selected branch.
      @local = run_command("git branch -l --no-color").split(/\n/).collect{ |b| b.gsub(/\*/,'').strip }
      @remote = run_command("git branch -r --no-color").split(/\n/).collect{ |b| b.gsub(/\*/,'').strip }

      # Tags are remote branches that start with "tags/".
      @tags = @remote.find_all { |b| b.strip =~ %r{^svn\/tags\/} }

    end

    def get_rebasebranch
	  get_branches 
	  @local = @local.find_all{|l| l == @options[:rebasebranch]}
	  @remote = @remote.find_all{|r| r.include? @options[:rebasebranch]}

      if @local.count > 1 
        pp "To many matching branches found (#{@local})."
        exit 1
      elsif @local.count == 0
	    pp "No local branch named \"#{@options[:rebasebranch]}\" found."
        exit 1
      end

      if @remote.count > 2 # 1 if remote is not pushed, 2 if its pushed to remote
        pp "To many matching remotes found (#{@remotes})"
        exit 1
      elsif @remote.count == 0
	    pp "No remote branch named \"#{@options[:rebasebranch]}\" found."
        exit 1
      end
	  pp "Local branches \"#{@local}\" found"
	  pp "Remote branches \"#{@remote}\" found"

      @tags = [] # We only rebase the specified branch

    end

    def fix_tags
      current = {}
      current['user.name']  = run_command("#{git_config_command} --get user.name", false)
      current['user.email'] = run_command("#{git_config_command} --get user.email", false)

      @tags.each do |tag|
        tag = tag.strip
        id      = tag.gsub(%r{^svn\/tags\/}, '').strip
        subject = run_command("git log -1 --pretty=format:'%s' \"#{escape_quotes(tag)}\"").chomp("'").reverse.chomp("'").reverse
        date    = run_command("git log -1 --pretty=format:'%ci' \"#{escape_quotes(tag)}\"").chomp("'").reverse.chomp("'").reverse
        author  = run_command("git log -1 --pretty=format:'%an' \"#{escape_quotes(tag)}\"").chomp("'").reverse.chomp("'").reverse
        email   = run_command("git log -1 --pretty=format:'%ae' \"#{escape_quotes(tag)}\"").chomp("'").reverse.chomp("'").reverse
        run_command("#{git_config_command} user.name \"#{escape_quotes(author)}\"")
        run_command("#{git_config_command} user.email \"#{escape_quotes(email)}\"")

        original_git_committer_date = ENV['GIT_COMMITTER_DATE']
        ENV['GIT_COMMITTER_DATE'] = escape_quotes(date)
        run_command("git tag -a -m \"#{escape_quotes(subject)}\" \"#{escape_quotes(id)}\" \"#{escape_quotes(tag)}\"")
        ENV['GIT_COMMITTER_DATE'] = original_git_committer_date

        run_command("git branch -d -r \"#{escape_quotes(tag)}\"")
      end

    ensure
      # We only change the git config values if there are @tags available.  So it stands to reason we should revert them only in that case.
      unless @tags.empty?
        current.each_pair do |name, value|
          # If a line was read, then there was a config value so restore it.
          # Otherwise unset the value because originally there was none.
          if value.strip != ''
            run_command("#{git_config_command} #{name} \"#{value.strip}\"")
          else
            run_command("#{git_config_command} --unset #{name}")
          end
        end
      end
    end

    def fix_branches
      svn_branches = @remote - @tags
      svn_branches.delete_if { |b| b.strip !~ %r{^svn\/} }

      if @options[:rebase]
         run_command("git svn fetch", true, true)
      end

      svn_branches.each do |branch|
        branch = branch.gsub(/^svn\//,'').strip
        if @options[:rebase] && (@local.include?(branch) || branch == 'trunk')
           lbranch = branch
           lbranch = 'master' if branch == 'trunk'
           run_command("git checkout -f \"#{lbranch}\"")
           run_command("git rebase \"remotes/svn/#{branch}\"")
           next
        end

        next if branch == 'trunk' || @local.include?(branch)

        if @cannot_setup_tracking_information
          run_command(Svn2Git::Migration.checkout_svn_branch(branch))
        else
          status = run_command("git branch --track \"#{branch}\" \"remotes/svn/#{branch}\"", false)

          # As of git 1.8.3.2, tracking information cannot be set up for remote SVN branches:
          # http://git.661346.n2.nabble.com/git-svn-Use-prefix-by-default-td7594288.html#a7597159
          #
          # Older versions of git can do it and it should be safe as long as remotes aren't pushed.
          # Our --rebase option obviates the need for read-only tracked remotes, however.  So, we'll
          # deprecate the old option, informing those relying on the old behavior that they should
          # use the newer --rebase otion.
          if status =~ /Cannot setup tracking information/m
            @cannot_setup_tracking_information = true
            run_command(Svn2Git::Migration.checkout_svn_branch(branch))
          else
            unless @legacy_svn_branch_tracking_message_displayed
              warn '*' * 68
              warn "svn2git warning: Tracking remote SVN branches is deprecated."
              warn "In a future release local branches will be created without tracking."
              warn "If you must resync your branches, run: svn2git --rebase"
              warn '*' * 68
            end

            @legacy_svn_branch_tracking_message_displayed = true

            run_command("git checkout \"#{branch}\"")
          end
        end
      end
    end

    def fix_trunk
      trunk = @remote.find { |b| b.strip == 'trunk' }
      if trunk && ! @options[:rebase]
        run_command("git checkout svn/trunk")
        run_command("git branch -D master")
        run_command("git checkout -f -b master")
      else
        run_command("git checkout -f master")
      end
    end

    def optimize_repos
      run_command("git gc")
    end

    def run_command(cmd, exit_on_error=true, printout_output=false)
      if ( ( cmd =~ /^git[ ]svn/ ) and ( ENV.key?('SVN2GIT_PASSWORD') ) )
        password = ENV['SVN2GIT_PASSWORD']
        cmd = "echo #{password} | " + cmd
      end
      
      _run_command( cmd, exit_on_error, printout_output )
    end

    def _run_command(cmd, exit_on_error=true, printout_output=false)
      log "Running command: #{cmd}\n"

      ret = ''
      @stdin_queue ||= Queue.new

      # We need to fetch input from the user to pass through to the underlying sub-process.  We'll constantly listen
      # for input and place any received values on a queue for consumption by a pass-through thread that will forward
      # the contents to the underlying sub-process's stdin pipe.
      @stdin_thread ||= Thread.new do
        loop { @stdin_queue << $stdin.gets.chomp }
      end

      # Open4 forks, which JRuby doesn't support.  But JRuby added a popen4-compatible method on the IO class,
      # so we can use that instead.
      IO.popen("2>&1 #{cmd}") do |output|
        threads = []

        threads << Thread.new(output) do |output|
          # git-svn seems to do all of its prompting for user input via STDERR.  When it prompts for input, it will
          # not terminate the line with a newline character, so we can't split the input up by newline.  It will,
          # however, use a space to separate the user input from the prompt.  So we split on word boundaries here
          # while draining STDERR.
          output.each(' ') do |word|
            ret << word

            if printout_output
              $stdout.print word
            else
              log word
            end
          end
        end

        # Simple pass-through thread to take anything the user types via STDIN and passes it through to the
        # sub-process's stdin pipe.
        Thread.new do
          loop do
            user_reply = @stdin_queue.pop

            # nil is our cue to stop looping (pun intended).
            break if user_reply.nil?
           
            stdin.puts user_reply
            stdin.close
          end
        end

        threads.each(&:join)

        # Push nil to the stdin_queue to gracefully exit the STDIN pass-through thread.
        @stdin_queue << nil
      end

      if exit_on_error && $?.exitstatus != 0
        $stderr.puts "command failed:\n#{cmd}"
        exit -1
      end

      ret
    end

    def log(msg)
      print msg if @options[:verbose]
    end

    def show_help_message(msg)
      puts "Error starting script: #{msg}\n\n"
      puts @opts.help
      exit
    end

    def verify_working_tree_is_clean
      status = run_command('git status --porcelain --untracked-files=no')
      unless status.strip == ''
        puts 'You have local pending changes.  The working tree must be clean in order to continue.'
        exit -1
      end
    end

    def git_config_command
      if @git_config_command.nil?
        status = run_command('git config --local --get user.name', false)

        @git_config_command = if status =~ /unknown option/m
                                'git config'
                              else
                                'git config --local'
                              end
      end

      @git_config_command
    end

  end
end

