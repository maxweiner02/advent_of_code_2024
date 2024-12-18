package day_4

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

main :: proc() {
	//Standard Debug Allocator declaration
	//src: https://gist.github.com/karl-zylinski/4ccf438337123e7c8994df3b03604e33
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}


	data, ok := os.read_entire_file("data.txt", context.allocator)
	if !ok {
		fmt.eprintln("Error reading file")
		return
	}
	defer delete(data, context.allocator)

	rune_matrix: [dynamic][]rune
	defer {
		for list in rune_matrix do delete(list)
		delete(rune_matrix)
	}

	file_string := string(data)
	for line in strings.split_lines_iterator(&file_string) {
		chars: [dynamic]rune
		for char in line {
			append(&chars, char)
		}
		append(&rune_matrix, chars[:])
	}

	fmt.println(searchWord(rune_matrix[:], "XMAS"))
	fmt.println(searchWordXMAS(rune_matrix[:]))
}

/*
- returns an int because a single location can be the first letter for up to 8 valid words
*/
searchGrid :: proc(grid: [][]rune, row: int, col: int, word: string) -> int {
	height := len(grid)
	width := len(grid[0])
	word_length := len(word)
	count := 0

	if grid[row][col] != rune(word[0]) do return count

	x := [8]int{-1, -1, -1, 0, 0, 1, 1, 1}
	y := [8]int{-1, 0, 1, -1, 1, -1, 0, 1}

	for dir := 0; dir < 8; dir += 1 {
		curX := row + x[dir]
		curY := col + y[dir]
		char_pos := 1

		for char_pos < word_length {
			if curX >= height || curX < 0 || curY >= width || curY < 0 {
				break
			}
			if grid[curX][curY] != rune(word[char_pos]) {

				break
			}

			curX += x[dir]
			curY += y[dir]
			char_pos += 1
		}
		if char_pos == word_length {

			count += 1
		}
	}
	return count
}

searchWord :: proc(grid: [][]rune, word: string) -> int {
	height := len(grid)
	width := len(grid[0])
	result := 0

	for i := 0; i < height; i += 1 {
		for j := 0; j < width; j += 1 {
			result += searchGrid(grid, i, j, word)
		}
	}

	return result
}


/*
- returns a boolean because each location can only have one valid value
- hardcoded for MAS; but could be refactored to take any odd length string
*/
searchGridXMAS :: proc(grid: [][]rune, row: int, col: int) -> bool {
	height := len(grid)
	width := len(grid[0])

	if grid[row][col] != 'A' do return false

	x := [4]int{-1, -1, 1, 1}
	y := [4]int{-1, 1, 1, -1}

	validDiagonal1 := false
	if row - 1 >= 0 && col - 1 >= 0 && row + 1 < height && col + 1 < width {
		if (grid[row - 1][col - 1] == 'M' && grid[row + 1][col + 1] == 'S') ||
		   (grid[row - 1][col - 1] == 'S' && grid[row + 1][col + 1] == 'M') {
			validDiagonal1 = true
		}
	}

	validDiagonal2 := false
	if row - 1 >= 0 && col + 1 < width && row + 1 < height && col - 1 >= 0 {
		if (grid[row - 1][col + 1] == 'M' && grid[row + 1][col - 1] == 'S') ||
		   (grid[row - 1][col + 1] == 'S' && grid[row + 1][col - 1] == 'M') {
			validDiagonal2 = true
		}
	}

	return validDiagonal1 && validDiagonal2
}

searchWordXMAS :: proc(grid: [][]rune) -> int {
	height := len(grid)
	width := len(grid[0])
	result := 0

	for i := 0; i < height; i += 1 {
		for j := 0; j < width; j += 1 {
			if searchGridXMAS(grid, i, j) do result += 1
		}
	}

	return result
}
