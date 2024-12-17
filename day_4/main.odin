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

	rune_matrix: [dynamic][dynamic]rune
	defer delete(rune_matrix)

	file_string := string(data)
	for line in strings.split_lines_iterator(&file_string) {
		chars: [dynamic]rune
		defer delete(chars)
		for char in line {
			append(&chars, char)
		}
		append(&rune_matrix, chars)
	}

	fmt.print(rune_matrix)

	/*
	===============
	- set up an omni-directional reader struct that can hold a cur_val and check 
	the value of letters in all 8 directions
	- In each direction that has a "valid" result, move in that direction; repeat process
	- when the accumulated letters equal "XMAS", add 1 to the counter and continue
	- THIS IMPLEMENTATION REQUIRES EVERY SQUARE TO BE A "starting" POINT
	===============
	*/
}
