package main

import (
	"fmt"
	"io"
	"sort"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type viewMode int

const (
	viewToday viewMode = iota
	viewOverdue
	viewTodayOverdue
	viewAll
)

var viewOrder = []viewMode{viewToday, viewOverdue, viewTodayOverdue, viewAll}

func (v viewMode) label() string {
	switch v {
	case viewToday:
		return "Today"
	case viewOverdue:
		return "Overdue"
	case viewTodayOverdue:
		return "Today + Overdue"
	case viewAll:
		return "All"
	}
	return "?"
}

// key is the stable identifier stored in ~/.config/todo/config as
// default_view, matching the bash tool's `todo task list [overdue|today]`
// vocabulary where applicable.
func (v viewMode) key() string {
	switch v {
	case viewToday:
		return "today"
	case viewOverdue:
		return "overdue"
	case viewTodayOverdue:
		return "today_overdue"
	case viewAll:
		return "all"
	}
	return "today"
}

var modeValues = []string{"text", "tui"}

type mode int

const (
	modeBrowse mode = iota
	modeAdd
	modeConfirmDelete
	modeSettings
	modeHelp
	modeSearch
	modeReschedule
)

var (
	styleSelected = lipgloss.NewStyle().Reverse(true)
	styleOverdue  = lipgloss.NewStyle().Foreground(lipgloss.Color("1"))
	styleGood     = lipgloss.NewStyle().Foreground(lipgloss.Color("2"))
	styleBad      = lipgloss.NewStyle().Foreground(lipgloss.Color("1"))
	styleDim      = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
)

// taskItem wraps a Task for bubbles/list, precomputing its display fields.
type taskItem struct {
	task Task
}

func (i taskItem) FilterValue() string { return i.task.Content }

func prioMarker(p int) string {
	switch p {
	case 4:
		return "p1"
	case 3:
		return "p2"
	case 2:
		return "p3"
	}
	return ""
}

// fmtDue mirrors the bash tool's fmt_due: "overdue YYYY-MM-DD[ time]",
// "today[ time]", or "YYYY-MM-DD[ time]" for future dates.
func fmtDue(due *Due, today string) (text string, overdue bool) {
	if due == nil {
		return "", false
	}
	d := due.DateKey()
	var t string
	// This API puts the full timestamp in Date (no separate Datetime, no
	// timezone suffix) when a time is set — check whichever field actually
	// carries the "T" and try both a zoned and an unzoned layout.
	raw := due.Datetime
	if raw == "" {
		raw = due.Date
	}
	if strings.Contains(raw, "T") {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			t = parsed.Local().Format("3:04 PM")
		} else if parsed, err := time.Parse("2006-01-02T15:04:05", raw); err == nil {
			// No zone info means this is already the user's local wall-clock
			// time as Todoist parsed it — format as-is, don't convert.
			t = parsed.Format("3:04 PM")
		}
	}
	switch {
	case d < today:
		if t != "" {
			return fmt.Sprintf("overdue %s %s", d, t), true
		}
		return fmt.Sprintf("overdue %s", d), true
	case d == today:
		if t != "" {
			return fmt.Sprintf("today %s", t), false
		}
		return "today", false
	default:
		if t != "" {
			return fmt.Sprintf("%s %s", d, t), false
		}
		return d, false
	}
}

// itemDelegate renders one compact line per task, matching the bash tool's
// "  3. p1  content  (due)" style, with reverse video on the selected row.
// query is set/cleared by the model as searches happen (a *itemDelegate is
// shared with list.Model, so mutating it here is immediately visible).
type itemDelegate struct {
	today string
	query string

	// visual-line selection range (inclusive), set by the model while V
	// mode is active.
	selecting      bool
	selFrom, selTo int
}

func (d *itemDelegate) Height() int                            { return 1 }
func (d *itemDelegate) Spacing() int                            { return 0 }
func (d *itemDelegate) Update(_ tea.Msg, _ *list.Model) tea.Cmd { return nil }

