package api

import "github.com/parnurzeal/gorequest"

func SendResult(url string, json string, username string, password string) (statusCode int, body string, status string) {

	// set up a new request
	request := gorequest.New()

	if username != "" && password != "" {
		request.SetBasicAuth(username, password)
	}

	// set up the url to post to
	resp, body, _ := request.Post(url).
		Send(json).
		End()

	return resp.StatusCode, body, resp.Status
}
