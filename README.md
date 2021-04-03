<p align="center">
    <h1 align="center">Bare Emacsclient Eval (BE2)</h1>
    <p align="center">
        Get non-quoted results from evaluating on a Emacs server.
    </p>
</p>

## About

`be2` is like an `emacsclient --eval "EXPR"` that returns the value of `EXPR` using `princ` instead of `print` or `prin1`.

The results are formatted for a human (unquoted) instead of a computer (quoted).

Consequently you can use the results of `be2 EXPR` just like you would any other shell function.

For example instead of this:

``` bash
emacsclient --eval 'emacs-version'
"26.3"
```

You get this:

``` bash
be2 'emacs-version'
26.3
```

If you want quoted output you are responsible for quoting it yourself:

``` bash
be2 '(format "%s" emacs-version)'
"26.3"
```

## Explanation

Shell functions typically don't automatically quote their results. Automatically quoting them can result in unpredictable behavior in the function's caller. `be2` adheres to this best practice of returning the unquoted result of the evaluated code. If you wanted a quoted result of evaluted code you need to quote it yourself. Why does `emacsclient --eval` seem to quote its results in the first place though?

[Apparently](https://emacs.stackexchange.com/questions/9391/why-is-emacsclient-inserting-quotes-around-output-strings) when you run `emacsclient --eval` it returns the value of the expression using either [`print`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html)

> The `print` function is a convenient way of printing.
> It outputs the printed representation of `object` to `stream`,
> printing in addition one newline before `object` and another after it.
> Quoting characters are used.
> `print` returns object.

or [`prin1`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html)

> This function outputs the printed representation
> of `object` to `stream`.
> It does not print newlines to separate output as `print` does,
> but it does use quoting characters just like `print`.
> It returns `object`.

both output a printed representation of `object` for the Elisp [`read`'er](https://www.gnu.org/software/emacs/manual/html_node/elisp/Streams-Intro.html).

[`princ`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html):

> This function outputs the printed representation of
> `object` to `stream`. It returns `object`.
>
> This function is intended to produce output that is
> readable by people, not by `read`, so it doesn’t insert quoting
> characters and doesn’t put double-quotes around the contents of
> strings. It does not add any spacing between calls.

on the other hand outputs a printed representation of `object` for a human to read.

`be2` uses `princ` to produce the expected human-readable printed representation of an `object` other shell functions work with results in a form they expected preventin unpredictable behavior.

## Requirements And Compatibility

- Unix like operating system
  - Tested on MacOS 10.13.
- Emacs
  - Tested on Emacs 26.
- Shell
  - Tested on Bash 5.x.

## Installation

These setup notes include all of the steps common to setting up _any_ Emacs server along with the BE2 specific steps.

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

The default configuration of Non-Interactive Non-Login shells is to neither perform the Bash [startup file sequence](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html) nor allow any interaction ([`PS1`](https://www.gnu.org/software/bash/manual/bash.html#Bash-Variables) is undefined). Consequently you need to define `PATH` and `be2` specific variables within the calling code, instead or relying on your startup files. Fortunately `be` already accounts for this. To use `be2` in Non-Interactive Non-Login shells simply define two variables and `source` the `be2` library file:

``` bash
export BE2SOCKET="/Users/gcr/server-sockets/emacs.sock"
export BE2HOME="/Users/gcr/src/be2"

source "$BE2HOME/be2lib.sh"
```

An example of how to write a script using this approach is included in the project directory named `be2`. It simply passes its arguments directly to the `be2` function: perfect for using your `be2` configuration as a shell-script in a Non-Interactive Non-Login shell.

#### More About Non-Interactive Non-Login Shells

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

#### Keyboard Maestro

[Keyboard Maestro](https://www.keyboardmaestro.com/main/) is a brilliant application. It's got an infinite free evaluation period because there are so many different ways you can use it. While it makes it easy to do everything, I only wanted it to do one thing: let me evaluate code in Emacs using Keyboard Maestro keyboard shortcuts anywhere in any application. Since Keyboard Macro can execute shell scripts in a Non-Interactive Non-Login Shell it can use `be2` just like any other program.

Here is all it takes:
- Create a new macro.
- Triggered by 'This String Is Typed': "emacsSample"
- Add an action: [Execute Shell Script](https://wiki.keyboardmaestro.com/action/Execute_a_Shell_Script).
- Choose "Execute text script" and "type results".
- Then add this `~/src/be2/be2 "EXPR"` to the input box.
  - `EXPR` can be any Elisp code but keep it simple: start with `(+ 1 1)`

Test it out first by choosing to ""display results in a window"". You should get a poup window with `2` in it. Once you've got that working change it back to "type results".

Now, whenever you type "emacsSample" the results of `EXPR` will be evaluated inside Emacs and typed into your computer.

Suddenly you get the best of both worlds: 100% of Emacs available on 100% of your computer. It works brilliantly. I hope you have a lot of fun!

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
