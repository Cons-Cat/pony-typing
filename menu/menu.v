module menu

// import context as ctx
import term.ui as tui
import prompt

pub interface DrawableItems {
	draw(&tui.Context, int, int)
}

pub struct Label {
pub mut:
	text     string
	x        int
	y        int
	bg       fn (string) string
	fg       fn (string) string
	hover_bg fn (string) string
	hover_fg fn (string) string
	hover    bool
}

pub fn (l Label) draw(mut ctx tui.Context, x int, y int) {
	text := if l.hover { l.hover_bg(l.hover_fg(l.text)) } else { l.bg(l.fg(l.text)) }
	ctx.draw_text(x, y, text)
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
		item.draw(ctx, b.x + x, b.y + y + i)
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
	// TODO: Account for layout
	for _, box in c.boxes {
		box.draw(mut ctx, c.x, c.y)
	}
}
