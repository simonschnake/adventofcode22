// read lines from inputs/input_day02.txt
// compile with: gcc -o output/solution_day02 solution_day02.c
// run with: ./solution_day02

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {ROCK = 1, PAPER = 2, SCISSORS = 3, LOST = 0, DRAW = 3, WIN = 6};

int get_winner(int player1, int player2)
{
    if (player1 == player2)
    {
        return DRAW;
    }
    else if (player1 == ROCK)
    {
        if (player2 == PAPER)
        {
            return LOST;
        }
        else
        {
            return WIN;
        }
    }
    else if (player1 == PAPER)
    {
        if (player2 == SCISSORS)
        {
            return LOST;
        }
        else
        {
            return WIN;
        }
    }
    else if (player1 == SCISSORS)
    {
        if (player2 == ROCK)
        {
            return LOST;
        }
        else
        {
            return WIN;
        }
    }
    else
    {
        return LOST;
    }
}

int get_my_hand(int player2, int outcome){
    if (outcome == DRAW)
    {
        return player2;
    }
    else if (outcome == WIN)
    {
        if (player2 == ROCK)
        {
            return PAPER;
        }
        else if (player2 == PAPER)
        {
            return SCISSORS;
        }
        else if (player2 == SCISSORS)
        {
            return ROCK;
        }
    }
    else if (outcome == LOST)
    {
        if (player2 == ROCK)
        {
            return SCISSORS;
        }
        else if (player2 == PAPER)
        {
            return ROCK;
        }
        else if (player2 == SCISSORS)
        {
            return PAPER;
        }
    } else
    {
        return 0;
    }
}

int char_to_symbol(char c) {
    if (c == 'A')
    {
        return ROCK;
    }
    else if (c == 'B')
    {
        return PAPER;
    }
    else if (c == 'C')
    {
        return SCISSORS;
    }
    else if (c == 'X')
    {
        return ROCK;
    } else if (c == 'Y')
    {
        return PAPER;
    }
    else if (c == 'Z')
    {
        return SCISSORS;
    } else
    {
        return 0;
    }
}

int char_to_outcome(char c){
    if (c == 'X')
    {
        return LOST;
    } else if (c == 'Y')
    {
        return DRAW;
    }
    else if (c == 'Z')
    {
        return WIN;
    } else
    {
        return 0;
    }
}

int for_each_line_do(char* filename, int (*outcome)(char, char)){
    // Open the file for reading
    FILE* file = fopen(filename, "r");

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

    // Add a null terminator to the end of the string
    str[size] = '\0';

    // Split the string into lines
    char* line = strsep(&str, "\n");

    int sum = 0;

    // Loop through the lines
    while (line != NULL)
    {
        // break at empty line
        if (strlen(line) == 0)
        {
            break;
        } 

        // switch for right outcome
        sum += outcome(line[0], line[2]);
        
        // Get the next line
        line = strsep(&str, "\n");
    }

    // Free the string
    free(str);

    // Close the file
    fclose(file);

    return sum;
}

int outcome_part1(char sym1, char sym2){
    int my_hand = char_to_symbol(sym2);
    int outcome =  get_winner(my_hand, char_to_symbol(sym1));
    return outcome + my_hand;
}

int outcome_part2(char sym1, char sym2){
    int outcome = char_to_outcome(sym2);
    
    return outcome + get_my_hand(char_to_symbol(sym1), outcome);
}

int main()
{
    int res1 = for_each_line_do("../inputs/input_day02.txt", outcome_part1);
    printf("Sum of points in part 1: %d\n", res1);

    int res2 = for_each_line_do("../inputs/input_day02.txt", outcome_part2);
    printf("Sum of points in part 2: %d\n", res2);

    return 0;
}
