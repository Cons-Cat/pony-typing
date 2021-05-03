module menu

import term
import term.ui

pub interface DrawableItems {
	draw(&ui.Context, int, int)
}

pub struct Label {
pub mut:
	text     string
	bg       fn (string) string
	fg       fn (string) string
	hover_bg fn (string) string
	hover_fg fn (string) string
	hover    bool
}

pub fn (l Label) draw(mut ctx ui.Context, x int, y int) {
	text := if l.hover { l.hover_bg(l.hover_fg(l.text)) } else { l.bg(l.fg(l.text)) }
	ctx.draw_text(x, y, text)
}

pub interface Button {
	// press fn ()
	label Label
	input ui.KeyCode
	draw(&ui.Context, int, int)
}

// TODO: This incurs a V compiler bug.
// pub fn (b Button) update(e &ui.Event) {
// 	if e.code == b.input {
// 		b.press()
// 	}
// }

pub struct BasicButton {
pub mut:
	press fn ()
	label Label
	input ui.KeyCode
}

// TODO: Remove when above bug is fixed.
pub fn (mut b BasicButton) update(e &ui.Event) {
	if e.code == ui.KeyCode(b.input) {
		b.press()
	}
}

pub fn (b BasicButton) draw(mut ctx ui.Context, x int, y int) {
	b.label.draw(mut ctx, x, y)
}

pub fn (mut b BasicButton) press() {
	b.label.hover = !b.label.hover
}

pub enum Anchor {
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
	anchor Anchor = .tl
}

pub fn (b Box) draw(mut ctx ui.Context, x int, y int, width int, height int) {
	// TODO: Complete anchoring
	for i, item in b.items {
    	match b.anchor {
    		.tl {
        		item.draw(ctx, x, y + i)
        	}
    		.bl {
				item.draw(ctx, b.x + x, y + height - b.items.len - i + 1)
			}
    		else { }
		}
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
	width  int
	height int
	layout Layout
	boxes  []Box
	// TODO: sumtype with none?
	opaque bool
	bg     fn (string) string
}

pub fn (c Container) draw(mut ctx ui.Context) {
	if c.opaque {
		for i in 0 .. c.width {
			for j in 0 .. c.height {
				ctx.draw_text(c.x + i, c.y + j, c.bg(' '))
			}
		}
	}
	// TODO: Account for layout
	mut y_offset := 1
	for i, box in c.boxes {
		box.draw(mut ctx, c.x, c.y + y_offset, c.width, c.height-y_offset)
		y_offset += box.items.len + 1
	}
}
