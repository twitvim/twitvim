# TwitVim - Twitter client for Vim

## Introduction

TwitVim is a Vim plugin that allows you to post to Twitter and view Twitter
timelines. It is an enhancement of [vimscript #2124](http://www.vim.org/scripts/script.php?script\_id=2124)
by Travis Jeffery. Credit goes to Travis for the original script concept and implementation.

TwitVim supports most of the features of a typical Twitter client, including:

- Friends, User, Direct Message, Mentions, and Favorites timelines
- Twitter Search
- Replying and retweeting
- Hashtags (jump to search timeline)
- In reply to (See which tweet an @-reply is for.)
- Opening links in a browser
- User profile display
- Twitter List viewing and managing
- Trending topics
- Timeline filtering

## Prerequisites

TwitVim uses [cURL](http://curl.haxx.se/) to communicate with Twitter.
Alternatively, you can configure TwitVim to use Vim's Perl, Python, Ruby, or
Tcl interfaces for faster network I/O.

Twitter OAuth requires either the [OpenSSL](http://www.openssl.org/)
software or a Vim binary compiled with Perl, Python, Ruby, or Tcl.

Some platforms already have cURL and OpenSSL preinstalled or have
installation packages for those, so that is the easier way to satisfy the
prerequisites.

## Installation

Use one of the methods below, depending on which plugin manager (or not)
you have. After installation, see ```:help TwitVim-install``` for
further instructions.

### Pathogen

Use the following commands:

    cd ~/.vim/bundle
    git clone https://github.com/twitvim/twitvim.git

### Vundle

Add the following to your vimrc:

    Plugin 'https://github.com/twitvim/twitvim.git'

Install with ```:PluginInstall```.

### Vimball file

Open the vmb file and then source it.

    vim twitvim-0.9.1.vmb
    :so %

## Usage

### Plugin commands

- :PosttoTwitter - This command will prompt you for a message to send to Twitter.
- :CPosttoTwitter - This command posts the current line in the current buffer
  to Twitter.
- :BPosttoTwitter - This command posts the current buffer to Twitter.
- :FriendsTwitter - View friends timeline.
- :UserTwitter - View your timeline.
- :MentionsTwitter - View @-mentions.
- :PublicTwitter - View public timeline.
- :DMTwitter - View direct messages.
- :SearchTwitter - Use Twitter Search.

### Global mappings

- Alt-T - In Visual select mode, the Alt-T key posts the selected text to
  Twitter. Use this mapping if you compose your tweets in a separate
  scratch buffer.
- Ctrl-T - Use this instead if the menu bar is enabled or if Alt-T is not
  available on your platform.

### Timeline buffer mappings

- Alt-R or <Leader\>r - Starts a @-reply. (in timeline buffer)
- Alt-D or <Leader\>d - Starts a direct message. (in timeline buffer)

Many more commands and mappings are available.
See TwitVim's help documentation for full details.

## License

TwitVim is distributed under the same terms as Vim itself.
See ```:help license```.

## Contact

- [@mortonfox](https://twitter.com/mortonfox) - The maintainer
- [@twitvim](https://twitter.com/twitvim) - TwitVim announcements
