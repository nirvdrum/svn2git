# 2.4.1 - 2021-12-17

  Since 'git-svn' does not support '--password' anymore, this release modifies the mechanism to supply a password when needed.

  * Removed support for '--password' option (jesteves; PR merge pending).
  * Added support for detecting and using the value of the environment variable 'SVN2GIT_PASSWORD' when `svn git` is invoked (jesteves; PR merge pending).
# 2.4.0 - 2016-10-30

  This release introduces the ability to supply a password for SVN repositories that can't authenticate by other means.
  It also adds the ability to specify the '--branches' and '--tags' arguments multiple times to better support those with
  more complicated SVN repository layouts.

  * Added support for the '--password' option for authentication (thanks edpbx).
  * Added the ability to specify the '--branches' and '--tags' arguments multiple times (thanks pdf).
  * Fixed a problem with processing of the '--exclude' argument (improper quoting internally) (thanks pdf).

# 2.3.2 - 2014-06-08

  This is a bugfix release. It fixes issues running with Windows using MRI ruby and fixes a problem with Ruby 1.8.7.
  
  * Removed open4 dependency. svn2git no longer has any runtime dependencies and things work well on Windows again.
  * Fixed an issue with Ruby 1.8.7, which doesn't implicitly require the 'thread' library meaning classes that library weren't in scope.


# 2.3.1 - 2014-05-14

  This is a critical bugfix release if you're running git >= 1.8.3.2.  In the days of svn2git 1.x we supported syncing
  local branches with upstream by tracking the branch as we set them up.  This allowed one to checkout the branch and
  issue a "git pull" to fetch the changes.  git-svn ceased allowing this in 1.8.3.2, which broke svn2git with that
  version of git and all subsequent versions.  The rationale seemed to be in order to prevent pushing changes from
  git-svn back up and breaking the remote link, but this was never something svn2git supported anyway.
  
  Acknowledging the new reality of upstream, the old behavior is retained but deprecated for users of git < 1.8.3.2.
  We'll be removing the establishment of remote tracking SVN branches in the 2.5.0 release.  If you wish to sync back
  with upstream, run `svn2git --rebase`.  If you're on git >= 1.8.3.2 your only option for resynchronizing is to
  use `svn2git --rebase`.
  
  Many thanks to ktdreyer for modernizing the test suite and Daniel Ruf (DanielRuf) for pushing on the git compatibility
  issue.
  
  * Fixed creating local branches for remote SVN branches in git >= 1.8.3.2.
  * Fixed verbose logging of sub-process STDERR stream.
  * Added MIT license metadata to gemspec.
  * Switched to minitest to get tests working on Ruby 1.9+ with minitest 5+ installed.
  

# 2.3.0 - 2014-05-14

  This release passes STDIN through to the underlying git-svn process, allowing users to interact with the
  git-svn prompt.  Principally, it will allow users to choose what to do when prompted about unverified
  SSL certificates.

  * Pass STDIN through to the underlying git-svn process so users can respond to prompts.

# 2.2.5 - 2014-03-09

  This is a bugfix release. It improves handling of quotes in SVN commit messages.


  * Fixed an with single quote escaping (thanks aucl).
  * Escape double quotes (e.g., if they appear in a commit message) before passing to the shell (thanks aucl).

# 2.2.4 - 2014-03-08

  There was a permissions problem with some of the files packed in 2.2.3.  This was caught immediately after the gem
  was pushed, so it was yanked as it simply wouldn't work for anyone.  2.2.4 contains everything 2.2.3 did, but with
  proper packaging.

# 2.2.3 - 2014-03-08

  This is a bugfix release. First change done by FeeJai.

  * Fixed an issue with password protected svn-repositories. The prompt to enter the password is now displayed.
  * Fixed an issue with server certificates. If the certificate is untrusted, the prompt to confirm or deny the certificate is now shown.
  * Fixed an issue with using the `--local` flag for `git config` in git versions < 1.7.4.


# 2.2.2 - 2012-10-07

  This is an overdue bugfix release.  No new features were added, but several long-standing bugs fixed by the community
  have been merged.  Many thanks to Edson de Lima (edsonlima), Rudger (Rud5G), Ben Wolfe (bwolfe), CyberTech, PowerKiKi, and Philipp Riemer (ruderphilipp) for the pull requests.

  * Fixed an issue working with repositories that contained a space in the name (thanks edsonlima).
  * Fixed an issue working with tags that contain a hyphen (thanks Rud5G).
  * Fixed an issue with fixing tags during a rebase (thanks PowerKiKi).
  * Double-quote git-svn commands working with tags to avoid issues with special strings (thanks CyberTech).
  * Improved the documentation example of fetching the author list for an SVN repository (thanks bwolfe).
  * Set the git committer date for tags in a more cross-platform manner (thanks CyberTech).
  * Improved documentation formatting (thanks ruderphilipp).

