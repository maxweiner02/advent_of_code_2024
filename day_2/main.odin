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

	count: int
	lax_count: int

	data, ok := os.read_entire_file("data.txt")

	if !ok {
		fmt.eprint("ERROR: Could not read file")
		return
	}
	defer delete(data)

	file_string := string(data)

	for line in strings.split_lines_iterator(&file_string) {
		temp_arr: []string = strings.split(line, " ", context.temp_allocator)
		defer delete(temp_arr, context.temp_allocator)

		if is_line_safe(temp_arr) {
			count += 1
		}

		if lax_is_line_safe(temp_arr) {
			lax_count += 1
		}
	}

	fmt.println(count)
	fmt.println(lax_count)
}

is_line_safe :: proc(line: []string) -> bool {
	prev_val: int
	is_ascending: bool

	for val_string, index in line {
		cur_val := strconv.atoi(val_string)

		if index == 0 {
			prev_val = cur_val
			continue
		}

		if index == 1 {
			is_ascending = true if cur_val > prev_val else false
		}

		if is_ascending {
			if cur_val <= prev_val {
				return false
			}
			if cur_val - prev_val > 3 {
				return false
			}
		} else {
			if cur_val >= prev_val {
				return false
			}
			if prev_val - cur_val > 3 {
				return false
			}
		}

		prev_val = cur_val
	}
	return true
}

lax_is_line_safe :: proc(line: []string) -> bool {
	if is_line_safe(line) {
		return true
	}

	for i in 0 ..< len(line) {
		if is_line_safe(line[..i] ++ line[i+1..]) {
			return true
		}
	}

	return false
}