var styleMatch = lipgloss.NewStyle().Background(lipgloss.Color("3")).Foreground(lipgloss.Color("0"))

// highlightMatches wraps every case-insensitive occurrence of query in
// content with styleMatch, nvim-search-style.
func highlightMatches(content, query string) string {
	if query == "" {
		return content
	}
	lowerContent := strings.ToLower(content)
	lowerQuery := strings.ToLower(query)
	var b strings.Builder
	i := 0
	for {
		rel := strings.Index(lowerContent[i:], lowerQuery)
		if rel < 0 {
			b.WriteString(content[i:])
			break
		}
		start := i + rel
		end := start + len(query)
		b.WriteString(content[i:start])
		b.WriteString(styleMatch.Render(content[start:end]))
		i = end
	}
	return b.String()
}

func (d *itemDelegate) Render(w io.Writer, m list.Model, index int, listItem list.Item) {
	ti, ok := listItem.(taskItem)
	if !ok {
		return
	}
	when, overdue := fmtDue(ti.task.Due, d.today)
	p := prioMarker(ti.task.Priority)
	content := highlightMatches(ti.task.Content, d.query)

	var line string
	if when != "" {
		line = fmt.Sprintf("%-3s %s  (%s)", p, content, when)
	} else {
		line = fmt.Sprintf("%-3s %s", p, content)
	}

	inRange := d.selecting && index >= d.selFrom && index <= d.selTo
	if index == m.Index() {
		fmt.Fprint(w, styleSelected.Render("> "+line))
		return
	}
	if inRange {
		fmt.Fprint(w, styleSelected.Render("* "+line))
		return
	}
	if overdue {
		prefix := fmt.Sprintf("  %-3s %s  (", p, content)
		fmt.Fprint(w, prefix+styleOverdue.Render(when)+")")
		return
	}
	fmt.Fprint(w, "  "+line)
}

type flashMsg struct {
	text string
	bad  bool
}

type tasksLoadedMsg struct {
	tasks []Task
	err   error
}

type Model struct {
	client *Client
	today  string

	list     list.Model
	delegate *itemDelegate
	viewIdx  int
	allTasks []Task
	loaded   bool

	mode      mode
	input     textinput.Model
	confirmID string
	confirmTx string

	modeIdx     int // index into modeValues, mirrors config's default_mode
	settingsRow int // 0 = default_mode, 1 = default_view

	searchQuery  string // last confirmed search, repeated by n/N
	searchOrigin int    // cursor position when '/' was pressed, for incsearch + esc-to-cancel

	visual       bool // vim-style visual line mode (V), for bulk complete/delete
	visualAnchor int
	bulkIDs      []string // pending bulk-delete ids, set when confirming from visual mode

	flash   string
	flashOK bool

	width, height int
	quitting      bool
}

func NewModel(client *Client) Model {
	today := time.Now().Format("2006-01-02")

	d := &itemDelegate{today: today}
	l := list.New(nil, d, 0, 0)
	l.SetShowTitle(false)
	l.SetShowStatusBar(false)
	l.SetShowHelp(false)
	l.SetShowPagination(false)
	l.SetFilteringEnabled(false)
	l.DisableQuitKeybindings()

	ti := textinput.New()
	ti.Placeholder = "e.g. call dentist tomorrow 3pm p1"
	ti.CharLimit = 500

	modeIdx := 0
	curMode := ConfigGet("default_mode", "text")
	for i, v := range modeValues {
		if v == curMode {
			modeIdx = i
		}
	}

	viewIdx := 0
	curView := ConfigGet("default_view", "today")
	for i, vm := range viewOrder {
		if vm.key() == curView {
			viewIdx = i
		}
	}

	return Model{
		client:   client,
		today:    today,
		list:     l,
		delegate: d,
		input:    ti,
		modeIdx:  modeIdx,
		viewIdx:  viewIdx,
	}
}

