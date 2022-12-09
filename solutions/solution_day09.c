#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N_PARTS 10
#define MIN_CAPACITY 100
#define MAX_FILLED 0.75
#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef struct
{
    int x;
    int y;
} point;

point *point_create(int x, int y)
{
    point *p = malloc(sizeof(point));

    // Check if malloc failed
    if (p == NULL)
    {
        fprintf(stderr, "Error: malloc failed in point_create!\n");
        exit(1);
    }

    p->x = x;
    p->y = y;
    return p;
}

void set_point(point *p, int x, int y)
{
    p->x = x;
    p->y = y;
}

void free_point(point *p)
{
    free(p);
}

typedef struct
{
    point **points;
    unsigned long n_points;
    unsigned long capacity;
} point_set;

point_set *point_set_create()
{
    point_set *ps = malloc(sizeof(point_set));

    // Check if malloc failed
    if (ps == NULL)
    {
        fprintf(stderr, "Error: malloc failed in point_set_create!\n");
        exit(1);
    }

    ps->points = malloc(MIN_CAPACITY * sizeof(point *));

    // Check if malloc failed
    if (ps->points == NULL)
    {
        fprintf(stderr, "Error: malloc failed in point_set_create!\n");
        exit(1);
    }

    ps->n_points = 0;
    ps->capacity = MIN_CAPACITY;
    return ps;
}

void free_point_set(point_set *ps)
{
    for (int i = 0; i < ps->n_points; i++)
    {
        if (ps->points[i] != NULL)
            free_point(ps->points[i]);
    }
    free(ps->points);
    free(ps);
}

unsigned long hash(int x, int y)
{
    unsigned long hash = 5381;

    hash = ((hash << 5) + hash) + x; /* hash * 33 + c */
    hash = ((hash << 5) + hash) + y; /* hash * 33 + c */

    return hash;
}

void point_set_add_without_capacity_check(point_set *ps, int x, int y)
{
    

    
    ps->n_points++;
}

void increase_capacity(point_set *ps)
{

    point **old_points = ps->points;

    ps->capacity *= 2;
    ps->points = malloc(ps->capacity * sizeof(point *));

    // Check if malloc failed
    if (ps->points == NULL)
    {
        fprintf(stderr, "Error: malloc failed in increase_capacity!\n");
        exit(1);
    }

    for (int i = 0; i < ps->capacity / 2; i++)
    {
        point *p = old_points[i];
        if (p != NULL)
        {
            int x = p->x;
            int y = p->y;
            
            unsigned long h = hash(x, y) % ps->capacity;
            while(ps->points[h] != NULL)
            {
                h = (h + 1) % ps->capacity;
            }

            ps->points[h] = p;
        }
    }

    free(old_points);
}

void point_set_add(point_set *ps, int x, int y)
{
    if (ps->n_points >= MAX_FILLED * ps->capacity)
    {
        increase_capacity(ps);
    }

    unsigned long h = hash(x, y) % ps->capacity;

    for(point *p_curr = ps->points[h]; p_curr != NULL; p_curr = ps->points[h])
    {
        if (p_curr->x == x && p_curr->y == y)
        {
            return;
        }
        h = (h + 1) % ps->capacity;
    }

    ps->points[h] = point_create(x, y);
    
    ps->n_points++;
}

int distance(point *p1, point *p2)
{
    return MAX(abs(p1->x - p2->x), abs(p1->y - p2->y));
}

int sign(int x)
{
    return (x > 0) - (x < 0);
}

void move_elem(point snake[], int i)
{
    point *prev = &snake[i - 1];
    point *curr = &snake[i];
    if (distance(prev, curr) >= 2)
    {
        curr->x += sign(prev->x - curr->x);
        curr->y += sign(prev->y - curr->y);
    }
}

void move(point snake[], char direction)
{
    point *head = &snake[0];

    switch (direction)
    {
    case 'U':
        head->y += 1;
        break;
    case 'D':
        head->y -= 1;
        break;
    case 'R':
        head->x += 1;
        break;
    case 'L':
        head->x -= 1;
        break;
    }

    // move rest of snake
    for (int i = 1; i < N_PARTS; i++)
    {
        move_elem(snake, i);
    }
}

char* read_file(char* filename) {
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

int main(int argc, char const *argv[])
{
    //char *input = strdup("R 5\nU 8\nL 8\nD 3\nR 17\nD 10\nL 25\nU 20");
    char* input = read_file("../inputs/input_day09.txt");

    //printf("%s\n", input);

    point snake[N_PARTS];

    // Initialize snake
    for (int i = 0; i < N_PARTS; i++)
    {
        set_point(&snake[i], 0, 0);
    }

    point *tail = &snake[N_PARTS - 1];

    point_set* all_pos_tail = point_set_create();

    // Split input into lines
    char *line = strsep(&input, "\n");

    // Iterate over lines
    while (line != NULL)
    {
        // Check if line is empty
        if(strlen(line) == 0) {
            break;
        }

        // Split line into parts
        char *part = strsep(&line, " ");
        char direction = part[0];
        part = strsep(&line, " ");
        int distance = atoi(part);

        for (int i = 0; i < distance; i++)
        {
            move(snake, direction);
            point_set_add(all_pos_tail, tail->x, tail->y);
        }

        // Get next line
        line = strsep(&input, "\n");
    }

    // Print number of all positions of the tail
    printf("The number is: %lu\n", all_pos_tail->n_points);

    // Free all_pos_tail
    free_point_set(all_pos_tail);

    // Free input
    free(input);

    return 0;
}
