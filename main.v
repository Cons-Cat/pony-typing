module main

import term
import term.ui as tui
import os

struct App {
mut:
	tui &tui.Context = 0
}

fn event(e &tui.Event, x voidptr) {
	mut app := &App(x)
	println(e)
	if e.typ == .key_down && e.code == .escape {
		exit(0)
	}
}

fn frame(x voidptr) {
	mut app := &App(x)

	app.tui.clear()
	// app.tui.set_bg_color(r: 63, g: 81, b: 181)
	// app.tui.draw_rect(20, 6, 41, 10)
	app.tui.draw_text(24, 2, 'Hello from V!')
	// app.tui.set_cursor_position(0, 0)

	mut t_lines := []LineBuffer{}
	mut l_one := LineBuffer{}
	l_one.push_word('min ')
	l_one.push_word('maximum')
	t_lines << l_one

	for l in t_lines {
		l.print(20, 8, mut app)
	}
	term.show_cursor() // TODO: Bad spot.
	term.set_cursor_position(term.Coord{10,8})

	app.tui.reset()
	app.tui.flush()
}

fn main() {
	mut app := &App{}
	app.tui = tui.init(
		user_data: app
		event_fn: event
		frame_fn: frame
		hide_cursor: false
		frame_rate: 60
	)
	app.tui.run() ?
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
		app.tui.draw_text(x + b.len / 2 + i, y,b.text[i].col_fn(b.text[i].chr.str()))
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
