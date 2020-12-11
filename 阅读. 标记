svn2git
=======

_svn2git_ is a tiny utility for migrating projects from Subversion to Git
while keeping the trunk, branches and tags where they should be. It uses
git-svn to clone an svn repository and does some clean-up to make sure
branches and tags are imported in a meaningful way, and that the code checked
into master ends up being what's currently in your svn trunk rather than
whichever svn branch your last commit was in.

Examples
--------

Say I have this code in svn:

    trunk
      ...
    branches
      1.x
      2.x
    tags
      1.0.0
      1.0.1
      1.0.2
      1.1.0
      2.0.0

git-svn will go through the commit history to build a new git repo. It will
import all branches and tags as remote svn branches, whereas what you really
want is git-native local branches and git tag objects. So after importing this
project I'll get:

    $ git branch
    * master
    $ git branch -a
    * master
      1.x
      2.x
      tags/1.0.0
      tags/1.0.1
      tags/1.0.2
      tags/1.1.0
      tags/2.0.0
      trunk
    $ git tag -l
    [ empty ]

After svn2git is done with your project, you'll get this instead:

    $ git branch
    * master
      1.x
      2.x
    $ git tag -l
      1.0.0
      1.0.1
      1.0.2
      1.1.0
      2.0.0

Finally, it makes sure the HEAD of master is the same as the current trunk of
the svn repo.

Installation
------------

Make sure you have git, git-svn, and ruby installed.  svn2git is a ruby wrapper around git's native SVN support through git-svn.  It is possible to have git installed without git-svn installed, so please do verify that you can run `$ git svn` successfully.  For a Debian-based system, the installation of the prerequisites would look like:

    $ sudo apt-get install git-core git-svn ruby

Once you have the necessary software on your system, you can install svn2git through rubygems, which will add the `svn2git` command to your PATH.    

    $ sudo gem install svn2git


Usage
-----

### Initial Conversion ###

There are several ways you can create a git repo from an existing
svn repo. The differentiating factor is the svn repo layout. Below is an
enumerated listing of the varying supported layouts and the proper way to
create a git repo from a svn repo in the specified layout.

1. The svn repo is in the standard layout of (trunk, branches, tags) at the
root level of the repo.

        $ svn2git http://svn.example.com/path/to/repo

2. The svn repo is NOT in standard layout and has only a trunk and tags at the
root level of the repo.

        $ svn2git http://svn.example.com/path/to/repo --trunk dev --tags rel --nobranches

3. The svn repo is NOT in standard layout and has only a trunk at the root
level of the repo.

        $ svn2git http://svn.example.com/path/to/repo --trunk trunk --nobranches --notags

4. The svn repo is NOT in standard layout and has no trunk, branches, or tags
at the root level of the repo. Instead the root level of the repo is
equivalent to the trunk and there are no tags or branches.

        $ svn2git http://svn.example.com/path/to/repo --rootistrunk

5. The svn repo is in the standard layout but you want to exclude the massive
doc directory and the backup files you once accidently added.

        $ svn2git http://svn.example.com/path/to/repo --exclude doc --exclude '.*~$'

6. The svn repo actually tracks several projects and you only want to migrate
one of them.

        $ svn2git http://svn.example.com/path/to/repo/nested_project --no-minimize-url

7. The svn repo is password protected.

        $ svn2git http://svn.example.com/path/to/repo --username <<user_with_perms>>

If this doesn't cooperate and you need to specify a password on the command-line:

        $ svn2git http://svn.example.com/path/to/repo --username <<user_with_perms>> --password <<password>>

8. You need to migrate starting at a specific svn revision number.

        $ svn2git http://svn.example.com/path/to/repo --revision <<starting_revision_number>>

9. You need to migrate starting at a specific svn revision number, ending at a specific revision number.

        $ svn2git http://svn.example.com/path/to/repo --revision <<starting_revision_number>>:<<ending_revision_number>>

10. Include metadata (git-svn-id) in git logs.

        $ svn2git http://svn.example.com/path/to/repo --metadata

The above will create a git repository in the current directory with the git
version of the svn repository. Hence, you need to make a directory that you
want your new git repo to exist in, change into it and then run one of the
above commands. Note that in the above cases the trunk, branches, tags options
are simply folder names relative to the provided repo path. For example if you
specified trunk=foo branches=bar and tags=foobar it would be referencing
http://svn.example.com/path/to/repo/foo as your trunk, and so on. However, in
case 4 it references the root of the repo as trunk.

### Repository Updates ###

