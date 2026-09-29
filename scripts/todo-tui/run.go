package main

import (
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
)

const tokenPath = "/run/agenix/todoist-token"

func run() error {
	token, err := ReadToken(tokenPath)
	if err != nil {
		return fmt.Errorf("no token at %s (edit nixos/secrets/todoist-token.age with agenix, then rebuild)", tokenPath)
	}

	client := NewClient(token)
	m := NewModel(client)

	p := tea.NewProgram(m, tea.WithAltScreen())
	_, err = p.Run()
	return err
}