func (m Model) Init() tea.Cmd {
	return m.reload()
}

func (m Model) reload() tea.Cmd {
	return func() tea.Msg {
		tasks, err := m.client.FetchAllTasks()
		return tasksLoadedMsg{tasks: tasks, err: err}
	}
}

func matchesView(t Task, v viewMode, today string) bool {
	if v == viewAll {
		return true
	}
	if t.Due == nil {
		return false
	}
	key := t.Due.DateKey()
	switch v {
	case viewToday:
		return key == today
	case viewOverdue:
		return key < today
	case viewTodayOverdue:
		return key <= today
	}
	return false
}

func (m *Model) applyView() {
	var filtered []Task
	for _, t := range m.allTasks {
		if matchesView(t, viewOrder[m.viewIdx], m.today) {
			filtered = append(filtered, t)
		}
	}
	sort.SliceStable(filtered, func(i, j int) bool {
		return filtered[i].Due.SortKey() < filtered[j].Due.SortKey()
	})
	items := make([]list.Item, len(filtered))
	for i, t := range filtered {
		items[i] = taskItem{task: t}
	}
	m.list.SetItems(items)
	// SetItems doesn't clamp the cursor itself, so a shrinking list (an
	// item completed/deleted out from under the current selection) can
	// leave Index() pointing past the end.
	if n := len(items); n > 0 && m.list.Index() >= n {
		m.list.Select(n - 1)
	}
}

// cycleSetting advances (delta=1) or retreats (delta=-1) the value of
// whichever settings row is currently highlighted, persisting it to
// ~/.config/todo/config immediately. Changing default_view also re-applies
// it live so the effect is visible as soon as you back out of settings.
func (m *Model) cycleSetting(delta int) {
	if m.settingsRow == 0 {
		m.modeIdx = (m.modeIdx + delta + len(modeValues)) % len(modeValues)
		ConfigSet("default_mode", modeValues[m.modeIdx])
	} else {
		m.viewIdx = (m.viewIdx + delta + len(viewOrder)) % len(viewOrder)
		ConfigSet("default_view", viewOrder[m.viewIdx].key())
		m.applyView()
		m.list.Select(0)
	}
}

const footerText = "? help"

// wrapFooter splits footerText into real lines at word boundaries so it
// stays fully visible on a narrow terminal — bubbletea treats each \n
// separated string as exactly one terminal row and clips anything wider
// rather than letting the terminal auto-wrap it.
func wrapFooter(width int) []string {
	if width <= 1 {
		return []string{footerText}
	}
	words := strings.Fields(footerText)
	var lines []string
	cur := ""
	for _, w := range words {
		switch {
		case cur == "":
			cur = w
		case len(cur)+1+len(w) <= width-1:
			cur += " " + w
		default:
			lines = append(lines, " "+cur)
			cur = w
		}
	}
	if cur != "" {
		lines = append(lines, " "+cur)
	}
	if len(lines) == 0 {
		lines = []string{""}
	}
	return lines
}

func (m *Model) layout() {
	headerLines := 3
	footerLines := 1 + len(wrapFooter(m.width))
	bodyHeight := m.height - headerLines - footerLines
	if bodyHeight < 3 {
		bodyHeight = 3
	}
	m.list.SetSize(m.width, bodyHeight)
}

func (m Model) selectedTask() (Task, bool) {
	item, ok := m.list.SelectedItem().(taskItem)
	if !ok {
		return Task{}, false
	}
	return item.task, true
}

// searchIndices returns the indices (in the currently displayed/filtered
// view) of tasks whose content contains query, case-insensitively.
func (m Model) searchIndices(query string) []int {
	if query == "" {
		return nil
	}
	q := strings.ToLower(query)
	var idxs []int
	for i, it := range m.list.Items() {
		ti, ok := it.(taskItem)
		if ok && strings.Contains(strings.ToLower(ti.task.Content), q) {
			idxs = append(idxs, i)
		}
	}
	return idxs
}