As of svn2git 2.0 there is a new feature to pull in the latest changes from SVN into your
git repository created with svn2git.  This is a one way sync, but allows you to use svn2git
as a mirroring tool for your SVN repositories.

The command to call is:

        $ cd <EXISTING_REPO> && svn2git --rebase

Authors
-------

To convert all your svn authors to git format, create a file somewhere on your
system with the list of conversions to make, one per line, for example:

    jcoglan = James Coglan <jcoglan@never-you-mind.com>
    stnick = Santa Claus <nicholas@lapland.com>

Then pass an _authors_ option to svn2git pointing to your file:

    $ svn2git http://svn.example.com/path/to/repo --authors ~/authors.txt

Alternatively, you can place the authors file into `~/.svn2git/authors` and
svn2git will load it out of there. This allows you to build up one authors
file for all your projects and have it loaded for each repository that you
migrate.

If you need a jump start on figuring out what users made changes in your
svn repositories the following command sequence might help. It grabs all
the logs from the svn repository, pulls out all the names from the commits,
sorts them, and then reduces the list to only unique names. So, in the end
it outputs a list of usernames of the people that made commits to the svn
repository which name on its own line. This would allow you to easily
redirect the output of this command sequence to `~/.svn2git/authors` and have
a very good starting point for your mapping.

    $ svn log --quiet | grep -E "r[0-9]+ \| .+ \|" | cut -d'|' -f2 | sed 's/ //g' | sort | uniq

Or, for a remote URL:

    $ svn log --quiet http://path/to/root/of/project | grep -E "r[0-9]+ \| .+ \|" | cut -d'|' -f2 | sed 's/ //g' | sort | uniq

Debugging
---------

If you're having problems with converting your repository and you're not sure why,
try turning on verbose logging.  This will print out more information from the
underlying git-svn process.

You can turn on verbose logging with the `-v` or `--verbose` flags, like so:

    $ svn2git http://svn.yoursite.com/path/to/repo --verbose

Options Reference
-----------------

    $ svn2git --help
    Usage: svn2git SVN_URL [options]
    
    Specific options:
            --rebase                     Instead of cloning a new project, rebase an existing one against SVN
            --username NAME              Username for transports that needs it (http(s), svn)
            --password PASS              Password for transports that needs it (http(s), svn)
            --trunk TRUNK_PATH           Subpath to trunk from repository URL (default: trunk)
            --branches BRANCHES_PATH     Subpath to branches from repository URL (default: branches); can be used multiple times
            --tags TAGS_PATH             Subpath to tags from repository URL (default: tags); can be used multiple times
            --rootistrunk                Use this if the root level of the repo is equivalent to the trunk and there are no tags or branches
            --notrunk                    Do not import anything from trunk
            --nobranches                 Do not try to import any branches
            --notags                     Do not try to import any tags
            --no-minimize-url            Accept URLs as-is without attempting to connect to a higher level directory
            --revision START_REV[:END_REV]
                                         Start importing from SVN revision START_REV; optionally end at END_REV
        -m, --metadata                   Include metadata in git logs (git-svn-id)
            --authors AUTHORS_FILE       Path to file containing svn-to-git authors mapping (default: ~/.svn2git/authors)
            --exclude REGEX              Specify a Perl regular expression to filter paths when fetching; can be used multiple times
        -v, --verbose                    Be verbose in logging -- useful for debugging issues
    
        -h, --help                       Show this message

FAQ
---

1. Why don't the tags show up in the master branch?

    The tags won't show up in the master branch because the tags are actually
    tied to the commits that were created in svn when the user made the tag.
    Those commits are the first (head) commit of branch in svn that is
    associated with that tag. If you want to see all the branches and tags
    and their relationships in gitk you can run the following: gitk --all
    
    For further details please refer to FAQ #2.
    
2. Why don't you reference the parent of the tag commits instead?

    In svn you are forced to create what are known in git as annotated tags.
    It just so happens that svn annotated tags allow you to commit change
    sets along with the tagging action. This means that the svn annotated tag
    is a bit more complex then just an annotated tag it is a commit which is
    treated as an annotated tag. Hence, for there to be a true 1-to-1 mapping
    between git and svn we have to transfer over the svn commit which acts as
    an annotated tag and then tag that commit in git using an annotated tag.
    
    If we were to reference the parent of this svn tagged commit there could
    potentially be situations where a developer would checkout a tag in git
    and the resulting code base would be different than if they checked out
    that very same tag in the original svn repo. This is only due to the fact
    that the svn tags allow changesets in them, making them not just annotated
    tags.

