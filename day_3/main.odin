package day_3

import "core:fmt"
import "core:io"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

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

	data, ok := os.read_entire_file("data.txt")
	defer delete(data)

	if !ok {
		fmt.eprint("ERROR: Could not read file")
		return
	}

	file_string := string(data)
	can_do := true

	fmt.println(calculate_total(file_string))
	fmt.println(can_do_calculate_total(file_string))
}

calculate_total :: proc(file_string: string) -> (total: int) {
	num_1: [dynamic]rune
	defer delete(num_1)

	num_2: [dynamic]rune
	defer delete(num_2)

	for char, index in file_string {
		int_1: int
		int_2: int
		cur_index := index
		if char == 'm' {
			if file_string[cur_index + 1] == 'u' {
				if file_string[cur_index + 2] == 'l' {
					if file_string[cur_index + 3] == '(' {
						cur_index += 4
						for subchar in file_string[cur_index:] {
							if unicode.is_digit(subchar) {
								append(&num_1, subchar)
								cur_index += 1
							} else {
								break
							}
						}
						// This comes after we have stopped at the end of num_1 and/or broken out
						if file_string[cur_index] == ',' {
							int_1 = strconv.atoi(
								utf8.runes_to_string(num_1[:], context.temp_allocator),
							)
							cur_index += 1
							for subchar in file_string[cur_index:] {
								if unicode.is_digit(subchar) {
									append(&num_2, subchar)
									cur_index += 1
								} else {
									break
								}
							}

							// This comes after we have stopped at the end of num_2 and/or broken out
							if file_string[cur_index] == ')' {
								int_2 = strconv.atoi(
									utf8.runes_to_string(num_2[:], context.temp_allocator),
								)
							}
						}
					}
				}
			}
		}
		total += int_1 * int_2
		clear(&num_1)
		clear(&num_2)
	}

	return
}

can_do_calculate_total :: proc(file_string: string) -> (total: int) {
	can_do := true

	num_1: [dynamic]rune
	defer delete(num_1)

	num_2: [dynamic]rune
	defer delete(num_2)

	for char, index in file_string {
		int_1: int
		int_2: int
		cur_index := index
		if char == 'm' {
			if file_string[cur_index + 1] == 'u' {
				if file_string[cur_index + 2] == 'l' {
					if file_string[cur_index + 3] == '(' {
						cur_index += 4
						for subchar in file_string[cur_index:] {
							if unicode.is_digit(subchar) {
								append(&num_1, subchar)
								cur_index += 1
							} else {
								break
							}
						}
						// This comes after we have stopped at the end of num_1 and/or broken out
						if file_string[cur_index] == ',' {
							int_1 = strconv.atoi(
								utf8.runes_to_string(num_1[:], context.temp_allocator),
							)
							cur_index += 1
							for subchar in file_string[cur_index:] {
								if unicode.is_digit(subchar) {
									append(&num_2, subchar)
									cur_index += 1
								} else {
									break
								}
							}

							// This comes after we have stopped at the end of num_2 and/or broken out
							if file_string[cur_index] == ')' {
								int_2 = strconv.atoi(
									utf8.runes_to_string(num_2[:], context.temp_allocator),
								)
							}
						}
					}
				}
			}
		} else if char == 'd' {
			if file_string[cur_index + 1] == 'o' {
				if file_string[cur_index + 2] == '(' {
					if file_string[cur_index + 3] == ')' {
						can_do = true
					}
				}
			}
		}
		total += int_1 * int_2
		clear(&num_1)
		clear(&num_2)
	}

	return
}
