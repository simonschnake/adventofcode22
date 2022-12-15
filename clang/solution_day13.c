#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

struct list
{
    union
    {
        int num;
        struct list *list;
    } value;

    bool is_list;

    struct list *next;
};

struct list *list_new_num(int num)
{
    struct list *list = malloc(sizeof(struct list));

    // Check if malloc failed
    if (list == NULL)
    {
        fprintf(stderr, "malloc failed for list\n");
        exit(EXIT_FAILURE);
    }

    list->value.num = num;
    list->is_list = false;
    list->next = NULL;
    return list;
}

struct list *list_new_list(struct list *list)
{
    struct list *new_list = malloc(sizeof(struct list));

    // Check if malloc failed
    if (new_list == NULL)
    {
        fprintf(stderr, "malloc failed for new_list\n");
        exit(EXIT_FAILURE);
    }

    new_list->value.list = list;
    new_list->is_list = true;
    new_list->next = NULL;
    return new_list;
}

void list_free(struct list *list)
{
    if (list->next != NULL)
    {
        list_free(list->next);
    }
    if (list->is_list && list->value.list != NULL)
    {
        list_free(list->value.list);
    }
    free(list);
}

struct list *parse_list(char **str)
{
    struct list *list = NULL;
    struct list *last = NULL;

    while (**str != '\0')
    {
        if (**str == ',')
        {
            (*str)++;
        }
        else if (**str == ']')
        {
            (*str)++;
            return list;
        }
        else if (**str == '[')
        {
            (*str)++;
            struct list *new_list = list_new_list(parse_list(str));
            if (list == NULL)
            {
                list = new_list;
            }
            else
            {
                last->next = new_list;
            }
            last = new_list;
        }
        else
        {
            int num = 0;
            while (**str >= '0' && **str <= '9')
            {
                num = num * 10 + (**str - '0');
                (*str)++;
            }
            struct list *new_list = list_new_num(num);
            if (list == NULL)
            {
                list = new_list;
            }
            else
            {
                last->next = new_list;
            }
            last = new_list;
        }
    }

    return list;
}

void print_list(struct list *list)
{
    printf("[");
    while (list != NULL)
    {
        if (list->is_list)
        {
            print_list(list->value.list);
        }
        else
        {
            printf("%d", list->value.num);
        }
        if (list->next != NULL)
        {
            printf(",");
        }
        list = list->next;
    }
    printf("]");
}

bool list_is_empty(struct list *list)
{
    return (list->is_list && list->value.list == NULL);
}

bool list_is_num(struct list *list)
{
    return !list->is_list;
}

struct c_str_vec
{
    char **data;
    int size;
    int capacity;
};

struct c_str_vec *c_str_vec_new(int capacity)
{
    struct c_str_vec *vec = malloc(sizeof(struct c_str_vec));

    // Check if malloc failed
    if (vec == NULL)
    {
        fprintf(stderr, "malloc failed for c_str_vec\n");
        exit(EXIT_FAILURE);
    }

    vec->data = malloc(sizeof(char *) * capacity);

    // Check if malloc failed
    if (vec->data == NULL)
    {
        fprintf(stderr, "malloc failed for c_str_vec->data\n");
        exit(EXIT_FAILURE);
    }

    vec->size = 0;
    vec->capacity = capacity;
    return vec;
}

void free_c_str_vec(struct c_str_vec *vec)
{
    free(vec->data);
    free(vec);
}

void c_str_vec_push(struct c_str_vec *vec, char *str)
{
    if (vec->size == vec->capacity)
    {
        vec->capacity *= 2;
        vec->data = realloc(vec->data, sizeof(char *) * vec->capacity);
        if (vec->data == NULL)
        {
            fprintf(stderr, "realloc failed for c_str_vec->data\n");
            exit(EXIT_FAILURE);
        }
    }
    vec->data[vec->size++] = str;
}

