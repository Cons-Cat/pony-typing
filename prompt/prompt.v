module prompt

import term
import io
import os
import rand

pub fn load_dict(file string, cap int) []string {
	mut lines := []string{}
	mut f := os.open(file) or { panic(err) }
	defer {
		f.close()
	}
	mut r := io.new_buffered_reader(reader: io.make_reader(f), cap: cap)
	for {
		l := r.read_line() or { break }
		lines << l
	}
	return lines
}

pub fn random_paragraph(dict []string, word_count u32) []LineBuffer {
	mut paragaph := []LineBuffer{}
	mut words := 0
	for words < word_count {
		mut temp_line := LineBuffer{}
		for i in 0 .. 4 {
			temp_line.push_word(dict[rand.int_in_range(0, dict.len)] + if i < 4 {
				' '
			} else {
				''
			})
			words += 1
		}
		paragaph << temp_line
	}
	return paragaph
}

interface Prompt {
mut:
	cursor_line int
	cursor_column int
	lines []LineBuffer
}

pub fn (mut p Prompt) input(char rune, row int, column int) {
	if p.lines[row].text[column].chr == char {
		p.lines[row].text[column].col_fn = term.black
	} else {
		p.lines[row].text[column].col_fn = term.red
	}
	if p.cursor_column < p.lines[row].len - 1 {
		p.cursor_column += 1
	} else {
		p.cursor_line += 1
		p.cursor_column = 0
	}
}

pub fn (mut p Prompt) backspace(row int, column int) {
	p.lines[row].text[column - 1].col_fn = term.white
	p.cursor_column -= 1
}

pub struct Quote {
mut:
	cursor_line   int
	cursor_column int
	lines         []LineBuffer
	link          Url
}

struct Url {
	url  string
	text string
}

struct Char {
pub mut:
	col_fn fn (string) string
	chr    rune
}

pub fn (c Char) str() string {
	return c.col_fn(c.chr.str())
}

pub fn make_chars_from_str(s string) []Char {
	mut return_str := []Char{len: s.len}
	for i, c in s {
		return_str[i] = Char{
			col_fn: term.cyan
			chr: rune(c)
		}
	}
	return return_str
}

pub fn make_str_from_chars(chars []Char) string {
	mut return_str := ''
	for _, c in chars {
		return_str = return_str + c.str()
	}
	return return_str
}

pub struct LineBuffer {
pub mut:
	len int
	// Maximum 16 words. 4 is average length of a word,
	// and an extra rune is allocated for whitespace and
	// punctuation. 80 = 16 * 5.
	word_ind int
	words    [16]byte
	text     [80]Char
}

pub fn (mut b LineBuffer) push_word(word string) {
	b.words[b.word_ind] = byte(word.len)
	for i in 0 .. word.len {
		b.text[b.len + i].chr = word[i]
		b.text[b.len + i].col_fn = term.dim
	}
	b.len += word.len
	b.word_ind += 1
}
