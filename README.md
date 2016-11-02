# Sensu Wrapper

## Description

A very small, very crappy go binary which wraps around shell commands and sends the result to a [local sensu socket](https://sensuapp.org/docs/latest/clients#client-socket-input) as an event.

It's heavily inspired by [@solarkennedy](https://github.com/solarkennedy)'s [sensu-shell-helper](https://github.com/solarkennedy/sensu-shell-helper) but written in Go and with additional options like TTL support.

The original was in ruby, which didn't really suit the task.

The ruby version coding inspiration is from [@agent462](https://github.com/agent462)'s [sensu-cli](https://github.com/agent462/sensu-cli) so it may look familiar in certain parts.

## Usage

```shell
NAME:
   Sensu Wrapper - Execute a command and send the result to a sensu socket

USAGE:
   sensu-wrapper [global options] command [command options] [arguments...]

VERSION:
   0.1

AUTHOR(S):
   Lee Briggs

COMMANDS:
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --dry-run, -D               Output to stdout or not
   --name value, -N value      The name of the check
   --ttl value, -T value       The TTL for the check (default: 0)
   --source value, -S value    The source of the check
   --handlers value, -H value  The handlers to use for the check
   --help, -h                  show help
   --version, -v               print the version
```

#### Basic Example

The minimum required is a name and a command to run. The command isn't a flag, it will just take any arguments from the invocation.

This will send a sensu event to localhost port 3030 for sensu's local socket to process.

```shell
$ sensu-wrapper -d -n "testing" /bin/echo hello
```
You can check the output of the JSON that it will send to sensu with `--dry-run`

```shell
$ sensu-wrapper -d -n "testing" /bin/echo hello
{"name":"testing","status":0,"output":"hello\n"}
```

#### JIT Clients

If you want to send the event from a client different to the client the check is running on, use the `source` option

```shell
$ sensu-wrapper -n "name" -d -s "mynewclientname" /bin/false
{"name":"name","command":"/bin/false","status":2,"output":"false","handler":[],"source":"mynewclientname","duration":0.0}
```

#### TTL

If you need to hear from your check every so often and it hasn't called, pass the TTL option (seconds) with `-T`
Sensu will create an event if it hasn't checked within its TTL.

```shell
$ sensu-wrapper -d -n "name" -d -t 60 /bin/echo hello
{"name":"name","status":0,"output":"hello\n","ttl":60}
```

#### Timeout

By default, the commands you run will timeout after 5seconds. If you wish to adjust that, specify the timeout flag:

```shell
$ sensu-wrapper -d -n "name" -d -T 25 ping 8.8.8.8
{"name":"name","status":0,"output":"hello\n"}
```

## Building

Make sure your `$GOPATH` is set: https://github.com/golang/go/wiki/GOPATH
Grab the external dependency: 

```shell
go get gopkg.in/urfave/cli.v1
```

Build it!

```shell
go build sensu-wrapper.go
```

That's it!

## Important Notes

* This thing is designed to run arbitrary shell commands without any escaping or safety mechanisms. It's not very safe at all.
* This thing has absolutely no locking. If you need to lock commands, I suggest you use [flock(2)](http://linux.die.net/man/2/flock)
* The performance of this thing hasn't been tested at all. It's running shell commands from within golang, make of that what you will.
* This is terrible code.


## Contributing

Please sent pull requests, I am a terrible developer and anyone who can make this better will be thanked greatly.
Also, spec tests. If you fancy helping me write tests, that would also be greatly appreciated, I'm kinda new to this game.
