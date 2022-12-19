
// read lines from inputs/input_day03.txt
// compile with: gcc -o output/solution_day03 solution_day03.c
// run with: ./solution_day03

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int for_each_line_in_file_accumulate_outcome(const char *filename,
                                             int (*outcome)(char *[])) {
  // Open the file for reading
  FILE *file = fopen(filename, "r");

  // Check if the file was successfully opened
  if (file == NULL) {
    printf("Error opening file!\n");
    return 1;
  }

  // Determine the size of the file
  fseek(file, 0, SEEK_END);
  long size = ftell(file);
  fseek(file, 0, SEEK_SET);

  // Allocate memory for the string
  char *str = malloc((size + 1) * sizeof(char));

  // Check if the memory was successfully allocated
  if (str == NULL) {
    printf("Error allocating memory for string!\n");
    return 1;
  }

  // Read the contents of the file into the string
  fread(str, sizeof(char), size, file);

  // Add a null terminator to the end of the string
  str[size] = '\0';

  // Split the string into lines
  char *line = strsep(&str, "\n");

  int sum = 0;
  char *last_three_str[3];
  int counter = 0;

  // Loop through the lines
  while (line != NULL) {
    if (counter >= 3) {
      sum += outcome(last_three_str);
      counter = 0;
    }

    if (strlen(line) == 0) {
      break;
    }

    last_three_str[counter] = line;
    counter++;

    // Get the next line
    line = strsep(&str, "\n");
  }

  // Free the string
  free(str);

  // Close the file
  fclose(file);

  return sum;
}

char find_matching_char(char *first, char *second, char *third) {
  int len = strlen(first);
  for (int i = 0; i < len; i++) {
    char c = first[i];
    if (strchr(second, c) != NULL && strchr(third, c) != NULL) {
      return c;
    }
  }
  return '\0';
}

int priority(char c) {
  // check if char is uppercase or lowercase
  if (c >= 'A' && c <= 'Z') {
    return c - 'A' + 27;
  } else if (c >= 'a' && c <= 'z') {
    return c - 'a' + 1;
  } else {
    return 0;
  }
}

int outcome(char *three_lines[]) {

  char c = find_matching_char(three_lines[0], three_lines[1], three_lines[2]);

  if (c == '\0') {
    return 0;
  }

  return priority(c);
}

int main() {
  int sum = for_each_line_in_file_accumulate_outcome(
      "../inputs/input_day03.txt", outcome);

  printf("The sum of priorities is %d\n", sum);

  return 0;
}
