module main

import term
import term.ui as tui
import os
import prompt as prmpt
import context as ctx
import menu

fn event(e &tui.Event, mut app ctx.App) {
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
	// Initial prompt.
	mut t_lines := prmpt.load_dict(os.dir(os.executable()) + '/words', 100)
	paragaph := prmpt.random_paragraph(t_lines, 10)

	// Instantiate context.
	mut app := &ctx.App{
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

	// Instantiate UI
	mut ui_box := menu.Box{
		x: 0
		y: 0
		anchor: .tl
	}
	tab_text := prmpt.make_char_from_str('TAB')

	ui_box.items << menu.Label{
		text: tab_text
		x: 0
		y: 0
		bg: term.yellow
		fg: term.cyan
	}

	mut ui := &menu.container{
		x: 0
		y: 0
		layout: menu.layout.vert
		boxes: [ui_box]
	}

	// Run game loop
	app.tui.run() ?
}

fn frame(mut app ctx.App) {
	app.width, app.height = term.get_terminal_size()

	app.tui.clear()

	print_prompt(mut app)

	app.tui.reset()
	app.tui.flush()

	term.set_cursor_position(term.Coord{
		app.width / 2 - app.prompt.lines[app.prompt.cursor_line].len / 2 + app.prompt.cursor_column,
		app.height / 2 + app.prompt.cursor_line})
	term.show_cursor()
}

fn print_prompt(mut app ctx.App) {
	for i, line in app.prompt.lines {
		for j in 0 .. line.len {
			raw_char := line.text[j].chr.str()
			smart_char := if raw_char == ' ' { '␣' } else { raw_char }
			app.tui.draw_text(app.width / 2 - line.len / 2 + j, app.height / 2 + i, line.text[j].col_fn(smart_char))
		}
	}
}
