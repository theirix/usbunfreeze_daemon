# UsbunfreezeDaemon

[![Gem Version](https://img.shields.io/gem/v/usbunfreeze_daemon.svg)](https://rubygems.org/gems/usbunfreeze_daemon)

Daemon application for Usbunfreeze kit.

## Installation

Install a gem

        gem install usbunfreeze_daemon

## Configuration

Settings file template can be found at `config/usbunfreeze.yaml.example`.

Configure Amazon AWS SQS queue and place access, secret key and queue name to the config.

## Usage

Launch a daemon:

    usbunfreeze_daemon -с /path/to/settings.yaml start

Daemon will poll AWS SQS queue and launch specified command when a message will be received.

Possible flags:

 * `--directory PATH` -- use `PATH` for logs and pids. Used usually for non-system installation
 * `--system` -- use `/var/log` for logging and `/var/run` for pid storing. `-d` is not needed with this flag.s
 * `--ontop` -- do not fork into daemon
 * `start|stop|status` -- self-describing control commands

## License information

Please consult with the LICENSE.txt for license information. It is MIT by the way.
