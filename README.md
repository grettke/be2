<p align="center">
    <h1 align="center">Bare Emacsclient Eval (BE2)</h1>
    <p align="center">
        Make Emacs server eval return unquoted value.
    </p>
</p>

## 𝙏𝙇𝘿𝙍

Couldn't make `emacsclient`'s `eval` return unquoted value so use `server-eval-at` in batch-mode instead because it directs the printer output directly (unquoted) to `STDOUT`:


``` emacs-lisp
emacs --batch --eval "(progn (require 'server) (princ (server-eval-at "server" 'emacs-version)))".

```

**Nothing further beyond 𝙏𝙇𝘿𝙍 is required: it contains the single example necessary to get the desired behavior.**

Everything _following_ provides some examples, explains the context and justification for the approach, and finally walks through my _highly personalized process_ to configuring `be2` for use in both the Bash shell and [Keyboard Maestro](https://www.keyboardmaestro.com/main/).

## About

`be2` is like an `emacsclient --eval "EXPR"` that returns the value of `EXPR` using `princ` instead of `print` or `prin1`.

The results are formatted for a human (unquoted) instead of a computer (quoted).

Consequently you can use the results of `be2 EXPR"` just like you would any other shell function.

For example instead of this (note the quoted result):

``` bash
emacsclient --eval 'emacs-version'
"26.3"
```

You get this (note the unquoted result):

``` bash
be2 'emacs-version'
26.3
```

If you want quoted output you are responsible for quoting it yourself:

``` bash
be2 '(format "%s" emacs-version)'
"26.3"
```

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

## Explanation

Why does this one-line work the way it does?

To make sense of the solution follow the story in this explanation.

###  Goal

Shell functions typically don't automatically quote their results. Automatically quoting them can result in unpredictable behavior in the function's caller. `be2` adheres to this best practice of returning the unquoted result of the evaluated code. If you want a quoted result of evaluted code you need to quote it yourself. Why does `emacsclient --eval` seem to quote its results in the first place though?

### Source Of Solution

[This article](https://emacs.stackexchange.com/questions/9391/why-is-emacsclient-inserting-quotes-around-output-strings) explains that  when you run `emacsclient --eval` it returns the value of the expression from `STDOUT`. Why though? Why is this happening?

### Printing Functions

Its important to understand how Emacs prints object information. There are three common ways to do it. Here is an overview:

Using either [`print`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html)

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

output a printed representation of `object` for the Elisp [`read`'er](https://www.gnu.org/software/emacs/manual/html_node/elisp/Streams-Intro.html).

[`princ`](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Functions.html):

> This function outputs the printed representation of
> `object` to `stream`. It returns `object`.
>
> This function is intended to produce output that is
> readable by people, not by `read`, so it doesn’t insert quoting
> characters and doesn’t put double-quotes around the contents of
> strings. It does not add any spacing between calls.

on the other hand outputs a printed representation of `object` for a human to read.

`emacsclient --eval` returns the quoted representation.

`server-eval-set` returns the unquoted representation.

Why?

### Getting To The Code

Debugging the Emacs server is an easy and fun way to learn what is happening in the code. Here is where to start:

- Stop Emacs
- Back up your server library file `server.el.gz` (assuming you are running a packaged Emacs)
  - Find your Emacs installation directory by running `which emacs`.
  - If it is a symbolic link then `ls` on it
  - Go there and fine the library file
    - `find . -name server.el.gz`
    - Back it up:
      - `cp ./Resources/lisp/server.el.gz ./Resources/lisp/server-ORG.el.gz `
- Start Emacs again
- Go to the function `server-start`
  - Type `C-h f server-eval-at RET`
  - Go the the `*Help*` window.
  - Move the cursor to the highlighted text `server.el` and hit RET.
- Now you are viewing the code for the Emacs server. This is where your journey begins.

### Handling Requests

The Emacs Server (from here referred to as The Server) interacts with Emacs Clients (from here referred to as The Client) in a typical client-server architecture.

Here is how it works:

#### Using `emacsclient`

- From here forward you are working inside of the Emacs that is open in the GUI. This is the one that you do most of your work in. It is The Server. The explanation below explains what happens when `emacsclient` contact The Server to evaluate code. `emacsclient` like the name implies is The Client.
- You start the server by calling `server-start`
- Function: `server-start`
  - Nearly everything you want to learn about The Server starts here.
  - Fun function to read and study.
  - Starts a subprocess that sits there and waits for client connections.
  - Key study point: the network process is configured with
    - `:filter #'server-process-filter`
    - So start there
- Suppose now you use `emacsclient` to connect to The Server and evaluate an expression. The Server handles a connected client in the function `server-process-filter`.
- Function: `server-process-filter`
  - Handles client request to evaluate an expression.
  - The _server_ handles many different commands. We care about `eval`
    - `'-eval EXPR'
  Evaluate EXPR as a Lisp expression and return the
  result in -print commands.`
  - The _client_ handles many different commands. We care about `print`
    - `'-print STRING'
  Print STRING on stdout.  Used to send values
  returned by -eval.`
  - Delegates `eval` work to `server-eval-and-print`
- Function: `server-eval-and-print`
  - "Eval EXPR and send the result back to client PROC."
  - Very interesting and brief function that does a lot.
  - Evalute the code; disable `C-g` until the evalution completes
  - Create a temp buffer
  - Redirect standard-out to it
  - `pp` the result to standard-out (the default output stream)
    - Uses `princ` to write the object's printed representation so it is unquoted.
    - That means "26.3" is represented as "26.3" because it is a string. This string value, the entire sequence of characters "double-quote-26.3-double-quote" _is_ the value that will be returned so Emacs knows to retain the double quotes.
  - Get the buffer contents
  - Prepare a special "server quote" of them and call `-print` on the client: thus returning the result of evaluation
- This is how `emacsclient` handles `--eval`. This explains why results are quoted: because `server-eval-and-print` returns then that way. That is fine but we want unquoted results.

#### Using `server-eval-at`

- From here forward you are working at the command-line with `be2`.
- `be` is now The Client
  - It start Emacs
  - Loads `server.el` and connects to The Server.
  - Evaluates the code passed by the user using `server-eval-at`
- `be2` starts starts an Emacs instance in [batch mode](https://www.gnu.org/software/emacs/manual/html_node/elisp/Batch-Mode.html). In batch mode Emacs will behave like this:
> Any Lisp program output that would normally go to the echo area, either
> using `message`, or using `prin1`, etc., with `t` as the stream (see [Output Streams](https://www.gnu.org/software/emacs/manual/html_node/elisp/Output-Streams.html)), goes instead to Emacs’s standard descriptors when in batch mode:  `message` writes to the standard error descriptor, while `prin1` and other print functions write to the standard output. Similarly, input that would normally come from the minibuffer is read from the standard input descriptor. Thus, Emacs behaves much like a noninteractive application program. (The echo area output that Emacs itself normally generates, such as command echoing, is suppressed entirely.)
- It connects to The Server socket.
- It requests The Server to evaluate the user's code using `server-eval-at`
- Function: `server-eval-at`
  - Create a new process used to contact The Server
    - Emacs is creating a new network process
    - It is now creating a process to speakg with itself
  - It connects to the server (itself)
  - It sends the `-eval` message with the `EXPR` you sent it
    - This enters `server-eval-and-print` to handle the request
    - It returns the normal result
- In `server-eval-at` The Client `read`'s the result of `server-eval-and-print`. Since The Client is running in batch mode the value is output to directly to `STDOUT` unquoted.
- This is why `server-eval-at` doesn't quote its results and why `be2` is necessary.

### Are `emacsclient` and Emacs the same thing?

That is a good question. Since they both `eval` code. Is `emacsclient` really Emacs behind the scenes? The answer is in the code.

You've already been reading `server.el` so you know that it is running inside Emacs. What about `emacsclient` though?

Check out the Emacs source code [from Git](git clone https://github.com/mirrors/emacs.git) and open the file `./lib-src/emacsclient.c`.

`emacsclient` is a C executable: it is not Emacs.

Emacs and `emacsclient` are not the same thing.

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
