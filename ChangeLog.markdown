# 2.1.0

  This release handles some corner cases with cloning git repositories, making svn2git applicable to wider environments.
  
  * Added --no-minimize-url option for migrating specific subprojects from an SVN repo containing several projects (thanks fmjrey).
  * Added --username option for migrating password-protected repositories (thanks svenax).
  * Added --revision option for specifying the revision to start importing from (thanks svenax).

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
