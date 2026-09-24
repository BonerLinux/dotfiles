package main

import (
	"fmt"
	"os"
	"path/filepath"

	tea "github.com/charmbracelet/bubbletea"
)

func run() error {
	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}
	tokenPath := filepath.Join(home, ".secrets", "todoist")
	token, err := ReadToken(tokenPath)
	if err != nil {
		return fmt.Errorf("no token at %s (echo YOUR_TOKEN > %s && chmod 600 %s)", tokenPath, tokenPath, tokenPath)
	}

	client := NewClient(token)
	m := NewModel(client)

	p := tea.NewProgram(m, tea.WithAltScreen())
	_, err = p.Run()
	return err
}
