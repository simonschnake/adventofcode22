// read lines from inputs/input_day01.txt
// compile with: gcc -o output/solution_day01 solution_day01.c
// run with: ./solution_day01

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void put_in_max_three_values(int* max_three_values, int value)
{
    if (value > max_three_values[0])
    {
        max_three_values[2] = max_three_values[1];
        max_three_values[1] = max_three_values[0];
        max_three_values[0] = value;
    }
    else if (value > max_three_values[1])
    {
        max_three_values[2] = max_three_values[1];
        max_three_values[1] = value;
    }
    else if (value > max_three_values[2])
    {
        max_three_values[2] = value;
    }
}

int main()
{
    // Open the file for reading
    FILE* file = fopen("../inputs/input_day01.txt", "r");

    // Check if the file was successfully opened
    if (file == NULL)
    {
        printf("Error opening file!\n");
        return 1;
    }

    // Determine the size of the file
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);

    // Allocate memory for the string
    char* str = malloc((size + 1) * sizeof(char));

    // Check if the memory was successfully allocated
    if (str == NULL)
    {
        printf("Error allocating memory for string!\n");
        return 1;
    }

    // Read the contents of the file into the string
    fread(str, sizeof(char), size, file);

    // Close the file
    fclose(file);

    // Add a null terminator to the end of the string
    str[size] = '\0';

    // Split the string into lines
    char* line = strsep(&str, "\n");

    int max_three_values[3] = {0, 0, 0};

    int current_value = 0;

    // Loop through the lines
    while (line != NULL)
    {
        // Print the line
        printf("%s\n", line);

        // Check if line is empty
        if (strlen(line) == 0)
        {
            put_in_max_three_values(max_three_values, current_value);
            current_value = 0;
        } else {
            current_value += atoi(line);
        }
        
        // Get the next line
        line = strsep(&str, "\n");
    }
    

    put_in_max_three_values(max_three_values, current_value);

    printf("Max three values: %d, %d, %d\n", max_three_values[0], max_three_values[1], max_three_values[2]);
    printf("Sum: %d\n", max_three_values[0] + max_three_values[1] + max_three_values[2]");

    

    return 0;
}
