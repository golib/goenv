# Groom your project’s Golang environment with goenv.
> This is based on *Sam Stephenson*'s [rbenv](https://github.com/sstephenson/rbenv) ! And all the wisdom of belong to him!

Use goenv to pick a Golang version for your application and guarantee
that your development environment matches production. You can also maintain
your Golang packages with painless.

**Powerful in development.** Specify your project's Golang version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running projects on different versions of Golang. Just Works™
  from the command line. Override the Golang version anytime: just set
  an environment variable.

**Rock-solid in production.** Your project's executables are its
  interface with ops. With goenv you'll never again need to
  `cd` in a cron job or Chef recipe to ensure you've selected
  the right runtime. The Golang version dependency lives in
  one place—your project—so upgrades and rollbacks are atomic,
  even when you switch versions.

**One thing well.** goenv is concerned solely with switching Golang
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Golang versions
  automatic.

[**Why choose goenv?**](https://github.com/mcspring/goenv/wiki/Why-goenv)

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Golang Version](#choosing-the-go-version)
  * [Locating the Golang Installation](#locating-the-go-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [How goenv hooks into your shell](#how-goenv-hooks-into-your-shell)
  * [Installing Golang Versions](#installing-go-versions)
  * [Uninstalling Golang Versions](#uninstalling-go-versions)
* [Command Reference](#command-reference)
  * [goenv local](#goenv-local)
  * [goenv global](#goenv-global)
  * [goenv shell](#goenv-shell)
  * [goenv versions](#goenv-versions)
  * [goenv version](#goenv-version)
  * [goenv setup](#goenv-setup)
  * [goenv which](#goenv-which)
  * [goenv whence](#goenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, goenv intercepts Golang commands using shim
executables injected into your `PATH`, determines which Golang version
has been specified by your project, and passes your commands along
to the correct Golang installation.

### Understanding PATH

When you run a command like `go` or `godoc`, your operating system
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

Through a process called _setuping_, goenv maintains shims in that
directory to match every Golang command across every installed version
of Golang — `go`, `fix`, `cover`, and so on.

Shims are lightweight executables that simply pass your command along
to goenv. So with goenv installed, when you run, say, `godoc`, your
operating system will do the following:

* Search your `PATH` for an executable file named `godoc`
* Find the goenv shim named `godoc` at the beginning of your `PATH`
* Run the shim named `godoc`, which in turn passes the command along to
  goenv

### Choosing the Golang Version

When you execute a shim, goenv determines which Golang version to use by
reading it from the following sources, in this order:

1. The `GOENV_VERSION` environment variable, if specified. You can use
   the [`goenv shell`](#goenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.go-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.go-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.go-version` file in the current working
   directory with the [`goenv local`](#goenv-local) command.

4. The global `~/.goenv/version` file. You can modify this file using
   the [`goenv global`](#goenv-global) command. If the global version
   file is not present, goenv assumes you want to use the "system" installed
   Golang — i.e. whatever version would be run if goenv weren't in your
   path.

### Choosing the GOPATH

1. The `GOENV_GOPATH` environment variable, if specified. You can use
   the [`goenv shell`](#goenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.go-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.go-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.go-version` file in the current working
   directory with the [`goenv local`](#goenv-local) command.

4. The global `~/.goenv/version` file. You can modify this file using
   the [`goenv global`](#goenv-global) command. If the global version
   file is not present, goenv assumes you want to use the "system" installed
   Golang — i.e. whatever version would be run if goenv weren't in your
   path.

### Locating the Golang Installation

Once goenv has determined which version of Golang your project has
specified, it passes the command along to the corresponding Golang
installation.

Each Golang version is installed into its own directory under
`~/.goenv/versions`. For example, you might have these versions
installed:

* `~/.goenv/versions/go-1/`
* `~/.goenv/versions/go-1.2/`
* `~/.goenv/versions/go-1.2.1/`

Version names to goenv are simply the names of the directories in
`~/.goenv/versions`.

## Installation

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of goenv and make it
easy to fork and contribute any changes back upstream.

1. Check out goenv into `~/.goenv`.

    ~~~ sh
    $ git clone https://github.com/golib/goenv.git ~/.goenv
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
$ git checkout v1
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade goenv
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
goenv using the [Homebrew](http://brew.sh) package manager on Mac OS X:

~~~
$ brew update
$ brew install goenv
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

3. Setupes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `goenv setup` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   goenv and plugins to change variables in your current shell, making
   commands like `goenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `goenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `goenv init -` for yourself to see exactly what happens under the
hood.

### Installing Golang Versions

Upgrade locale cache by run:

~~~ sh
# upgrade locale cache
$ goenv upgrade
~~~

List all available versions by run:

~~~ sh
# list all available versions
$ goenv list
~~~

Install the specified version by run:

~~~ sh
# install go1
$ goenv install go1
~~~

Alternatively to the `install` command, you can download and compile
Golang manually as a subdirectory of `~/.goenv/versions/`. An entry in
that directory can also be a symlink to a Golang version installed
elsewhere on the filesystem. goenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Golang version.

### Uninstalling Golang Versions

As time goes on, Golang versions you install will accumulate in your
`~/.goenv/versions` directory.

~~~ sh
# uninstall a Golang version
$ goenv uninstall go1
~~~

To remove old Golang versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Golang version with the `goenv prefix` command, e.g. `goenv prefix
1.2`.

## Command Reference

Like `git`, the `goenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### goenv local

Sets a local project-specific Golang version by writing the version
name to a `.go-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `GOENV_VERSION` environment variable or with the `goenv shell`
command.

    $ goenv local 1.2

When run without a version number, `goenv local` reports the currently
configured local version. You can also unset the local version:

    $ goenv local --unset

### goenv global

Sets the global version of Golang to be used in all shells by writing
the version name to the `~/.goenv/version` file. This version can be
overridden by an project-specific `.go-version` file, or by
setting the `GOENV_VERSION` environment variable.

    $ goenv global 1.2.1

The special version name `system` tells goenv to use the system Golang
(detected by searching your `$PATH`).

When run without a version number, `goenv global` reports the
currently configured global version.

### goenv shell

Sets a shell-specific Golang version by setting the `GOENV_VERSION`
environment variable in your shell. This version overrides
project-specific versions and the global version.

    $ goenv shell go1

When run without a version number, `goenv shell` reports the current
value of `GOENV_VERSION`. You can also unset the shell version:

    $ goenv shell --unset

Note that you'll need goenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`GOENV_VERSION` variable yourself:

    $ export GOENV_VERSION=go1

### goenv versions

Lists all installed Golang versions known to goenv, and shows an asterisk next to
the currently active version.

    $ goenv versions
      go1
      1.2
    * 1.2.1 (set by /Users/mc/.goenv/version)

### goenv version

Displays the currently active Golang version, along with information on
how it was set.

    $ goenv version
    1.2.1 (set by /Volumes/golang/.go-version)

### goenv setup

Installs shims for all Golang executables known to goenv (i.e.,
`~/.goenv/versions/*/bin/*`). Run this command after you install a new
version of Golang, or install a program that provides commands.

    $ goenv setup

### goenv which

Displays the full path to the executable that goenv will invoke when
you run the given command.

    $ goenv which fix
    /Users/mc/.goenv/versions/1.2.1/bin/fix

### goenv whence

Lists all Golang versions with the given command installed.

    $ goenv whence godoc
    go1
    1.2.1

## Development

The goenv source code is hosted on [GitHub](https://github.com/golib/goenv).
It's clean, modular, and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/golib/goenv/issues).

### Version History

**1.0.0** (March 11, 2014)

* Initial public release.

### License

(The MIT license)

```
Copyright (c) 2013 Spring MC

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
```