# 2.2.1 - 2012-02-25

  This is a critical bugfix release if your repository has tags.  Thanks to David Zülke (dzuelke) for the patches making up this release.

  * Added the ability to specify an end revision for migration (thanks dzuelke).
  * Fixed an issue with initial conversion if the repo had tags (thanks dzuelke).

# 2.2.0 - 2012-01-25

  Thanks to Craig Hobbs (craigahobbs) and Simon Chiang (thinkerbot) for the patches making up this release.
  It rounds out our tag support by handling tags with special characters and preserving original tag author info.

  * Fixed an issue with not quoting tag names (thanks craigahobbs and thinkerbot)
  * Fixed an issue whereby the person running the svn2git conversion became the author of every tag (i.e., we lost the
  original tag committer info) (thanks thinkerbot)

# 2.1.2 - 2011-12-28

  * Fixed a regression in improperly quoting branch names (thanks ziangsong).

# 2.1.1 - 2011-12-27

  * Fixed SVN branch detection (thanks thinkerbot).
  * Stop processing when a git subprocess fails (thanks thinkerbot).
  * Fixed an issue with SVN branches containing shell special characters (thanks sleicht).

# 2.1.0 - 2011-04-03

  Thanks to Francois Rey (fmjrey), Sven Axelsson (svenax), and Julian Taylor (juliantaylor) for submitting all the patches
  that comprise this release.  svn2git now works with a much wider array SVN repositories because of their efforts.
  
  * Added --no-minimize-url option for migrating specific subprojects from an SVN repo containing several projects (thanks fmjrey).
  * Added --username option for migrating password-protected repositories (thanks svenax).
  * Added --revision option for specifying the revision to start importing from (thanks svenax).
  * Fixed compatibility with older versions of git (thanks juliantaylor).

# 2.0.0 - 2010-05-29

  This release adds the oft requested incremental SVN update support.  If you run svn2git with the `--rebase` option on an existing
  repository that you've converted with svn2git, it will fetch new branches & tags from SVN and update existing ones.  There are
  two important things to note:

  * This will not work on already converted repositories because the tracking information isn't set up correctly.  You could do that
  yourself, but it's probably a lot easier to do the conversion over.
  * svn2git now maintains remote tracking information.  If this is a problem for you because you don't want any links to the SVN server
  you can either stick with a 1.x release of svn2git or simply clone the repo created with svn2git, which will lose the tracking information.

  A great deal of thanks to Nathaniel McCallum (npmccallum) for coming up with an elegant solution and then providing the patch for this release.

# 1.3.3 - 2010-03-31

  Thanks to Jeff Ramnani (jramnani) for finding a problem with with the --excludes tag and providing a patch.

  * Fix error when using '--exclude' option.

# 1.3.2 - 2010-03-12

  Thanks to Rajit Singh (rajit) for finding a problem with quoting in tag comments that were causing issues with svn2git's internal
  quoting and providing a patch.

  * Deal cleanly with any single quotes found in tag comments so that the 'git tag' commands run correctly.

# 1.3.1 - 2009-06-09

  Thanks to KUBO Atsuhiro (iteman) for finding a problem with the tagging process and providing a patch.
  
  * Fixed a problem with creating actual git tags when the SVN tags path was named anything other than 'tags.'

# 1.3.0 - 2009-06-09

  Many thanks to Malte S. Stretz (mss) for the patches making up most of this release.

  * Fixed a problem where tags didn't get the original date and time.
  * New switch --exclude which can be used to specify a PCRE pattern to exclude paths from the import.
  * New switches --no{trunk,branches,tags} to skip import of those.
  * Improved docs.

# 1.2.4 - 2009-05-04

  * No changes.  I ran the jeweler command twice inadvertently.  Tearing down the release would be more harmful than helpful.

# 1.2.3 - 2009-05-04

  * Yanked out the code referencing the gem by name.  This shouldn't be necessary at all.

# 1.2.2 - 2009-05-04

  * Updated the reference gem in the binary to use this one and not the one on RubyForge.

# 1.2.1 - 2009-04-19

  * Fixed a problem with the svn2git binary not loading command-line args properly.

# 1.2.0 - 2009-04-17

  * Reworked command-line options so they work similarly to every other app in the world.
  * Better error messaging when no URL provided.
  * Improved docs.

# 1.1.1 - 2009-04-15
  
  * Started using Jeweler for gem management.
  * Fixed issue with not loading up RubyGems appropriately.

# 1.1.0 - 2009-01-02

  * First release since nirvdrum fork.
  
  * Fixed issues with handling of tags and branches.
  * Added better logging of output from git-svn.
  * Wrap external command processing to capture failures.

# 1.0.0 - 2008-07-19

  * Forked version from jcoglan.
