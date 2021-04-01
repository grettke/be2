<p align="center">
<h1 align="center">MOre baSH EMacs evAL (MOSHEMAL)</h1>
<p align="center">Evaluate single-line Elisp expressions on a running local Emacs instance.</p>
</p>

## About

This script helps you evaluate a single-line Elisp expression on a running local Emacs instance from a Bash shell.

## Requirements And Compatibility

- Unix like operating system
  - Tested on MacOS 10.13.
- Emacs
  - MOSHEMAL is tested against Emacs 26.
    - MOSHEMAL only uses libraries included with Emacs.
- Shell
  - MOSHEMAL is tested against Bash 5.0.
    - Bash-isms are minimal and this script can easily be adapted to your favorite shell.
- Optionally
  - `git` to pull the project.

## Installation

Caffeinate yourself and follow the steps: it will all make sense when you are finished.

### Bash

Specify a *full-qualified* file in your home director to act as your server-socket file:

``` bash
export EMACSSOCKET="/Users/gcr/server-sockets/emacs.sock"
```

Configure the socket restricting access permissions to only yourself:

``` bash
mkdir ~/server-sockets/
cd ~/server-sockets/
touch emacs.sock
chmod 700 emacs.sock
```

### Emacs

Configure Emacs to start it's server on the socket:

``` emacs-lisp
(setq server-name (getenv "EMACSSOCKET"))
(server-start)
```

Either evaluate that or restart Emacs.

### MOSHEMAL

Verify the socket file exists with the correct permissions.

Check out the code:

``` bash
cd ~/src
git clone git@github.com:grettke/moshemal.git
```

Load it in:

``` bash
source "$EMACSSOCKET=""
```

Create a new shell and Emacs instance to check for startup errors. Fix any. Evaluate some code from the command line on a running Emacs instance. The EXPR must be enclosed in quotes.

``` bash
moshemal '(message "Hello, world.")'
moshemal '(message "Hello, world.")' >> ~/tmp/log.txt
moshemal "(+ 1 1)"
```

Always consider how you escape your single and double quotes.

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
  - That distinction clarifies the primary difference between `emacsclient` and `moshemal`.

### Elisp Packages

- [jwiegley/emacs-async](https://github.com/jwiegley/emacs-async):
  - "`async.el` is a module for doing asynchronous processing in Emacs."
  - `async.el` performs asynchronous tasks initiated by the running Emacs instance. For example, it is independently compiling code or sending an email. `moshemal` is connecting to a running Emacs instance to evaluate code. There is no overlap between them.

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

[Feature Requests](https://github.com/grettke/moshemal/issues/new/choose) and [Bug Reports](https://github.com/grettke/moshemal/issues/new/choose) are welcome.

This project intends to be a safe, welcoming space for collaboration, and contributors must adhere to [our Code of Conduct](https://github.com/grettke/moshemal/blob/master/CODE_OF_CONDUCT.md).

### Submitting content changes:

#### By Hand

- Open a [Feature Request](https://github.com/grettke/moshemal/issues/new/choose).
- Fill out the questionnaire.
- Review and discuss the request further.

#### Via Git

- Open a [Pull Request](https://github.com/grettke/moshemal/pulls).
- Await code review.

# License

- [[./LICENSE.txt][GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007]].
