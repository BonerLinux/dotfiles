package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

const apiBase = "https://api.todoist.com/api/v1"

type Due struct {
	Date     string `json:"date"`
	Datetime string `json:"datetime"`
}

// DateKey is the plain YYYY-MM-DD this task is due on, regardless of
// whether it carries a specific time.
func (d *Due) DateKey() string {
	if d == nil {
		return ""
	}
	// This API puts the full timestamp in Date itself when a time is set
	// (Datetime is left empty) — always take just the first 10 chars so
	// callers get a plain YYYY-MM-DD regardless of which field it came from.
	if d.Date != "" {
		if len(d.Date) >= 10 {
			return d.Date[:10]
		}
		return d.Date
	}
	if len(d.Datetime) >= 10 {
		return d.Datetime[:10]
	}
	return ""
}

// SortKey is the full due value (datetime when present, else date), used
// for chronological ordering within a day.
func (d *Due) SortKey() string {
	if d == nil {
		return ""
	}
	if d.Datetime != "" {
		return d.Datetime
	}
	return d.Date
}

type Task struct {
	ID       string `json:"id"`
	Content  string `json:"content"`
	Priority int    `json:"priority"`
	Due      *Due   `json:"due"`
}

type tasksPage struct {
	Results    []Task `json:"results"`
	NextCursor string `json:"next_cursor"`
}

type Client struct {
	token string
	http  *http.Client
}

func NewClient(token string) *Client {
	return &Client{token: token, http: &http.Client{Timeout: 20 * time.Second}}
}

func (c *Client) authedRequest(method, rawURL string, body io.Reader) (*http.Response, error) {
	req, err := http.NewRequest(method, rawURL, body)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	if method == http.MethodPost {
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	}
	return c.http.Do(req)
}

// FetchAllTasks pulls every active task. The `filter` query param on this
// endpoint is not honored by the API (confirmed empirically: filter=overdue
// returns the same unfiltered list as no filter), so we always fetch
// everything and filter/sort client-side. limit=200 keeps this to a single
// request for any reasonably sized task list.
func (c *Client) FetchAllTasks() ([]Task, error) {
	var all []Task
	cursor := ""
	for {
		u := fmt.Sprintf("%s/tasks?limit=200", apiBase)
		if cursor != "" {
			u += "&cursor=" + url.QueryEscape(cursor)
		}
		resp, err := c.authedRequest(http.MethodGet, u, nil)
		if err != nil {
			return nil, err
		}
		var page tasksPage
		err = json.NewDecoder(resp.Body).Decode(&page)
		resp.Body.Close()
		if err != nil {
			return nil, err
		}
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return nil, fmt.Errorf("GET /tasks failed (HTTP %d)", resp.StatusCode)
		}
		all = append(all, page.Results...)
		if page.NextCursor == "" {
			break
		}
		cursor = page.NextCursor
	}
	return all, nil
}

func (c *Client) CloseTask(id string) error {
	u := fmt.Sprintf("%s/tasks/%s/close", apiBase, url.PathEscape(id))
	resp, err := c.authedRequest(http.MethodPost, u, nil)
	if err != nil {
		return err
	}
	resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("complete failed (HTTP %d)", resp.StatusCode)
	}
	return nil
}

func (c *Client) DeleteTask(id string) error {
	u := fmt.Sprintf("%s/tasks/%s", apiBase, url.PathEscape(id))
	resp, err := c.authedRequest(http.MethodDelete, u, nil)
	if err != nil {
		return err
	}
	resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("delete failed (HTTP %d)", resp.StatusCode)
	}
	return nil
}

// QuickAdd creates a task via Todoist's natural-language quick-add endpoint
// (parses due dates, #project, @label, p1-p4 priority out of the text).
func (c *Client) QuickAdd(text string) (*Task, error) {
	u := fmt.Sprintf("%s/tasks/quick", apiBase)
	body := "text=" + url.QueryEscape(text)
	resp, err := c.authedRequest(http.MethodPost, u, strings.NewReader(body))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("create failed (HTTP %d)", resp.StatusCode)
	}
	var t Task
	if err := json.NewDecoder(resp.Body).Decode(&t); err != nil {
		return nil, err
	}
	return &t, nil
}

// Reschedule updates a task's due date via natural-language text (e.g.
// "tomorrow 5pm"), returning the updated task. Unlike the other write
// endpoints this one takes a JSON body, not form-encoded.
func (c *Client) Reschedule(id, dueText string) (*Task, error) {
	u := fmt.Sprintf("%s/tasks/%s", apiBase, url.PathEscape(id))
	payload, err := json.Marshal(map[string]string{"due_string": dueText})
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequest(http.MethodPost, u, bytes.NewReader(payload))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+c.token)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("reschedule failed (HTTP %d)", resp.StatusCode)
	}
	var t Task
	if err := json.NewDecoder(resp.Body).Decode(&t); err != nil {
		return nil, err
	}
	return &t, nil
}

func ReadToken(path string) (string, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(b)), nil
}
