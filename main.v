module main

import term
import term.ui as tui
import os
import prompt as prmpt

struct App {
mut:
	tui    &tui.Context = 0
	prompt &prmpt.Prompt
}

fn event(e &tui.Event, mut app App) {
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
	mut t_lines := prmpt.load_dict(os.dir(os.executable()) + '/words', 100)
	paragaph := prmpt.random_paragraph(t_lines, 10)
	mut app := &App{
		prompt: &prmpt.Prompt(prmpt.Quote{
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
		for j in 0 .. line.len {
			app.tui.draw_text(width / 2 - line.len / 2 + j, height / 2 + i, line.text[j].col_fn(line.text[j].chr.str()))
		}
		// line.print(width / 2, height / 2 + i, mut app)
	}

	app.tui.reset()
	app.tui.flush()

	term.set_cursor_position(term.Coord{
		width / 2 - app.prompt.lines[app.prompt.cursor_line].len / 2 + app.prompt.cursor_column,
		height / 2 + app.prompt.cursor_line})
	term.show_cursor()
}