char *read_file(const char *filename)
{
    // Open File for reading
    FILE *fp = fopen(filename, "r");

    // Check if file was opened successfully
    if (fp == NULL)
    {
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
    if (buffer == NULL)
    {
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

bool lt(struct list *left, struct list *right)
{
    if (list_is_num(left) && list_is_num(right))
    {
        // both are numbers
        return left->value.num < right->value.num;
    }

    if (list_is_num(left))
    {
        // left is number, right is list
        // make left list
        struct list *left_list = list_new_num(left->value.num);
        left->is_list = true;
        left->value.list = left_list;
        return lt(left, right);
    }

    if (list_is_num(right))
    {
        // left is list, right is number
        // make right list
        struct list *right_list = list_new_num(right->value.num);
        right->is_list = true;
        right->value.list = right_list;
        return lt(left, right);
    }

    // both are lists


    if(list_is_empty(right) && !list_is_empty(left))
    {
        // right empty but left not
        return false;
    }
    if(list_is_empty(left) && !list_is_empty(right))
    {
        // left empty but right not
        return true;
    }
    if(list_is_empty(left) && list_is_empty(right))
    {
        // both empty
        return lt(left->next, right->next);
    }

    // both not empty
    if (lt(left->value.list, right->value.list))
    {
        return true;
    }
    if (lt(right->value.list, left->value.list))
    {
        return false;
    }
    
    return lt(left->value.list->next, right->value.list->next);
}

/*
bool lt(char *line_l, char *line_r)
{
    if (*line_l == '\0')
    {
        // strings are equal
        return true;
    }
    // skip comma
    if (*line_l == ',')
        line_l++;
    if (*line_r == ',')
        line_r++;
    // case left start with '['
    if (*line_l == '[')
    {
        if (*line_r == '[') // left and right are both lists
            return lt(line_l + 1, line_r + 1);
        if (*line_r == ']') // right is shorter
            return false;

        if (*(line_l + 1) == ']') // case left is empty
            return true;

        if (*(line_l + 2) == ']') // case left has one element
        {
            if (*line_r == *(line_l + 1))
                return lt(line_l + 3, line_r + 1);
        }

        return *(line_l + 1) < *line_r;
    }

    // case right start with '['
    if (*line_r == '[')
    {
        if (*line_l == ']') // left is shorter
            return true;
        // left is an element
        if (*(line_r + 1) == ']') // case right is empty
            return false;
        if (*(line_r + 2) == ']') // case right has one element
        {
            if (*line_l == *(line_r + 1))
                return lt(line_l + 1, line_r + 3);
            else
                return *line_l < *(line_r + 1);
        }
        return *line_l <= *(line_r + 1);
    }

    if (*line_l == ']')
    {
        if (*line_r == ']') // both are empty
            return lt(line_l + 1, line_r + 1);
        return true;
    }

    if (*line_r == ']')
        return false;

    // case both are numbers
    if (*line_l < *line_r)
        return true;
    if (*line_l > *line_r)
        return false;
    return lt(line_l + 1, line_r + 1);
}
*/

int main(int argc, char const *argv[])
{
    char *input = strdup("[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n[]\n[3]\n[[[]]]\n[[]]\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]\n");
    // char *input = read_file("../inputs/input_day13.txt");

    struct c_str_vec *lines = c_str_vec_new(10);
    char *line = strsep(&input, "\n");
    while (line != NULL)
    {
        if (strlen(line) != 0)
        {
            c_str_vec_push(lines, line);
        }
        line = strsep(&input, "\n");
    }

    int sum_idx = 0;
    bool *res = malloc(sizeof(bool) * lines->size / 2);
    // check if malloc failed
    if (res == NULL)
    {
        fprintf(stderr, "malloc failed for res\n");
        exit(EXIT_FAILURE);
    }

    for (int i = 0, j = 1; j < lines->size; i = i + 2, j = j + 2)
    {
        struct list *left = parse_list(&(lines->data[i]));
        struct list *right = parse_list(&(lines->data[j]));

        if (lt(left, right))
        {
            printf("Input %d is in right order\n", i / 2 + 1);
            res[i / 2] = true;
            sum_idx += (i / 2) + 1;
        }
        else
        {
            res[i / 2] = false;
        }

        list_free(left);
        list_free(right);
    }

    // free input
    free(input);

    for (int i = 0; i < lines->size / 2; i++)
    {
        printf("%s\n", res[i] ? "true" : "false");
    }

    printf("sum_idx: %d\n", sum_idx);

    free_c_str_vec(lines);
    free(res);

    return EXIT_SUCCESS;
}
