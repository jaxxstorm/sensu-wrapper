package main

import (
	"encoding/json"
	"fmt"
	"github.com/jaxxstorm/sensu-wrapper/api"
	"github.com/jaxxstorm/sensu-wrapper/command"
	"gopkg.in/urfave/cli.v1"
	"io/ioutil"
	"net"
	"os"
	"strings"
)

func main() {

	type Output struct {
		Name     string   `json:"name"`
		Command  string   `json:"command"`
		Status   int      `json:"status"`
		Output   string   `json:"output"`
		Ttl      int      `json:"ttl,omitempty"`
		Source   string   `json:"source,omitempty"`
		Handlers []string `json:"handlers,omitempty"`
	}

	app := cli.NewApp()

	app.Flags = []cli.Flag{
		cli.BoolFlag{Name: "dry-run, D, d", Usage: "Output to stdout or not"},
		cli.StringFlag{Name: "name, N, n", Usage: "The name of the check"},
		cli.IntFlag{Name: "ttl, t", Usage: "The TTL for the check"},
		cli.IntFlag{Name: "timeout, T", Usage: "Amount of time before the command times out"},
		cli.StringFlag{Name: "source, S, s", Usage: "The source of the check"},
		cli.StringSliceFlag{Name: "handlers, H", Usage: "The handlers to use for the check"},
		cli.StringFlag{Name: "json-file, f", Usage: "JSON file to read and add to output"},
		cli.StringFlag{Name: "json, j", Usage: "JSON string to add to output"},
		cli.StringFlag{Name: "api-url, a", Usage: "Send the result to the Sensu API"},
		cli.IntFlag{Name: "api-port", Usage: "Port for the sensu API", Value: 4567},
		cli.BoolFlag{Name: "api-tls", Usage: "Whether to use TLS for calls to API"},
		cli.StringFlag{Name: "api-username, u", Usage: "Username for Sensu API"},
		cli.StringFlag{Name: "api-password, p", Usage: "Password for Sensu API", EnvVar: "SENSU_API_PASSWORD,SENSU_PASSWORD"},
	}

	app.Name = "Sensu Wrapper"
	app.Version = "0.3.3"
	app.Usage = "Execute a command and send the result to a sensu socket"
	app.Authors = []cli.Author{
		cli.Author{
			Name: "Lee Briggs",
		},
	}
	app.Action = func(c *cli.Context) error {

		if !c.IsSet("name") {
			cli.ShowAppHelp(c)
			return cli.NewExitError("Error: No check name specified", -1)
		}

		if !c.Args().Present() {
			cli.ShowAppHelp(c)
			return cli.NewExitError("Error: Must pass a command to run", -1)
		}

		// runs the command args
		// timeout is 0 if not set
		status, output := command.RunCommand(c.Args().First(), c.Args().Tail(), c.Int("timeout"))

		sensu_values := &Output{
			Name:     c.String("name"),
			Command:  strings.Join(c.Args(), " "),
			Status:   status,
			Output:   output,
			Ttl:      c.Int("ttl"),
			Source:   c.String("source"),
			Handlers: c.StringSlice("handlers"),
		}

		// declare a slice to write JSON to
		var output_json []byte

		if !c.IsSet("json-file") && !c.IsSet("json") {
			// We don't need to add extra values, just marshal the original struct
			output_json, _ = json.Marshal(sensu_values)
		} else {
			// create to unmarshal JSON
			values := map[string]interface{}{}

			if c.IsSet("json-file") {
				additional_json, err := ioutil.ReadFile(c.String("json-file"))
				// check for file errors
				if err != nil {
					panic(err)
				}
				
				if err := json.Unmarshal([]byte(additional_json), &values); err != nil {
					return cli.NewExitError("Invalid JSON in"+c.String("json-file"), -1)
				}
			} else {
				additional_json := c.String("json")
				
				if err := json.Unmarshal([]byte(additional_json), &values); err != nil {
					return cli.NewExitError("Invalid JSON in"+c.String("json"), -1)
				}
			}
			// append the values from sensu_values struct
			values["name"] = sensu_values.Name
			values["command"] = sensu_values.Command
			values["status"] = sensu_values.Status
			values["output"] = sensu_values.Output
			if sensu_values.Ttl != 0 {
				values["ttl"] = sensu_values.Ttl
			}
			if sensu_values.Source != "" {
				values["source"] = sensu_values.Source
			}
			if len(sensu_values.Handlers) != 0 {
				values["handlers"] = sensu_values.Handlers
			}
			// marshal final values into JSON
			output_json, _ = json.Marshal(values)
		}

		if c.Bool("dry-run") {
			fmt.Println(string(output_json))
			return nil
		} else if c.IsSet("api-url") {

			code, result, http_status := api.SendResult(c.Bool("api-tls"), c.String("api-url"), c.Int("api-port"), string(output_json), c.String("api-username"), c.String("api-password"))
			if code == 202 {
				fmt.Println(result)
				return nil
			} else {
				fmt.Println("Error sending result to Sensu API:", http_status)
				return nil
			}
		} else {
			conn, err := net.Dial("udp", "127.0.0.1:3030")
			if err != nil {
				return cli.NewExitError("Problem sending JSON to socket", 3)
			} else {
				fmt.Fprintf(conn, string(output_json))
				return nil
			}
		}
	}

	app.Run(os.Args)
}