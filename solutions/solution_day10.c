#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* read_file(const char* filename) {
    // Open File for reading
    FILE *fp = fopen(filename, "r");

    // Check if file was opened successfully
    if (fp == NULL) {
        printf("Error opening file!\n");
        exit(1);
    }

    // Get file size
    fseek(fp, 0L, SEEK_END);
    long size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);

    // Allocate memory for entire content
    char *buffer = malloc((size + 1) * sizeof(char));

    // Check if memory was allocated successfully
    if (buffer == NULL) {
        printf("Error allocating memory!\n");
        exit(1);
    }

    // Copy file into buffer
    fread(buffer, sizeof(char), size, fp);

    // Close file
    fclose(fp);

    // Add null terminator
    buffer[size] = '\0';

    return buffer;
}


void print_if_fitting_circle_and_increase_sum_of_strengths(int n_circles, int value, int* sum_of_strengths) {
    if (n_circles >= 20 && (n_circles - 20) % 40 == 0) {
        printf("num_circ: %d \t value: %d\n", n_circles, value);
        *sum_of_strengths += value * n_circles;
    }
}

int main(int argc, char const *argv[])
{
    char *input = read_file("../inputs/input_day10.txt");

    // Split input into lines
    char *line = strsep(&input, "\n");

    int value = 1;
    int n_circles = 0;
    int sum_of_strengths = 0;

    // Iterate over lines
    while (line != NULL)
    {
        // Check if line is empty
        if(strlen(line) == 0) {
            break;
        }

        // if line starts with noop, increase n_circles
        if (strncmp(line, "noop", 4) == 0) {
            n_circles++;
            print_if_fitting_circle_and_increase_sum_of_strengths(n_circles, value, &sum_of_strengths);
        } else {
            // Split line into parts
            char *part = strsep(&line, " ");
            char *command = part;
            part = strsep(&line, " ");
            int value_to_increase = atoi(part);

            n_circles++;
            print_if_fitting_circle_and_increase_sum_of_strengths(n_circles, value, &sum_of_strengths);
            n_circles++;
            print_if_fitting_circle_and_increase_sum_of_strengths(n_circles, value, &sum_of_strengths);
            value += value_to_increase;
        }

        // Get next line
        line = strsep(&input, "\n");
    }

    free(input);

    printf("Sum of strengths: %d\n", sum_of_strengths);

    return 0;
}
