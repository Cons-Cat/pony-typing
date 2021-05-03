module main

import term
import term.ui as tui
import os
import prompt as prmpt
import context as ctx
import menu

fn main() {
	// Initial prompt.
	mut t_lines := prmpt.load_dict(os.dir(os.executable()) + '/words', 100)
	paragaph := prmpt.random_paragraph(t_lines, 10)

	mut prompt_container := make_prompt_ui()
	prompt_container.width, prompt_container.height = term.get_terminal_size()

	// mut sidebar_container := make_sidebar_ui()
	// _, sidebar_container.height = term.get_terminal_size()
	// sidebar_container.x = -sidebar_container.width
	mut sidebar_container := menu.SuperContainer(menu.Container{})

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

fn event(e &tui.Event, mut app ctx.App) {
	// Match typing prompt input.
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
	// Update UI elements.
	for mut menu in app.menu_stack {
		menu.update(e)
	}
}

fn frame(mut app ctx.App) {
	app.width, app.height = term.get_terminal_size()
	app.menu_stack[ctx.UILayers.prompt].width, app.menu_stack[ctx.UILayers.prompt].height = app.width,
		app.height + 1
	app.menu_stack[ctx.UILayers.sidebar].height = app.height + 1

	app.tui.clear()

	// TODO: Streamline prompt
	print_prompt(mut app)
	for _, mut menu in app.menu_stack {
		menu.draw(mut app.tui)
	}

	app.tui.reset()
	app.tui.flush()

	term.set_cursor_position(term.Coord{
		app.width / 2 - app.prompt.lines[app.prompt.cursor_line].len / 2 + app.prompt.cursor_column,
		app.height / 2 + app.prompt.cursor_line})
	// Technically, cursor should already be showing.
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

fn make_prompt_ui() menu.SuperContainer {
	mut ui_box := &menu.Box{
		x: 0
		y: 0
		anchor: .bl
	}
	// TODO: Why does this need to be heap allocated?
	// IIRC this is a bug related to interfaces.
	test_label := &menu.Label{
		text: 'TAB'
		bg: term.bright_bg_black
		fg: term.cyan
		hover_bg: term.bg_black
		hover_fg: term.cyan
	}
	ui_box.items << &menu.BasicButton{
		label: test_label
		input: .tab
		press: slide_panel
	}
	return &menu.Container{
		x: 0
		y: 0
		layout: .quad
		boxes: [ui_box]
	}
}

fn make_sidebar_ui() menu.SuperContainer {
	mut type_box := &menu.Box{
		anchor: .tl
	}
	type_box.items << &menu.Label{
		text: 'TYPE'
		bg: term.bg_cyan
		fg: term.black
	}
	type_box.items << &menu.BasicButton{
		label: menu.Label{
			text: 'Random'
			bg: term.bright_bg_white
			fg: term.black
		}
	}
	type_box.items << &menu.BasicButton{
		label: menu.Label{
			text: 'Quotes'
			bg: term.bright_bg_white
			fg: term.black
		}
	}

	mut tab_box := &menu.Box{
		anchor: .bl
	}
	tab_box.items << &menu.BasicButton{
		label: menu.Label{
			text: 'TAB'
			bg: term.bg_cyan
			fg: term.black
		}
	}

	sidebar_boxes := [
		type_box,
		tab_box,
	]
	return &menu.Container{
		x: 0
		y: 0
		width: 20
		layout: .vert
		opaque: true
		bg: term.bright_bg_white
		boxes: sidebar_boxes
	}
}

struct SidePanel {
	menu.Container
	toggle bool
	// TODO: Acceleration / Velocity
}

fn slide_panel() {
	// panic('n')
}
