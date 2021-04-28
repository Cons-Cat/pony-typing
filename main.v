module main

import term
import term.ui as tui
import io
import os
import rand

struct App {
mut:
	tui    &tui.Context = 0
	prompt &Prompt
}

fn event(e &tui.Event, mut app App) {
	// mut app := &App(x)
	println(e)
	match e.typ {
		.key_down {
			match e.code {
				.escape {
					exit(0)
				}
				32...126 { // 0-9a-zA-Z
					app.prompt.input(e.ascii, app.prompt.cursor_line, app.prompt.cursor_column)
				}
            .backspace {
					app.prompt.backspace(app.prompt.cursor_line, app.prompt.cursor_column)
            }
				else {}
			}
		}
		else {}
	}
}

fn main() {
	mut t_lines := load_dict(os.dir(os.executable()) + '/words', 100)
	paragaph := random_paragraph(t_lines, 10)
	mut app := &App{
		prompt: &Prompt(Quote{
			lines: paragaph
		})
	}
	app.tui = tui.init(
		user_data: app
		event_fn: event
		frame_fn: frame
		hide_cursor: false
		frame_rate: 60
	)
	app.tui.run() ?
}

fn frame(mut app App) {
	width, height := term.get_terminal_size()

	app.tui.clear()

	for i, line in app.prompt.lines {
		line.print(width / 2, height / 2 + i, mut app)
	}

	app.tui.reset()
	app.tui.flush()

	term.set_cursor_position(term.Coord{
		width / 2 - app.prompt.lines[app.prompt.cursor_line].len / 2 + app.prompt.cursor_column,
		height / 2 + app.prompt.cursor_line})
	term.show_cursor()
}

fn load_dict(file string, cap int) []string {
	mut lines := []string{}
	mut f := os.open(file) or { panic(err) }
	defer {
		f.close()
	}
	mut r := io.new_buffered_reader(reader: io.make_reader(f), cap: cap)
	for {
		l := r.read_line() or { break }
		lines << l
	}
	return lines
}

fn random_paragraph(dict []string, word_count u32) []LineBuffer {
	mut paragaph := []LineBuffer{}
	mut words := 0
	for words < word_count {
		mut temp_line := LineBuffer{}
		for i in 0 .. 4 {
			temp_line.push_word(dict[rand.int_in_range(0, dict.len)] + if i < 4 {
				' '
			} else {
				''
			})
			words += 1
		}
		paragaph << temp_line
	}
	return paragaph
}

interface Prompt {
mut:
	cursor_line int
	cursor_column int
	lines []LineBuffer
}

fn (mut p Prompt) input(char rune, row int, column int) {
	if p.lines[row].text[column].chr == char {
		p.lines[row].text[column].col_fn = term.black
	} else {
		p.lines[row].text[column].col_fn = term.red
	}
	if p.cursor_column < p.lines[row].len - 1 {
		p.cursor_column += 1
	} else {
		p.cursor_line += 1
		p.cursor_column = 0
	}
}

fn (mut p Prompt) backspace(row int, column int) {
	p.lines[row].text[column-1].col_fn = term.white
	p.cursor_column -= 1
}

struct Quote {
mut:
	cursor_line   int
	cursor_column int
	lines         []LineBuffer
	link          Url
}

struct Url {
	url  string
	text string
}

struct Char {
mut:
	col_fn fn (string) string
	chr    rune
}

struct LineBuffer {
mut:
	len int
	// Maximum 16 words. 4 is average length of a word,
	// and an extra rune is allocated for whitespace and
	// punctuation. 80 = 16 * 5.
	word_ind int
	words    [16]byte
	text     [80]Char
}

fn (b LineBuffer) print(x int, y int, mut app App) {
	for i in 0 .. b.len {
		app.tui.draw_text(x - b.len / 2 + i, y, b.text[i].col_fn(b.text[i].chr.str()))
	}
}

fn (mut b LineBuffer) push_word(word string) {
	b.words[b.word_ind] = byte(word.len)
	for i in 0 .. word.len {
		b.text[b.len + i].chr = word[i]
		b.text[b.len + i].col_fn = term.dim
	}
	b.len += word.len
	b.word_ind += 1
}