// jumpToMatch moves the cursor to the next (forward) or previous (backward)
// match relative to `from`, wrapping around like nvim's / and n/N do.
// Returns false if there were no matches at all.
func (m *Model) jumpToMatch(query string, from int, forward bool) bool {
	idxs := m.searchIndices(query)
	if len(idxs) == 0 {
		return false
	}
	if forward {
		for _, i := range idxs {
			if i > from {
				m.list.Select(i)
				return true
			}
		}
		m.list.Select(idxs[0])
	} else {
		for i := len(idxs) - 1; i >= 0; i-- {
			if idxs[i] < from {
				m.list.Select(idxs[i])
				return true
			}
		}
		m.list.Select(idxs[len(idxs)-1])
	}
	return true
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {

	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.input.Width = msg.Width - 4
		m.layout()
		return m, nil

	case tasksLoadedMsg:
		m.loaded = true
		if msg.err != nil {
			m.flash, m.flashOK = "error: "+msg.err.Error(), false
			return m, nil
		}
		m.allTasks = msg.tasks
		m.applyView()
		return m, nil

	case flashMsg:
		m.flash, m.flashOK = msg.text, !msg.bad
		return m, nil

	case combinedMsg:
		m.allTasks = msg.tasks
		m.applyView()
		m.flash, m.flashOK = msg.flash, !msg.bad
		return m, nil

	case tea.KeyMsg:
		return m.handleKey(msg)
	}

	return m, nil
}

