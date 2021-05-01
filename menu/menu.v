module menu

import context as ctx
import prompt

pub interface DrawableItems {
	draw(&ctx.App, int, int)
}

pub struct Label {
pub mut:
	text []prompt.Char
	x    int
	y    int
	bg   fn (string) string
	fg   fn (string) string
}

pub fn (l Label) draw(mut app ctx.App, x int, y int) {
	app.draw_char_array(l.text, l.x + x, l.y + y)
}

pub interface Button {
	press fn ()
	label Label
	update()
	draw(&ctx.App)
}

// TODO: BasicButton
pub enum Anchor {
	t
	b
	l
	r
	tl
	tr
	bl
	br
}

pub struct Box {
pub mut:
	items  []DrawableItems
	x      int
	y      int
	anchor Anchor
}

pub fn (b Box) draw(mut app ctx.App, x int, y int) {
	for i, item in b.items {
		item.draw(app, x, y + i)
	}
}

pub enum Layout {
	vert
	quad
}

pub struct Container {
pub mut:
	x      int
	y      int
	layout Layout
	boxes  []Box
}

pub fn (c Container) draw(mut app ctx.App) {
	for _, box in c.boxes {
		box.draw(mut app, c.x, c.y)
	}
}
