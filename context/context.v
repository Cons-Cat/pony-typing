module context

import term
import term.ui as tui
import os
import prompt as prmpt

pub struct App {
pub mut:
	tui    &tui.Context = 0
	prompt &prmpt.Prompt
	width  int
	height int
}