func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch m.mode {
	case modeHelp:
		m.mode = modeBrowse
		return m, nil

	case modeAdd:
		switch msg.String() {
		case "esc":
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			return m, nil
		case "enter":
			text := strings.TrimSpace(m.input.Value())
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			if text == "" {
				return m, nil
			}
			return m, m.doCreate(text)
		}
		var cmd tea.Cmd
		m.input, cmd = m.input.Update(msg)
		return m, cmd

	case modeSearch:
		switch msg.String() {
		case "esc":
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			m.list.Select(m.searchOrigin)
			return m, nil
		case "enter":
			query := strings.TrimSpace(m.input.Value())
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			if query == "" {
				m.list.Select(m.searchOrigin)
				return m, nil
			}
			m.searchQuery = query
			m.delegate.query = query
			if !m.jumpToMatch(query, m.searchOrigin, true) {
				m.flash, m.flashOK = fmt.Sprintf("no match for %q", query), false
			}
			return m, nil
		}
		var cmd tea.Cmd
		m.input, cmd = m.input.Update(msg)
		// incsearch: jump live as you type, always relative to where '/'
		// was pressed, same as nvim.
		m.delegate.query = m.input.Value()
		m.jumpToMatch(m.input.Value(), m.searchOrigin, true)
		return m, cmd

	case modeReschedule:
		switch msg.String() {
		case "esc":
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			return m, nil
		case "enter":
			text := strings.TrimSpace(m.input.Value())
			m.mode = modeBrowse
			m.input.Blur()
			m.input.SetValue("")
			if text == "" {
				return m, nil
			}
			return m, m.doReschedule(m.confirmID, m.confirmTx, text)
		}
		var cmd tea.Cmd
		m.input, cmd = m.input.Update(msg)
		return m, cmd

	case modeConfirmDelete:
		switch msg.String() {
		case "y", "Y":
			m.mode = modeBrowse
			if len(m.bulkIDs) > 0 {
				ids := m.bulkIDs
				m.bulkIDs = nil
				return m, m.doBulkDelete(ids)
			}
			id, content := m.confirmID, m.confirmTx
			return m, m.doDelete(id, content)
		default:
			m.mode = modeBrowse
			m.bulkIDs = nil
			return m, nil
		}

	case modeSettings:
		switch msg.String() {
		case "j":
			if m.settingsRow < 1 {
				m.settingsRow++
			}
		case "k":
			if m.settingsRow > 0 {
				m.settingsRow--
			}
		case "l":
			m.cycleSetting(1)
		case "h":
			m.cycleSetting(-1)
		case "esc", "q":
			m.mode = modeBrowse
		}
		return m, nil
	}

	// modeBrowse
	m.flash = ""

	// Visual line mode (V): j/k/g/G extend the selection instead of just
	// moving the cursor; c/d act on the whole range; everything else is
	// ignored, same as vim's "motions + one operator" visual mode.
	if m.visual {
		switch msg.String() {
		case "j", "k", "down", "up":
			var cmd tea.Cmd
			m.list, cmd = m.list.Update(msg)
			m.updateSelectionRange()
			return m, cmd
		case "g":
			if len(m.list.Items()) > 0 {
				m.list.Select(0)
			}
			m.updateSelectionRange()
			return m, nil
		case "G":
			if n := len(m.list.Items()); n > 0 {
				m.list.Select(n - 1)
			}
			m.updateSelectionRange()
			return m, nil
		case "c":
			ids, contents := m.selectedRange()
			m.visual = false
			m.delegate.selecting = false
			if len(ids) == 0 {
				return m, nil
			}
			return m, m.doBulkComplete(ids, contents)
		case "d":
			ids, _ := m.selectedRange()
			m.visual = false
			m.delegate.selecting = false
			if len(ids) == 0 {
				return m, nil
			}
			m.mode = modeConfirmDelete
			m.bulkIDs = ids
			return m, nil
		case "esc", "V":
			m.visual = false
			m.delegate.selecting = false
			return m, nil
		}
		return m, nil
	}

	switch msg.String() {
	case "V":
		m.visual = true
		m.visualAnchor = m.list.Index()
		m.updateSelectionRange()
		return m, nil

	case "q", "ctrl+c":
		m.quitting = true
		return m, tea.Quit

	case "h":
		m.viewIdx = (m.viewIdx - 1 + len(viewOrder)) % len(viewOrder)
		m.applyView()
		m.list.Select(0)
		return m, nil

	case "l":
		m.viewIdx = (m.viewIdx + 1) % len(viewOrder)
		m.applyView()
		m.list.Select(0)
		return m, nil

	case "g":
		if len(m.list.Items()) > 0 {
			m.list.Select(0)
		}
		return m, nil

	case "G":
		if n := len(m.list.Items()); n > 0 {
			m.list.Select(n - 1)
		}
		return m, nil

	case "r":
		return m, m.reload()

	case "?":
		m.mode = modeHelp
		return m, nil

	case "a":
		m.mode = modeAdd
		m.input.Placeholder = "e.g. call dentist tomorrow 3pm p1"
		m.input.Focus()
		return m, textinput.Blink

	case "R":
		if t, ok := m.selectedTask(); ok {
			m.mode = modeReschedule
			m.confirmID, m.confirmTx = t.ID, t.Content
			m.input.Placeholder = "e.g. tomorrow 5pm, next monday, no date"
			m.input.SetValue("")
			m.input.Focus()
			return m, textinput.Blink
		}
		return m, nil

	case "/":
		m.mode = modeSearch
		m.searchOrigin = m.list.Index()
		m.input.Placeholder = "search tasks..."
		m.input.SetValue("")
		m.input.Focus()
		return m, textinput.Blink

	case "n":
		if m.searchQuery == "" {
			m.flash, m.flashOK = "no active search — press / to search", false
			return m, nil
		}
		if !m.jumpToMatch(m.searchQuery, m.list.Index(), true) {
			m.flash, m.flashOK = fmt.Sprintf("no match for %q", m.searchQuery), false
		}
		return m, nil

	case "N":
		if m.searchQuery == "" {
			m.flash, m.flashOK = "no active search — press / to search", false
			return m, nil
		}
		if !m.jumpToMatch(m.searchQuery, m.list.Index(), false) {
			m.flash, m.flashOK = fmt.Sprintf("no match for %q", m.searchQuery), false
		}
		return m, nil

	case "S":
		m.mode = modeSettings
		m.settingsRow = 0
		return m, nil

	case "c", "enter":
		if t, ok := m.selectedTask(); ok {
			return m, m.doComplete(t.ID, t.Content)
		}
		return m, nil

	case "d":
		if t, ok := m.selectedTask(); ok {
			m.mode = modeConfirmDelete
			m.confirmID, m.confirmTx = t.ID, t.Content
		}
		return m, nil
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m Model) doComplete(id, content string) tea.Cmd {
	return func() tea.Msg {
		if err := m.client.CloseTask(id); err != nil {
			return flashMsg{text: err.Error(), bad: true}
		}
		return reloadThenFlash(m, fmt.Sprintf("completed %q", content), false)
	}
}

