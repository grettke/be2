<p align="center">
<h1 align="center">Bash Emacs Eval (BE2)</h1>
<p align="center">Evaluate single-line Elisp expressions on a running local Emacs instance.</p>
</p>

## About

This script helps you evaluate a single-line Elisp expression on a running local Emacs instance from a Bash shell.

## Requirements And Compatibility

- Unix like operating system
  - Tested on MacOS 10.13.
- Emacs
  - BE2 is tested against Emacs 26.
  - BE2 only uses libraries included with Emacs.
- Shell
  - BE2 is tested against Bash 5.0.
- Optionally
  - `git` to pull the project.

## Installation

Caffeinate yourself and follow the steps: it will all make sense when you are finished.

### Required Setup

This setup works for when you log in using for example your favorite terminal app or over SSH. It configures your setup so you can:
- Call `be2` directly from the terminal.
- Call `be2` within a shell script.

This is how to use it interactively like you would expect for both login and non-login shells.

#### Bash

Specify a *fully-qualified* file in your home directory to act as your server-socket file:

``` bash
export BE2SOCKET="/Users/gcr/server-sockets/emacs.sock"
```

Configure the socket restricting access permissions to only yourself:

``` bash
mkdir ~/server-sockets/
cd ~/server-sockets/
touch emacs.sock
chmod 700 emacs.sock
```
#### Emacs

Configure Emacs to start it's server on the socket:

``` emacs-lisp
(setq server-name (getenv "BE2SOCKET"))
(server-start)
```

#### BE2

Close and start a new shell.

Start Emacs.

Verify the socket file exists with the correct permissions.

Check out the code:

``` bash
cd ~/src
git clone git@github.com:grettke/be2.git
```

Load it in:

``` bash
export BE2HOME="/Users/gcr/src/be2"
source "BE2HOME/be2lib.sh"
```

Create a new shell and Emacs instance to check for startup errors. Fix any. Evaluate some code from the command line on the Emacs instance. The EXPR must be enclosed in quotes. *Carefully* escape your single and double quotes!

Call `be2` stand-alone:

``` bash
be2 '(message "Hello, world.")'
# Results go to STDOUT just like you expect.
be2 '(message "Hello, world.")' >> ~/tmp/log.txt
be2 "(+ 1 1)"
be2 "emacs-version"
```

Call `be2` inside other code:

``` bash
printf "How many is binary? $(be2 '(+ 1 1)')\n"
```

### For Non-Interactive Non-Login Shells

The first time you learn about Non-Interactive Non-Login Shells it can be very surprising. Fortunately there are a lot of great resources explaining why the exist, how they work, and how to configure them. The best place to start is with a single resource that thoroughly explains everything you need to learn.

