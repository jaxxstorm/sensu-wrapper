# Sensu Wrapper

## Description

A very small, very crappy ruby script which wraps around shell commands and sends the result to a [local sensu socket](https://sensuapp.org/docs/latest/clients#client-socket-input) as an event.

It's heavily inspired by [@solarkennedy](https://github.com/solarkennedy)'s [sensu-shell-helper](https://github.com/solarkennedy/sensu-shell-helper) but written in ruby and with additional options like TTL support

## Usage

```shell
Usage:
  -n, --name=<s>       Name of check
  -c, --command=<s>    The command to run
  -d, --dry-run        Output to stdout
  -H, --handler=<s>    Which handlers to use on the event
  -t, --ttl=<i>        How often should we hear from this check
  -s, --source=<s>     Where should this check come from?
  -e, --extra=<s>      Extra fields you'd like to include in the form of ruby hash mappings
  -N, --nagios         Nagios compliant
  -v, --version        Print version and exit
  -h, --help           Show this message
```

## Examples

If you just want to create a standard sensu check on a client, the basic invocation is:

```shell
$ sensu-wrapper -n "name" -c "/bin/false"
```

You can check the output of the JSON that it will send to sensu with `--dry-run`

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d
{"name":"name","command":"/bin/false","status":2,"output":"false","handler":[],"ttl":null,"source":null}
```

If your command returns nagios compliant exit codes (ie a 1,2 or 3) you can pass the `-N` option

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d -N
{"name":"name","command":"/bin/false","status":1,"output":"false","handler":[],"ttl":null,"source":null}
```

If you want to send the event from a client different to the client the check is running on, use the `source` option

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d -s "mynewclientname"
{"name":"name","command":"/bin/false","status":2,"output":"false","handler":[],"ttl":null,"source":"mynewclientname"}
```

Finally, if your sensu environment has special required fields, you can pass extra fields using the `-e` option in the form of a ruby hash mapping. These will get appended to your final check value. Be sure to wrap the whole hash map in quotation marks

```shell
$ sensu-wrapper -n "name" -c "/bin/false" -d -N -e "'extra_field' => 'value'" -e "'extra_field_2' => 'value'"
{"name":"name","command":"/bin/false","status":1,"output":"false","handler":[],"ttl":null,"source":null,"extra_field":"value","extra_field_2":"value"}
```

## Installation

I haven't published this to rubygems yet, because it's pretty shitty and I'm basically embarrased by it. However, if you're a sucker for punishment and want to give it a try, you can simply copy the file in the `bin/` directory to a place of your choice. The only dependency is the [trollop gem](https://rubygems.org/gems/trollop/versions/2.1.2)

You can also of course install directly from the gemspec:

```shell
gem build sensu-wrapper.gemspec
gem install sensu-wrapper-0.0.1.gem
```

Once I add some modules and make it decent, I'll ship it to rubygems.

## Contributing

Please sent pull requests, I am a terrible developer and anyone who can make this better will be thanked greatly. 
