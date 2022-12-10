#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct vec
{
    int *values;
    size_t size;
} vec_t;

vec_t *create_vec(size_t size)
{
    vec_t *v = malloc(sizeof(vec_t));
    if (v == NULL)
    {
        printf("Error allocating memory for vector!\n");
        exit(1);
    }
    v->values = malloc(size * sizeof(size_t));
    if (v->values == NULL)
    {
        printf("Error allocating memory for vector!\n");
        exit(1);
    }
    v->size = size;
    return v;
}

vec_t *add_to_vec(vec_t *v, size_t value)
{
    v->values = realloc(v->values, (v->size + 1) * sizeof(size_t));
    if (v->values == NULL)
    {
        printf("Error allocating memory for vector!\n");
        exit(1);
    }
    v->values[v->size] = value;
    v->size++;
    return v;
}

void free_vec(vec_t *v)
{
    free(v->values);
    free(v);
}

typedef struct file
{
    char *name;
    size_t size;
    struct file **children;
    size_t num_children;
    struct file *parent;
} file_t;

file_t *create_file(char *name, size_t size)
{
    file_t *f = malloc(sizeof(file_t));
    f->name = name;
    f->size = size;
    f->children = NULL;
    f->num_children = 0;
    f->parent = NULL;
    return f;
}

void add_child(file_t *parent, file_t *child)
{
    child->parent = parent;
    parent->children = realloc(parent->children, (parent->num_children + 1) * sizeof(file_t *));
    parent->children[parent->num_children] = child;
    parent->num_children++;

    if (child->size > 0)
    {
        for (file_t *p = parent; p != NULL; p = p->parent)
        {
            p->size += child->size;
        }
    }
}

file_t *get_child(file_t *parent, char *name)
{
    for (size_t i = 0; i < parent->num_children; i++)
    {
        if (strcmp(parent->children[i]->name, name) == 0)
        {
            return parent->children[i];
        }
    }
    return NULL;
}

void free_file(file_t *f)
{
    for (size_t i = 0; i < f->num_children; i++)
    {
        free_file(f->children[i]);
    }
    free(f->children);
    free(f);
}

void add_sizes(file_t *f, vec_t *sizes)
{
    // check if dir 
    if (f->children != NULL){
        add_to_vec(sizes, f->size);
        for (size_t i = 0; i < f->num_children; i++)
        {
            add_sizes(f->children[i], sizes);
        }

    }
}

int main()
{
    // Open the file for reading
    FILE *file = fopen("../inputs/input_day07.txt", "r");

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
    char *str = malloc((size + 1) * sizeof(char));

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

    // Create the root node
    file_t *root = create_file("/", 0);
    file_t *current = root;

    // Split the string into lines
    char *line = strsep(&str, "\n");

    // Loop through the lines
    while (line != NULL)
    {
        // Print the line
        printf("%s\n", line);

        // compare line to "$ ls"
        if (strcmp(line, "$ ls") == 0)
        {
            // Do nothing
        }
        else if (strncmp(line, "$ cd", 4) == 0)
        {
            if (strcmp(line, "$ cd ..") == 0)
            {
                if (current == root)
                {
                    // Do nothing
                }
                else
                {
                    // Go up a directory
                    current = current->parent;
                }
            }
            else if (strncmp(line, "$ cd /", 8) == 0)
            {
                // Go to root
                current = root;
            }
            else
            {
                // Go down a directory
                char *name = line + 5;
                file_t *child = get_child(root, name);
                if (child == NULL)
                {
                    // Create the directory
                    child = create_file(name, 0);
                    add_child(current, child);
                }
                current = child;
            }
        }
        else if (strncmp(line, "dir", 3) == 0)
        {
            char *name = line + 4;
            file_t *child = get_child(current, name);
            if (child == NULL)
            {
                // Create the directory
                child = create_file(name, 0);
                add_child(current, child);
            }
        }
        else
        {
            // File line containing the size and the name separated by a space
            char *name = line;
            char *size_str = strsep(&name, " ");
            size_t size = (size_t)atoi(size_str);
            file_t *child = get_child(current, name);
            if (child == NULL)
            {
                // Create the file
                child = create_file(name, size);
                add_child(current, child);
            }
        }

        // Get the next line
        line = strsep(&str, "\n");

        if (line == NULL)
        {
            break;
        }
    }

    vec_t *sizes = create_vec(0);
    add_sizes(root, sizes);
    for (size_t i = 0; i < sizes->size; i++)
    {
        printf("%d ", sizes->values[i]);
    }
    printf("\n");
    size_t sum = 0;
    for (size_t i = 0; i < sizes->size; i++)
    {
        if (sizes->values[i] <= 100000){
            sum += sizes->values[i];
        }
    }
    printf("Sum: %lu\n", sum);

    // Free the vector
    free_vec(sizes);

    // Free the file
    free_file(root);

    // Free the string
    free(str);

    return 0;
}
