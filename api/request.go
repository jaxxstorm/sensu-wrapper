package api

import (
	"github.com/parnurzeal/gorequest"
	"strconv"
)

func SendResult(tls bool, url string, port int, json string, username string, password string) (statusCode int, body string, status string) {

	// set up a new request
	request := gorequest.New()

	if username != "" && password != "" {
		request.SetBasicAuth(username, password)
	}

	var prefix string

	if tls {
		prefix = "https://"
	} else {
		prefix = "http://"
	}
	dest := prefix + url + ":" + strconv.Itoa(port)
	// set up the url to post to
	resp, body, _ := request.Post(dest + "/results").
		Send(json).
		End()

	return resp.StatusCode, body, resp.Status
}