func (m Model) doDelete(id, content string) tea.Cmd {
	return func() tea.Msg {
		if err := m.client.DeleteTask(id); err != nil {
			return flashMsg{text: err.Error(), bad: true}
		}
		return reloadThenFlash(m, fmt.Sprintf("deleted %q", content), false)
	}
}

// updateSelectionRange recomputes the delegate's highlighted range from the
// visual-mode anchor and the current cursor position (order-independent —
// you can extend the selection either up or down from where V was pressed).
func (m *Model) updateSelectionRange() {
	if !m.visual {
		m.delegate.selecting = false
		return
	}
	from, to := m.visualAnchor, m.list.Index()
	if from > to {
		from, to = to, from
	}
	m.delegate.selecting = true
	m.delegate.selFrom, m.delegate.selTo = from, to
}

// selectedRange returns the ids/contents of tasks within the current visual
// selection range.
func (m Model) selectedRange() (ids, contents []string) {
	if !m.delegate.selecting {
		return nil, nil
	}
	items := m.list.Items()
	for i := m.delegate.selFrom; i <= m.delegate.selTo && i < len(items); i++ {
		if ti, ok := items[i].(taskItem); ok {
			ids = append(ids, ti.task.ID)
			contents = append(contents, ti.task.Content)
		}
	}
	return
}

func (m Model) doBulkComplete(ids, contents []string) tea.Cmd {
	return func() tea.Msg {
		failed := 0
		for _, id := range ids {
			if err := m.client.CloseTask(id); err != nil {
				failed++
			}
		}
		label := fmt.Sprintf("completed %d task(s)", len(ids)-failed)
		if failed > 0 {
			label += fmt.Sprintf(" (%d failed)", failed)
		}
		return reloadThenFlash(m, label, failed > 0)
	}
}

func (m Model) doBulkDelete(ids []string) tea.Cmd {
	return func() tea.Msg {
		failed := 0
		for _, id := range ids {
			if err := m.client.DeleteTask(id); err != nil {
				failed++
			}
		}
		label := fmt.Sprintf("deleted %d task(s)", len(ids)-failed)
		if failed > 0 {
			label += fmt.Sprintf(" (%d failed)", failed)
		}
		return reloadThenFlash(m, label, failed > 0)
	}
}

func (m Model) doCreate(text string) tea.Cmd {
	return func() tea.Msg {
		t, err := m.client.QuickAdd(text)
		if err != nil {
			return flashMsg{text: err.Error(), bad: true}
		}
		when, _ := fmtDue(t.Due, m.today)
		if when == "" {
			when = "no due date"
		}
		return reloadThenFlash(m, fmt.Sprintf("created %q  (%s)", t.Content, when), false)
	}
}

func (m Model) doReschedule(id, content, dueText string) tea.Cmd {
	return func() tea.Msg {
		t, err := m.client.Reschedule(id, dueText)
		if err != nil {
			return flashMsg{text: err.Error(), bad: true}
		}
		when, _ := fmtDue(t.Due, m.today)
		if when == "" {
			when = "no due date"
		}
		return reloadThenFlash(m, fmt.Sprintf("rescheduled %q  (%s)", content, when), false)
	}
}

