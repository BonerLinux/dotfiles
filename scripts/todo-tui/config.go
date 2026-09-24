package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func configPath() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".config", "todo", "config"), nil
}

// ConfigGet reads a single key from ~/.config/todo/config, matching the
// bash tool's plain KEY=value format so both stay interoperable.
func ConfigGet(key, fallback string) string {
	path, err := configPath()
	if err != nil {
		return fallback
	}
	f, err := os.Open(path)
	if err != nil {
		return fallback
	}
	defer f.Close()

	val := fallback
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		if idx := strings.IndexByte(line, '='); idx > 0 {
			if line[:idx] == key {
				val = line[idx+1:]
			}
		}
	}
	return val
}

// ConfigSet updates key=value in place, or appends it if absent.
func ConfigSet(key, value string) error {
	path, err := configPath()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}

	var lines []string
	found := false
	if f, err := os.Open(path); err == nil {
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := scanner.Text()
			if idx := strings.IndexByte(line, '='); idx > 0 && line[:idx] == key {
				lines = append(lines, fmt.Sprintf("%s=%s", key, value))
				found = true
			} else {
				lines = append(lines, line)
			}
		}
		f.Close()
	}
	if !found {
		lines = append(lines, fmt.Sprintf("%s=%s", key, value))
	}

	return os.WriteFile(path, []byte(strings.Join(lines, "\n")+"\n"), 0o644)
}
