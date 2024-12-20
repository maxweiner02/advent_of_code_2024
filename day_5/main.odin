package day_5

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
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
	defer delete(data)

	sections: []string = strings.split(string(data), "\n\r\n")
	rules_raw := sections[0]
	page_sequences := sections[1]
	defer delete(sections)

	rules := make(map[int][dynamic]int)
	defer {
		for rule in rules {
			delete(rules[rule])
		}
		clear(&rules)
		delete(rules)
	}
	for rule in strings.split_lines_iterator(&rules_raw) {
		parts := strings.split(rule, "|")
		defer delete(parts)
		key := strconv.atoi(parts[0])
		elem := strconv.atoi(parts[1])
		ok := key in rules
		if ok {
			append(&rules[key], elem)
		} else {
			rules[key] = [dynamic]int{elem}
		}
	}

	total := 0
	invalid_total := 0

	for sequence in strings.split_lines_iterator(&page_sequences) {
		pages := strings.split(sequence, ",")
		defer delete(pages)
		sequence_found := false
		for page, i in pages {
			page_num := strconv.atoi(page)
			ok := page_num in rules
			if ok {
				for elem in rules[page_num] {
					#reverse for page_string in pages[:i] {
						num := strconv.atoi(page_string)
						if elem == num {
							sequence_found = true
							break
						}
					}
					if sequence_found {
						break
					}
				}
				if sequence_found {
					break
				}
			}
		}
		if !sequence_found {
			middle_index := len(pages) / 2
			middle_value := strconv.atoi(pages[middle_index])
			total += middle_value
		} else {
			// Reorder the bad sequence
			reordered_sequence := reorder_sequence(pages, rules)
			middle_index := len(reordered_sequence) / 2
			middle_value := reordered_sequence[middle_index]
			invalid_total += middle_value
		}
	}

	fmt.println(total)
	fmt.println(invalid_total)
}

//works on sample but not big data
reorder_sequence :: proc(sequence: []string, rules: map[int][dynamic]int) -> []int {
	num_sequence: [dynamic]int
	for str in sequence do append(&num_sequence, strconv.atoi(str))
	defer delete(num_sequence)

	ordered_sequence := make([]int, len(num_sequence))
	copy(ordered_sequence, num_sequence[:])
	defer delete(ordered_sequence)

	for key, elems in rules {
		for elem in elems {
			key_index := -1
			elem_index := -1
			for num, i in ordered_sequence {
				if num == key {
					key_index = i
				} else if num == elem {
					elem_index = i
				}
				if key_index != -1 && elem_index != -1 {
					break
				}
			}
			if key_index != -1 && elem_index != -1 && key_index > elem_index {
				ordered_sequence[key_index], ordered_sequence[elem_index] =
					ordered_sequence[elem_index], ordered_sequence[key_index]
			}
		}
	}

	return ordered_sequence
}
