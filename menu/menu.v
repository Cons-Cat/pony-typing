module menu

// import context as ctx
import term.ui as tui
import prompt

pub interface DrawableItems {
	draw(&tui.Context, int, int)
}

pub struct Label {
pub mut:
	text []prompt.Char
	x    int
	y    int
	bg   fn (string) string
	fg   fn (string) string
}

pub fn (l Label) draw(mut ctx tui.Context, x int, y int) {
	// app.draw_char_array(l.text, l.x + x, l.y + y)
	// TODO: Draw_Text
}

pub interface Button {
	press fn ()
	label Label
	update()
	draw(&tui.Context)
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

pub fn (b Box) draw(mut ctx tui.Context, x int, y int) {
	for i, item in b.items {
		item.draw(ctx, x, y + i)
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

pub fn (c Container) draw(mut ctx tui.Context) {
	for _, box in c.boxes {
		box.draw(mut ctx, c.x, c.y)
	}
}
