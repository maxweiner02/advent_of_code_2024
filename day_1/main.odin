package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	//Standard Debug Allocator delcaration
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

	left_array: [dynamic]string
	right_array: [dynamic]string
	total: i32


	data, ok := os.read_entire_file("data.txt", context.allocator)

	if !ok {
		fmt.eprint("ERROR: Could not read file")
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		temp_arr: []string = strings.split(line, "   ")
		append(&left_array, temp_arr[0])
		append(&right_array, temp_arr[1])
		delete(temp_arr)
	}

	// slice.sort(left_array[:])
	// slice.sort(right_array[:])

	if len(left_array) != len(right_array) {
		fmt.eprint("Columns are not of same length")
		return
	}

	// for num, index in left_array {

	// }
	for rune in left_array[0] {

	}

	//this works :)
	test1 := strconv.atoi(left_array[0])
	test2 := strconv.atoi(right_array[0])
	test3 := test1 - test2

	fmt.print(test3)
	delete(left_array)
	delete(right_array)
}
