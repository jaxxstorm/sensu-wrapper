package command

import (
	"bytes"
	"log"
	"os/exec"
	"syscall"
	"time"
)

func RunCommand(cmdName string, cmdArgs []string, timeout int) (int, string) {

	// the command we're going to run
	cmd := exec.Command(cmdName, cmdArgs...)

	// assign vars for output and stderr
	var output bytes.Buffer
	var stderr bytes.Buffer

	var combined string

	// get the stdout and stderr and assign to pointers
	cmd.Stderr = &stderr
	cmd.Stdout = &output

	// Start the command
	if err := cmd.Start(); err != nil {
		log.Fatalf("Command not found: %s", cmdName)
	}

	timer := time.AfterFunc(time.Second*time.Duration(timeout), func() {
		// if timeout is set, kill the process
		if timeout > 0 {
			err := cmd.Process.Kill()
			if err != nil {
				panic(err)
			}
		}
	})

	// Here's the good stuff
	if err := cmd.Wait(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			// Command ! exit 0, capture it
			if status, ok := exiterr.Sys().(syscall.WaitStatus); ok {
				// Check it's nagios compliant
				if status.ExitStatus() == 1 || status.ExitStatus() == 2 || status.ExitStatus() == 3 {
					combined = stderr.String() + output.String()
					return status.ExitStatus(), combined
				} else {
					// If not, force an exit code 2
					combined = stderr.String() + output.String()
					return 2, combined
				}
			}
		} else {
			log.Fatalf("cmd.Wait: %v", err)
		}
		timer.Stop()
	}
	// We didn't get captured, continue!
	return 0, output.String()

}
