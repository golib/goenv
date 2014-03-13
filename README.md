# Groom your app’s Ruby environment with goenv.

Use goenv to pick a Ruby version for your application and guarantee
that your development environment matches production. Put goenv to work
with [Bundler](http://gembundler.com/) for painless Ruby upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Ruby version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Ruby. Just Works™
  from the command line and with app servers like [Pow](http://pow.cx).
  Override the Ruby version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With goenv and [Bundler
  binstubs](https://github.com/sstephenson/goenv/wiki/Understanding-binstubs)
  you'll never again need to `cd` in a cron job or Chef recipe to
  ensure you've selected the right runtime. The Ruby version
  dependency lives in one place—your app—so upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** goenv is concerned solely with switching Ruby
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Ruby versions, or
  use the [ruby-build][]
  plugin to automate the process. Specify per-application environment
  variables with [goenv-vars](https://github.com/sstephenson/goenv-vars).
  See more [plugins on the
  wiki](https://github.com/sstephenson/goenv/wiki/Plugins).

[**Why choose goenv over
RVM?**](https://github.com/sstephenson/goenv/wiki/Why-goenv%3F)

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Ruby Version](#choosing-the-ruby-version)
  * [Locating the Ruby Installation](#locating-the-ruby-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [How goenv hooks into your shell](#how-goenv-hooks-into-your-shell)
  * [Installing Ruby Versions](#installing-ruby-versions)
  * [Uninstalling Ruby Versions](#uninstalling-ruby-versions)
* [Command Reference](#command-reference)
  * [goenv local](#goenv-local)
  * [goenv global](#goenv-global)
  * [goenv shell](#goenv-shell)
  * [goenv versions](#goenv-versions)
  * [goenv version](#goenv-version)
  * [goenv rehash](#goenv-rehash)
  * [goenv which](#goenv-which)
  * [goenv whence](#goenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, goenv intercepts Ruby commands using shim
executables injected into your `PATH`, determines which Ruby version
has been specified by your application, and passes your commands along
to the correct Ruby installation.

### Understanding PATH

When you run a command like `ruby` or `rake`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

goenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.goenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, goenv maintains shims in that
directory to match every Ruby command across every installed version
of Ruby—`irb`, `gem`, `rake`, `rails`, `ruby`, and so on.

Shims are lightweight executables that simply pass your command along
to goenv. So with goenv installed, when you run, say, `rake`, your
operating system will do the following:

* Search your `PATH` for an executable file named `rake`
* Find the goenv shim named `rake` at the beginning of your `PATH`
* Run the shim named `rake`, which in turn passes the command along to
  goenv

### Choosing the Ruby Version

When you execute a shim, goenv determines which Ruby version to use by
reading it from the following sources, in this order:

1. The `RBENV_VERSION` environment variable, if specified. You can use
   the [`goenv shell`](#goenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.ruby-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.ruby-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.ruby-version` file in the current working
   directory with the [`goenv local`](#goenv-local) command.

4. The global `~/.goenv/version` file. You can modify this file using
   the [`goenv global`](#goenv-global) command. If the global version
   file is not present, goenv assumes you want to use the "system"
   Ruby—i.e. whatever version would be run if goenv weren't in your
   path.

### Locating the Ruby Installation

Once goenv has determined which version of Ruby your application has
specified, it passes the command along to the corresponding Ruby
installation.

Each Ruby version is installed into its own directory under
`~/.goenv/versions`. For example, you might have these versions
installed:

* `~/.goenv/versions/1.8.7-p371/`
* `~/.goenv/versions/1.9.3-p327/`
* `~/.goenv/versions/jruby-1.7.1/`

Version names to goenv are simply the names of the directories in
`~/.goenv/versions`.

## Installation

**Compatibility note**: goenv is _incompatible_ with RVM. Please make
  sure to fully uninstall RVM and remove any references to it from
  your shell initialization files before installing goenv.

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of goenv and make it
easy to fork and contribute any changes back upstream.

1. Check out goenv into `~/.goenv`.

    ~~~ sh
    $ git clone https://github.com/sstephenson/goenv.git ~/.goenv
    ~~~

2. Add `~/.goenv/bin` to your `$PATH` for access to the `goenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.goenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `goenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(goenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if goenv was set up:

    ~~~ sh
    $ type goenv
    #=> "goenv is a function"
    ~~~

5. _(Optional)_ Install [ruby-build][], which provides the
   `goenv install` command that simplifies the process of
   [installing new Ruby versions](#installing-ruby-versions).

#### Upgrading

If you've installed goenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.goenv
$ git pull
~~~

To use a specific release of goenv, check out the corresponding tag:

~~~ sh
$ cd ~/.goenv
$ git fetch
$ git checkout v0.3.0
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade goenv ruby-build
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
goenv and [ruby-build][] using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew update
$ brew install goenv ruby-build
~~~

Afterwards you'll still need to add `eval "$(goenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

### How goenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`goenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `goenv init` actually does:

1. Sets up your shims path. This is the only requirement for goenv to
   function properly. You can do this by hand by prepending
   `~/.goenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.goenv/completions/goenv.bash` will set that
   up. There is also a `~/.goenv/completions/goenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `goenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   goenv and plugins to change variables in your current shell, making
   commands like `goenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `goenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `goenv init -` for yourself to see exactly what happens under the
hood.

### Installing Ruby Versions

The `goenv install` command doesn't ship with goenv out of the box, but
is provided by the [ruby-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ goenv install -l

# install a Ruby version:
$ goenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Ruby manually as a subdirectory of `~/.goenv/versions/`. An entry in
that directory can also be a symlink to a Ruby version installed
elsewhere on the filesystem. goenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Ruby version.

### Uninstalling Ruby Versions

As time goes on, Ruby versions you install will accumulate in your
`~/.goenv/versions` directory.

To remove old Ruby versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Ruby version with the `goenv prefix` command, e.g. `goenv prefix
1.8.7-p357`.

The [ruby-build][] plugin provides an `goenv uninstall` command to
automate the removal process.

## Command Reference

Like `git`, the `goenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### goenv local

Sets a local application-specific Ruby version by writing the version
name to a `.ruby-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `RBENV_VERSION` environment variable or with the `goenv shell`
command.

    $ goenv local 1.9.3-p327

When run without a version number, `goenv local` reports the currently
configured local version. You can also unset the local version:

    $ goenv local --unset

Previous versions of goenv stored local version specifications in a
file named `.goenv-version`. For backwards compatibility, goenv will
read a local version specified in an `.goenv-version` file, but a
`.ruby-version` file in the same directory will take precedence.

### goenv global

Sets the global version of Ruby to be used in all shells by writing
the version name to the `~/.goenv/version` file. This version can be
overridden by an application-specific `.ruby-version` file, or by
setting the `RBENV_VERSION` environment variable.

    $ goenv global 1.8.7-p352

The special version name `system` tells goenv to use the system Ruby
(detected by searching your `$PATH`).

When run without a version number, `goenv global` reports the
currently configured global version.

### goenv shell

Sets a shell-specific Ruby version by setting the `RBENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ goenv shell jruby-1.7.1

When run without a version number, `goenv shell` reports the current
value of `RBENV_VERSION`. You can also unset the shell version:

    $ goenv shell --unset

Note that you'll need goenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`RBENV_VERSION` variable yourself:

    $ export RBENV_VERSION=jruby-1.7.1

### goenv versions

Lists all Ruby versions known to goenv, and shows an asterisk next to
the currently active version.

    $ goenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.goenv/version)
      jruby-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### goenv version

Displays the currently active Ruby version, along with information on
how it was set.

    $ goenv version
    1.8.7-p352 (set by /Volumes/37signals/basecamp/.ruby-version)

### goenv rehash

Installs shims for all Ruby executables known to goenv (i.e.,
`~/.goenv/versions/*/bin/*`). Run this command after you install a new
version of Ruby, or install a gem that provides commands.

    $ goenv rehash

### goenv which

Displays the full path to the executable that goenv will invoke when
you run the given command.

    $ goenv which irb
    /Users/sam/.goenv/versions/1.9.3-p327/bin/irb

### goenv whence

Lists all Ruby versions with the given command installed.

    $ goenv whence rackup
    1.9.3-p327
    jruby-1.7.1
    ree-1.8.7-2011.03

## Development

The goenv source code is [hosted on
GitHub](https://github.com/sstephenson/goenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sstephenson/goenv/issues).

### Version History

**0.4.0** (January 4, 2013)

* goenv now prefers `.ruby-version` files to `.goenv-version` files
  for specifying local application-specific versions. The
  `.ruby-version` file has the same format as `.goenv-version` but is
  [compatible with other Ruby version
  managers](https://gist.github.com/1912050).
* Deprecated `ruby-local-exec` and moved its functionality into the
  standard `ruby` shim. See the [ruby-local-exec wiki
  page](https://github.com/sstephenson/goenv/wiki/ruby-local-exec) for
  upgrade instructions.
* Modified shims to include the full path to goenv so that they can be
  invoked without having goenv's bin directory in the `$PATH`.
* Sped up `goenv init` by avoiding goenv reinitialization and by
  using a simpler indexing approach. (Users of
  [chef-goenv](https://github.com/fnichol/chef-goenv) should upgrade
  to the latest version to fix a [compatibility
  issue](https://github.com/fnichol/chef-goenv/pull/26).)
* Reworked `goenv help` so that usage and documentation is stored as a
  comment in each subcommand, enabling plugin commands to hook into
  the help system.
* Added support for full completion of the command line, not just the
  first argument.
* Updated installation instructions for Zsh and Ubuntu users.
* Fixed `goenv which` and `goenv prefix` with system Ruby versions.
* Changed `goenv exec` to avoid prepending the system Ruby location to
  `$PATH` to fix issues running system Ruby commands that invoke other
  commands.
* Changed `goenv rehash` to ensure it exits with a 0 status code under
  normal operation, and to ensure outdated shims are removed first
  when rehashing.
* Modified `goenv rehash` to run `hash -r` afterwards, when shell
  integration is enabled, to ensure the shell's command cache is
  cleared.
* Removed use of the `+=` operator to support older versions of Bash.
* Adjusted non-bare `goenv versions` output to include `system`, if
  present.
* Improved documentation for installing and uninstalling Ruby
  versions.
* Fixed `goenv versions` not to display a warning if the currently
  specified version doesn't exist.
* Fixed an instance of local variable leakage in the `goenv` shell
  function wrapper.
* Changed `goenv shell` to ensure it exits with a non-zero status on
  failure.
* Added `goenv --version` for printing the current version of goenv.
* Added `/usr/lib/goenv/hooks` to the plugin hook search path.
* Fixed `goenv which` to account for path entries with spaces.
* Changed `goenv init` to accept option arguments in any order.

**0.3.0** (December 25, 2011)

* Added an `goenv root` command which prints the value of
  `$GOENV_ROOT`, or the default root directory if it's unset.
* Clarified Zsh installation instructions in the Readme.
* Removed some redundant code in `goenv rehash`.
* Fixed an issue with calling `readlink` for paths with spaces.
* Changed Zsh initialization code to install completion hooks only for
  interactive shells.
* Added preliminary support for ksh.
* `goenv rehash` creates or removes shims only when necessary instead
  of removing and re-creating all shims on each invocation.
* Fixed that `GOENV_DIR`, when specified, would be incorrectly
  expanded to its parent directory.
* Removed the deprecated `set-default` and `set-local` commands.
* Added a `--no-rehash` option to `goenv init` for skipping the
  automatic rehash when opening a new shell.

**0.2.1** (October 1, 2011)

* Changed the `goenv` command to ensure that `GOENV_DIR` is always an
  absolute path. This fixes an issue where Ruby scripts using the
  `ruby-local-exec` wrapper would go into an infinite loop when
  invoked with a relative path from the command line.

**0.2.0** (September 28, 2011)

* Renamed `goenv set-default` to `goenv global` and `goenv set-local`
  to `goenv local`. The `set-` commands are deprecated and will be
  removed in the next major release.
* goenv now uses `greadlink` on Solaris.
* Added a `ruby-local-exec` command which can be used in shebangs in
  place of `#!/usr/bin/env ruby` to properly set the project-specific
  Ruby version regardless of current working directory.
* Fixed an issue with `goenv rehash` when no binaries are present.
* Added support for `goenv-sh-*` commands, which run inside the
  current shell instead of in a child process.
* Added an `goenv shell` command for conveniently setting the
  `$RBENV_VERSION` environment variable.
* Added support for storing goenv versions and shims in directories
  other than `~/.goenv` with the `$GOENV_ROOT` environment variable.
* Added support for debugging goenv via `set -x` when the
  `$GOENV_DEBUG` environment variable is set.
* Refactored the autocompletion system so that completions are now
  built-in to each command and shared between bash and Zsh.
* Added support for plugin bundles in `~/.goenv/plugins` as documented
  in [issue #102](https://github.com/sstephenson/goenv/pull/102).
* Added `/usr/local/etc/goenv.d` to the list of directories searched
  for goenv hooks.
* Added support for an `$GOENV_DIR` environment variable which
  defaults to the current working directory for specifying where goenv
  searches for local version files.

**0.1.2** (August 16, 2011)

* Fixed goenv to be more resilient against nonexistent entries in
  `$PATH`.
* Made the `goenv rehash` command operate atomically.
* Modified the `goenv init` script to automatically run `goenv
  rehash` so that shims are recreated whenever a new shell is opened.
* Added initial support for Zsh autocompletion.
* Removed the dependency on egrep for reading version files.

**0.1.1** (August 14, 2011)

* Fixed a syntax error in the `goenv help` command.
* Removed `-e` from the shebang in favor of `set -e` at the top of
  each file for compatibility with operating systems that do not
  support more than one argument in the shebang.

**0.1.0** (August 11, 2011)

* Initial public release.

### License

(The MIT license)

Copyright (c) 2013 Sam Stephenson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [ruby-build]: https://github.com/sstephenson/ruby-build#readme