That resource is [this](https://unix.stackexchange.com/questions/170493/login-non-login-and-interactive-non-interactive-shells#170499)! Please read it a few times to take in the difference between shell types. Soon you will find the differences are pretty straightforward. It can also have fun to run some code and see for yourself what is what.

Here is how to determine for yourself exactly how a shell is configured:

- Is this shell an: Interactive Shell?
``` bash
if [ -z "$PS1" ]; then
  printf "This shell is *not* interactive.\n"
else
  printf "This shell *is* interactive.\n"
fi
```

- Is this shell a: Login Shell?
``` bash
if shopt login_shell | grep "on"; then
  printf "This *is* a login shell.\n"
else
  printf "This is *not* a login shell.\n"
fi
```

The best way to have fun now is to run that code in different situations. For example, try logging in to a terminal and running it, putting it in a script and calling it from the terminal, running it via `cron`, and thoroughly executing the shell from another process. That is likely to cover all combinations of shell types. If you read this far, then check out one of the most fun ways you can work with a Non-Interactive Non-Login Shell.

[Keyboard Maestro](https://www.keyboardmaestro.com/main/) is a brilliant application. It's got an infinite free evaluation period because there are so many different ways you can use it. While it makes it easy to do everything, I only wanted it to do one thing: let me evaluate code in Emacs using Keyboard Maestro keyboard shortcuts anywhere in any application.

Here is all it takes:
- Create a new macro.
- Triggered by 'This String Is Typed': "emacsSample"
- Add an action: [Execute Shell Script](https://wiki.keyboardmaestro.com/action/Execute_a_Shell_Script).
- Choose "Execute text script" and "type results".
- Then add this `~/src/be2/be2 "(EXPR)"` to the input box.
  - `EXPR` can be any Elisp code but keep it simple: start with `(+ 1 1)`

Now, whenever you type "emacsSample" the results of `EXPR` will be evaluated inside Emacs and typed into your computer.

Suddenly you get the best of both worlds: 100% of Emacs available on 100% of your computer. It works brilliantly. I hope you have a lot of fun!

## Resources

- The following are all of the Documentation, Related Projects, References, and Discussion out there.
- *Entry Format* follows
- Name and URL of reference:
  - Description of resource.
  - Relevance of, comparison to, and discussion about follows.

### GNU Emacs Official

- [GNU Emacs 24.1 NEWS](https://www.gnu.org/software/emacs/news/NEWS.24.1)
  - Release notes announcing addition of `server-eval-at`.
  - "The new function `server-eval-at` allows evaluation of Lisp forms on
named Emacs server instances."

- [Using Emacs as a Server](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html):
  - "Various programs can invoke your choice of editor to edit a particular piece of text."
  - Primarily explains how to use `emacsclient`.
  - Briefly mentions that "it is possible to connect to the server from another Emacs instance and evaluate Lisp expressions on the server, using the `server-eval-at` function" and that "this feature is mainly useful for developers."
  - That distinction clarifies the primary difference between `emacsclient` and `be2`.

### Elisp Packages

- [jwiegley/emacs-async](https://github.com/jwiegley/emacs-async):
  - "`async.el` is a module for doing asynchronous processing in Emacs."
  - `async.el` performs asynchronous tasks initiated by the running Emacs instance. For example, it is independently compiling code or sending an email. `be2` is connecting to a running Emacs instance to evaluate code. There is no overlap between them.

### Real-World Applications

- [Elnode](https://github.com/nicferrier/elnode.git)
  - "An evented IO webserver in Emacs Lisp."
  - From [elnode-rle.el](https://github.com/nicferrier/elnode/blob/master/elnode-rle.el)
    - "This is an elnode handler and tools for doing asynchrous programming."
    - "The idea is that you can setup associated child processes and pass them work to do and receive their output over HTTP."
  - Implements client-server process within Elnode itself.
- [dockerfile-elnode-Dockerfile for rapid developing Elnode based web-application.](https://github.com/supermomonga/dockerfile-elnode)
  - Hot-deploy to [Elnode](https://github.com/nicferrier/elnode) running inside of a Docker instance.
  - Configures an Emacs-server inside the Docker container.
  - Connect to it with `server-eval-at` for live-coding on the running Elnode server.
- [Airplay for Emacs](https://github.com/gongo/airplay-el)
  - "A client for AirPlay Server." (to clarify the name *doesn't* reflect the fact that it is _actually_ an AirPlay server itself)
  - `airplay-el` uses [simple-httpd](https://github.com/skeeto/emacs-web-server) to act as an [Apple AirPlay](https://www.apple.com/airplay/) server.
  - Clients control this server by using `server-eval-at` to execute commands to for example play movies or display pictures.

### Articles

- [What’s New in Emacs 24 (part 2)
By Mickey Petersen](https://masteringemacs.net/article/what-is-new-in-emacs-24-part-2)
  - Blog post.
  - "Hmm. There’s a lot of potential locked away in this one command. Large-scale mapreduce clusters are, I suppose, now possible with Emacs thanks to Elisp and the functions `map` and `reduce` :-)"
  - Totally agreed. Maybe even [The Dining Philosophers](https://en.wikipedia.org/wiki/Dining_philosophers_problem) can benefit from this.
- [Why is Emacsclient inserting quotes around output strings?](https://emacs.stackexchange.com/questions/9391/why-is-emacsclient-inserting-quotes-around-output-strings)
  - Title describes question posed.
  - Discussion trying to determine the relationship between `princ` and `server-eval-at`. Somewhat inconclusive.
- [print unquoted output to stdout from emacsclient](https://emacs.stackexchange.com/questions/28665/print-unquoted-output-to-stdout-from-emacsclient)
  - Title describes question posed.
  - Their observation:
    - `emacsclient` seems to return only the result of the evaluated code.
    - `server-eval-at` seems to return the value printed to `stdout`.

## Contributing

[Feature Requests](https://github.com/grettke/be2/issues/new/choose) and [Bug Reports](https://github.com/grettke/be2/issues/new/choose) are welcome.

This project intends to be a safe, welcoming space for collaboration, and contributors must adhere to [our Code of Conduct](https://github.com/grettke/be2/blob/master/CODE_OF_CONDUCT.md).

### Submitting content changes:

#### By Hand

- Open a [Feature Request](https://github.com/grettke/be2/issues/new/choose).
- Fill out the questionnaire.
- Review and discuss the request further.

#### Via Git

- Open a [Pull Request](https://github.com/grettke/be2/pulls).
- Await code review.

# License

- [GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007](./LICENSE.txt).
