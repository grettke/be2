<p align="center">
<h1 align="center">MOre baSH EMacs evAL</h1>
<p align="center">Evaluate single-line Elisp expressions on a running local Emacs instance.</p>
</p>

## Usage

This script helps you evaluate a single-line Elisp expression on a running local Emacs instance.

## Setup

Caffeinate yourself and follow the steps: it will all make sense when you are finished.

Please read about how to [use](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html) Emacs as a server: it lets you connect to it and evaluate code.

Specify a full-qualified file in your home directory to acts as your server-socket:

``` bash
export EMACSSOCKET="/Users/gcr/server-sockets/emacs.sock"
```

Configure the socket:

``` bash
mkdir ~/server-sockets/
cd ~/server-sockets/
touch emacs.sock
chmod 700 emacs.sock
```

Configure Emacs to start it's server on the socket:

``` emacs-lisp
(setq server-name (getenv "EMACSSOCKET"))
(server-start)
```

Either evaluate that or restart Emacs.

Verify the socket file exists with the correct permissions.

Check out the code:

``` bash
cd ~/src
git clone git@github.com:grettke/moshemal.git
```

Load it in your init file:

``` bash
source "/Users/gcr/src/moshemal/moshemal.sh"
```

Create a new shell and Emacs instance to check for startup errors. Fix any. Evaluate some code from the command line on a running Emacs instance:

``` bash
moshemal "(corporate-bs-generator-make)"
```

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
