module context

import term
import term.ui as tui
import prompt as prmpt
import menu

pub struct App {
pub mut:
	tui        &tui.Context = 0
	prompt     &prmpt.Prompt
	menu_stack []&menu.Container
	width      int
	height     int
}

pub fn (mut app App) draw_char_array(text []prmpt.Char, x int, y int) {
	for i in 0 .. text.len {
		app.tui.draw_text(x + i, y, text.str())
	}
}
