package day_1

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
	total: int

	data, ok := os.read_entire_file("data.txt")

	if !ok {
		fmt.eprint("ERROR: Could not read file")
		return
	}
	defer delete(data)

	file_string := string(data)

	for line in strings.split_lines_iterator(&file_string) {
		temp_arr: []string = strings.split(line, "   ", context.temp_allocator)
		defer delete(temp_arr, context.temp_allocator)

		append(&left_array, temp_arr[0])
		append(&right_array, temp_arr[1])
	}

	//part_1: Sort and then sum columns together
	fmt.println(sorted_sum(left_array[:], right_array[:]))


	//part_2: calculate "similarity score" by multiplying {values * occurences}
	fmt.println(similarity_score(left_array[:], right_array[:]))

	delete(left_array)
	delete(right_array)
}

sorted_sum :: proc(left_array: []string, right_array: []string) -> (total: int) {
	slice.stable_sort(left_array)
	slice.stable_sort(right_array)

	if len(left_array) != len(right_array) {
		fmt.eprint("Columns are not of same length\n")
		return -1
	}

	for index in 0 ..< len(left_array) {
		dif := strconv.atoi(left_array[index]) - strconv.atoi(right_array[index])
		abs_dif := abs(dif)

		total += abs_dif
	}
	return
}

similarity_score :: proc(left_array: []string, right_array: []string) -> (score: int) {
	occurence_map := make(map[string]int)
	defer delete(occurence_map)

	for value in right_array {
		occurence_map[value] += 1
	}

	for value in left_array {
		score += strconv.atoi(value) * occurence_map[value]
	}

	return
}
