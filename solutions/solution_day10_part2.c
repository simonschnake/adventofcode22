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

void do_after_cycle(char display[6][41], int n_reg, int n_cyc, int* sum_of_strengths) {
    // first part
    if (n_cyc >= 20 && (n_cyc - 20) % 40 == 0) {
        printf("cycle: %d \t register: %d\n", n_cyc, n_reg);
        *sum_of_strengths += (n_reg * n_cyc);
    }

    int line = (n_cyc - 1) / 40;
    int column = (n_cyc - 1) % 40;
    
    if (column >= n_reg - 1 && column <= n_reg + 1) {
        display[line][column] = '#';
    }
}

int main()
{
    char *input = read_file("../inputs/input_day10.txt");

    char display[6][41] = {
        "........................................",
        "........................................",
        "........................................",
        "........................................",
        "........................................",
        "........................................"
    };
    int n_reg = 1;
    int n_cyc = 0;
    int sum_of_strengths = 0;


    // Split input into lines
    char *line = strsep(&input, "\n");

    // Iterate over lines
    while (line != NULL)
    {
        // Check if line is empty
        if(strlen(line) == 0) {
            break;
        }

        // if line starts with noop, increase n_circles
        if (strncmp(line, "noop", 4) == 0) {
            n_cyc++;
            do_after_cycle(&display, n_reg, n_cyc, &sum_of_strengths);
        } else {
            // Split line into parts
            char *part = strsep(&line, " ");
            part = strsep(&line, " ");
            int value_to_increase = atoi(part);

            n_cyc++;
            do_after_cycle(&display, n_reg, n_cyc, &sum_of_strengths);
            n_cyc++;
            do_after_cycle(&display, n_reg, n_cyc, &sum_of_strengths);
            n_reg += value_to_increase;
        }

        // Get next line
        line = strsep(&input, "\n");
    }

    // print display
    for (int i = 0; i < 6; i++) {
        printf("%s\n", display[i]);
    }

    free(input);

    printf("Sum of strengths: %d\n", sum_of_strengths);

    return 0;
}
