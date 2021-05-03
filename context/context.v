module context

import term
import term.ui as tui
import prompt as prmpt
import menu

pub enum UILayers {
	prompt
	sidebar
	length
}

pub struct App {
pub mut:
	tui    &tui.Context = 0
	prompt &prmpt.Prompt
	// TODO: Set size with UILayers.length
	// This should work, but doesn't due to a compiler bug.
	menu_stack     [2]menu.SuperContainer
	sidebar_toggle bool
	width          int
	height         int
}

pub fn (mut app App) draw_char_array(text []prmpt.Char, x int, y int) {
	for i in 0 .. text.len {
		app.tui.draw_text(x + i, y, text.str())
	}
}