// reloadThenFlash re-fetches tasks synchronously (we're already off the UI
// goroutine inside a tea.Cmd) and returns a single message so the flash and
// the refreshed list land in the same Update cycle.
func reloadThenFlash(m Model, text string, bad bool) tea.Msg {
	tasks, err := m.client.FetchAllTasks()
	if err != nil {
		return flashMsg{text: err.Error(), bad: true}
	}
	return combinedMsg{tasks: tasks, flash: text, bad: bad}
}

type combinedMsg struct {
	tasks []Task
	flash string
	bad   bool
}

func (m Model) View() string {
	if m.quitting {
		return ""
	}
	if !m.loaded {
		return "loading...\n"
	}

	sep := strings.Repeat("-", max(m.width, 1))
	total := len(m.list.Items())
	cursor := m.list.Index() + 1
	if total == 0 {
		cursor = 0
	}
	header := fmt.Sprintf(" todo * %s * %s%*s[%d/%d]",
		viewOrder[m.viewIdx].label(), m.today, 10, "", cursor, total)
	if m.visual {
		n := m.delegate.selTo - m.delegate.selFrom + 1
		header += fmt.Sprintf("  -- VISUAL -- %d selected", n)
	}

	var body string
	switch m.mode {
	case modeHelp:
		body = helpText()
	case modeSettings:
		body = m.settingsText()
	default:
		if total == 0 {
			body = "  (nothing here)"
		} else {
			body = m.list.View()
		}
	}

	footer := strings.Join(wrapFooter(max(m.width, 1)), "\n")

	var overlay string
	switch m.mode {
	case modeAdd:
		overlay = "\n New task: " + m.input.View()
	case modeSearch:
		overlay = "\n /" + m.input.View()
	case modeReschedule:
		overlay = fmt.Sprintf("\n Reschedule %q: %s", m.confirmTx, m.input.View())
	case modeConfirmDelete:
		if len(m.bulkIDs) > 0 {
			overlay = fmt.Sprintf("\n %s (y/n)", styleBad.Render(fmt.Sprintf("Delete %d selected tasks?", len(m.bulkIDs))))
		} else {
			overlay = fmt.Sprintf("\n %s (y/n)", styleBad.Render(fmt.Sprintf("Delete %q?", m.confirmTx)))
		}
	}

	if m.flash != "" {
		style := styleGood
		if !m.flashOK {
			style = styleBad
		}
		overlay = "\n " + style.Render(m.flash)
	}

	return strings.Join([]string{sep, header, sep, body, sep, footer}, "\n") + overlay
}

func helpText() string {
	return strings.Join([]string{
		"",
		"  todo - keybindings",
		"",
		"  j / k        move down / up",
		"  g / G        jump to top / bottom",
		"  h / l        previous / next view",
		"  /            search (incremental, like nvim); enter confirms, esc cancels",
		"  n / N        repeat search forward / backward",
		"  enter, c     complete selected task",
		"  d            delete selected task (confirms first)",
		"  R            reschedule selected task (natural language, e.g. 'tomorrow 5pm')",
		"  V            visual line select; j/k/g/G extend, c/d act on all, esc cancels",
		"  a            add a new task",
		"  r            refresh current view",
		"  S            settings (default_mode, default_view)",
		"  ?            this help",
		"  q            quit",
		"",
		"  press any key to go back",
	}, "\n")
}

func (m Model) settingsText() string {
	modeCursor, viewCursor := " ", " "
	if m.settingsRow == 0 {
		modeCursor = ">"
	} else {
		viewCursor = ">"
	}
	return strings.Join([]string{
		"",
		"  todo - settings",
		"",
		fmt.Sprintf("%s default_mode   < %s >", modeCursor, modeValues[m.modeIdx]),
		fmt.Sprintf("%s default_view   < %s >", viewCursor, viewOrder[m.viewIdx].label()),
		"",
		"  j/k select row   h/l change value   esc back",
	}, "\n")
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
