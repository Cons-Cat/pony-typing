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

	// Instantiate UI
	mut ui_box := menu.Box{
		x: 0
		y: 0
		anchor: .tl
	}

	test_label := menu.Label{
		text: 'TAB'
		bg: term.white
		fg: term.cyan
		hover_bg: term.black
		hover_fg: term.cyan
	}

	ui_box.items << menu.BasicButton{
		label: test_label
		input: tui.KeyCode.tab
	}

	mut prompt_container := menu.Container{
		x: 0
		y: 0
		layout: .quad
		boxes: [ui_box]
	}
	prompt_container.width, prompt_container.height = term.get_terminal_size()

	mut sidebar_container := menu.Container{
		x: 0
		y: 0
		width: 20
		layout: .vert
		opaque: true
		bg: term.bright_bg_white
	}
	_, sidebar_container.height = term.get_terminal_size()

	// Instantiate context.
	mut app := &ctx.App{
		prompt: &prmpt.Prompt(prmpt.Quote{
			lines: paragaph
		})
		menu_stack: [prompt_container, sidebar_container]!
	}
	app.tui = tui.init(
		user_data: app
		event_fn: event
		frame_fn: frame
		hide_cursor: false
		frame_rate: 60
	)

	// Run game loop
	app.tui.run() ?
}

fn frame(mut app ctx.App) {
	app.width, app.height = term.get_terminal_size()

	app.tui.clear()

	print_prompt(mut app)
	for _, menu in app.menu_stack {
		menu.draw(mut app.tui)
	}

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
