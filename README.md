# govm
govm is a version manager for the [Go](golang.org/) programming language. It
allows for the creation and management of [Workspaces](##workspaces). On the
chance that Workspace management is unecessary for some use cases, govm also
automates the installation process in a way is easy to uninstall in the future.

## Workspaces
A workspace is comprised of a unique `GOPATH` and Go binaries. This means that
modules installed with `go get` are isolated to their own Workspace - allowing
for controlled environments for development and testing.

Additionally, this also means each Workspace can run a different version of Go
which can be swapped with little friction.

## Installation
Installing govm is handled by the setup script: `setup.sh`, which must be run
as `sudo` to ensure it will complete its task. It will copy `govm.sh` to
`/usr/local/bin` under the name `govm` so it can be run, and will modify the
environment to allow for Workspaces to function correctly.

To ensure this, the following 3 lines will be added to the `.5c6einit` file.

    export GOPATH="$HOME/go/current"
    export PATH="$HOME/.govm/current/bin:$PATH"
    export PATH="$HOME/go/current/bin:$PATH"

These will allow for the required binaries to be called when `go` is invoked,
and also add any binary modules fetched with `go get` to the `PATH`.

In order for these changes to take effect, please ensure that your profile file
(`.zprofile`, `.bash_profile`, etc) executes the `.5c6einit` file.

Once the `setup.sh` script has run, and the changes to your shell profile have
been made, restart your terminal for the updates to `PATH` to take effect.

## Usage
govm expects one of 4 commands, [`install`](#install), [`remove`](#remove),
[`set`](#set), and [`list`](#list).

### Install
The `install` command will create a new Workspace, and install the indicated
version of Go in it. `install` has two valid ways to call it, with minor
behavior changes based on which one is used. The structure of the command is:

    $ govm install <version> [workspace]

Calling `install` with both a version and a Workspace name, for example:

    $ govm install 1.16.4 projecta

Will create a new Workspace named 'projecta' that uses version 1.16.4 of Go.
Calling `install` with only a version indicated, such as:

    $ govm install 1.16.4

Will create a Workspace named `go1.16.4` and install the 1.16.4 version of Go.
This second case is provided as some users may just want to install versions of
Go rather than specifically named workspaces for different projects.

When `install` is called for the first time, it will also automatically `set`
the first setup Workspace as the current Workspace.

`install` will also archive any binary archives it downloads to speed up the
creation of new Workspaces that use the same version of Go.

### Remove
The `remove` command will delete a Workspace. It must be called as the super
user via `sudo`. The structure of the command is as follows:

    $ govm remove <workspace>

An example of the use of this command:

    $ sudo govm remove projecta

This would delete the 'projecta' Workspace, the binaries it would run, and any
modules fetched with `go get`.

### Set
The `set` command will set a Workspace as current. This means that the binaries
associated with that Workspace will be referenced in the `PATH` and modules
installed to it will be avaliable for use. The structure of the command is
as follows:

    $ govm set <workspace>

For example:

    $ govm set projecta

Would set the binaries in the 'projecta' Workspace to be called when `go` is
invoked, and mean that the modules installed while `projecta' was the current
Workspace are avaliable for use as libraries and programs.

### List
The `list` command will list all of the currently installed Workspaces as well
as indicating which one is set as current. The structure of the command is:

    $ govm list

An example of the output is as follows:

    projecta       go1.16.4    current
    projectb       go1.16.4
    projectc       go1.15.12

The current Workspace will be indicated by the presence of the word 'current'
after the usual listing.
