# Sensu Wrapper

## Description

A very small, very crappy ruby script which wraps around shell commands and sends the result to a [local sensu socket](https://sensuapp.org/docs/latest/clients#client-socket-input) as an event.

It's heavily inspired by [@solarkennedy](https://github.com/solarkennedy)'s [sensu-shell-helper](https://github.com/solarkennedy/sensu-shell-helper) but written in ruby and with additional options like TTL support.

A lot of the coding inspiration is from [@agent462](https://github.com/agent462)'s [sensu-cli](https://github.com/agent462/sensu-cli) so it may look familiar in certain parts.

## Usage

```shell
Usage:
  -n, --name=<s>       Name of check
  -c, --command=<s>    The command to run
  -d, --dry-run        Output to stdout
  -H, --handler=<s>    Which handlers to use on the event
  -T, --ttl=<i>        How often should we hear from this check
  -s, --source=<s>     Where should this check come from?
  -e, --extra=<s>      Extra fields you'd like to include in the form of ruby hash mappings
  -N, --nagios         Nagios compliant
  -t, --timeout=<i>    Timeout command execution after number of s
  -v, --version        Print version and exit
  -h, --help           Show this message
```

## Examples

If you just want to create a standard sensu check on a client, the basic invocation is:

#### Basic Example

The minimum required is a name and a command to run. This will send a sensu event to localhost port 3030 for sensu's local socket to process.

```shell
$ sensu-wrapper -n "testing" -c "/bin/echo \'hello\'" -d
```
You can check the output of the JSON that it will send to sensu with `--dry-run`

```shell
$ sensu-wrapper -n "testing" -c "/bin/echo \'hello\'" -d
{"name":"testing","command":"/bin/echo \\'hello\\'","status":0,"output":"'hello'\n","handler":[],"duration":0.0}
```

#### Nagios Compliant

If your command returns nagios compliant exit codes (ie a 1,2 or 3) you can pass the `-N` option

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d -N
{"name":"testing","command":"/bin/echo false","status":1,"output":"command returned no stdout","handler":[],"duration":0.0}
```

#### JIT Clients

If you want to send the event from a client different to the client the check is running on, use the `source` option

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d -s "mynewclientname"
{"name":"name","command":"/bin/false","status":2,"output":"false","handler":[],"source":"mynewclientname","duration":0.0}
```

#### Timeout

If you want to make your command stop after X amount of time, you can specify a timeout using `-t`

```shell
$ sensu-wrapper -n "name" -c "/bin/sleep 10" -d -t 5
{"name":"testing","command":"/bin/sleep 10","status":2,"output":"command timed out","handler":[],"timeout":5,"duration":5.01}

```

**Warning: This is pretty hacky in ruby. If you want reliable timeouts, you should put them in your script**

_Massive thanks to [this gist](https://gist.github.com/pasela/9392115) from [@pasela](https://github.com/pasela) for the implementation_

#### TTL

If you need to hear from your check every so often and it hasn't called, pass the TTL option (seconds) with `-T`
Sensu will create an event if it hasn't checked within its TTL.

```shell
$ sensu-wrapper -n "name" -c "/bin/sleep 10" -d -T 60 -t 2
{"name":"name","command":"/bin/sleep 10","status":2,"output":"command timed out","handler":[],"ttl":60,"timeout":2,"duration":2.0}
```

#### Custom JSON

Finally, if your sensu environment has special required fields, you can pass extra fields using the `-e` option in the form of a ruby hash mapping. These will get appended to your final check value. Be sure to wrap the whole hash map in quotation marks

```shell
$ sensu-wrapper -n "name" -c "/bin/sleep 1" -d -N -e "'extra_field' => 'value'" -e "'extra_field_2' => 'value'"
{"name":"name","command":"/bin/sleep 1","status":0,"output":"command returned to stdout","handler":[],"duration":1.01,"extra_field":"value","extra_field_2":"value"}
```

## Installation

I haven't published this to rubygems yet, because it's pretty shitty and I'm basically embarrased by it. However, if you're a sucker for punishment and want to give it a try, you can simply copy the file in the `bin/` directory to a place of your choice. The only dependency is the [trollop gem](https://rubygems.org/gems/trollop/versions/2.1.2)

You can also of course install directly from the gemspec:

```shell
gem build sensu-wrapper.gemspec
gem install sensu-wrapper-0.0.1.gem
```

Once I add some modules and make it decent, I'll ship it to rubygems.

## Important Notes

* This thing is designed to run arbitrary shell commands without any escaping or safety mechanisms. It's not very safe at all.
* This thing has absolutely no locking. If you need to lock commands, I suggest you use [flock(2)](http://linux.die.net/man/2/flock)
* The timeouts aren't reliable. If you want reliable timeout, I suggest you wrap your commands in a script and use [timeout(1)](http://linux.die.net/man/1/timeout)
* The performance of this thing hasn't been tested at all. It's running shell commands from within ruby, make of that what you will.
* This is terrible code.


## Contributing

Please sent pull requests, I am a terrible developer and anyone who can make this better will be thanked greatly.
Also, spec tests. If you fancy helping me write tests, that would also be greatly appreciated, I'm kinda new to this game.
