#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct point_struct {
    int x;
    int y;
} point_t;

typedef struct queue_struct {
    int front, rear, size;
    unsigned capacity;
    point_t* array;
} queue_t;

queue_t* createQueue(unsigned capacity)
{
    queue_t* queue = (queue_t*)malloc(sizeof(queue_t));

    // Check if the queue is created
    if (!queue){
        fprintf(stderr, "Error: Failed to create queue.");
        exit(EXIT_FAILURE);
    }

    queue->capacity = capacity;
    queue->front = queue->size = 0;
    queue->rear = capacity - 1;
    queue->array = (point_t*)malloc(queue->capacity * sizeof(point_t));

    // Check if the array is created
    if (!queue->array){
        fprintf(stderr, "Error: Failed to create queue->array.");
        exit(EXIT_FAILURE);
    }

    return queue;
}

void deleteQueue(queue_t* queue)
{
    if (queue){
        if (queue->array){
            free(queue->array);
        }
        free(queue);
    }
}

void increaseCapacity(queue_t* queue)
{
    point_t* new_array = (point_t*)malloc(queue->capacity * 2 * sizeof(point_t));

    // Check if the array is created
    if (!new_array){
        fprintf(stderr, "Error: Failed to create newArray.");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < queue->capacity; i++){
        new_array[i] = queue->array[(queue->front + i) % queue->capacity];
    }

    queue->front = 0;
    queue->capacity *= 2;
    queue->rear = queue->capacity - 1;
    
    free(queue->array);
    queue->array = new_array;
}

int isFull(queue_t* queue)
{
    return (queue->size == queue->capacity);
}

int isEmpty(queue_t* queue)
{
    return (queue->size == 0);
}

void enqueue(queue_t* queue, point_t point)
{
    if (isFull(queue)){
        increaseCapacity(queue);
    }
    queue->rear = (queue->rear + 1) % queue->capacity;
    queue->array[queue->rear] = point;
    queue->size = queue->size + 1;
}

point_t dequeue(queue_t* queue)
{
    if (isEmpty(queue)){
        fprintf(stderr, "Error: Queue is empty.");
        exit(EXIT_FAILURE);
    }
    point_t point = queue->array[queue->front];
    queue->front = (queue->front + 1) % queue->capacity;
    queue->size = queue->size - 1;
    return point;
}

typedef struct matrix {
    int* array;
    int row;
    int col;
} matrix_t;

matrix_t* createMatrix(int row, int col)
{
    matrix_t* matrix = (matrix_t*)malloc(sizeof(matrix_t));

    // Check if the matrix is created
    if (!matrix){
        fprintf(stderr, "Error: Failed to create matrix.");
        exit(EXIT_FAILURE);
    }

    matrix->row = row;
    matrix->col = col;

    matrix->array = (int*)malloc(row * col * sizeof(int));

    // Check if the array is created
    if (!matrix->array){
        fprintf(stderr, "Error: Failed to create matrix->array.");
        exit(EXIT_FAILURE);
    }

    return matrix;
}

void deleteMatrix(matrix_t* matrix)
{
    if (matrix){
        if (matrix->array){
            free(matrix->array);
        }
        free(matrix);
    }
}

void printMatrix(matrix_t* matrix)
{
    for (int i = 0; i < matrix->row; i++){
        for (int j = 0; j < matrix->col; j++){
            printf("%d\t", matrix->array[i * matrix->col + j]);
        }
        printf("\n");
    }
}

int getMatrixValue(matrix_t* matrix, int x, int y)
{
    // Check if x and y are valid
    if (x < 0 || x >= matrix->row || y < 0 || y >= matrix->col){
        fprintf(stderr, "Error: getMatrixValue - Invalid x and y.");
        exit(EXIT_FAILURE);
    }
    return matrix->array[x * matrix->col + y];
}

void setMatrixValue(matrix_t* matrix, int x, int y, int value)
{
    // Check if x and y are valid
    if (x < 0 || x >= matrix->row || y < 0 || y >= matrix->col){
        fprintf(stderr, "Error: setMatrixValue - Invalid x and y.");
        exit(EXIT_FAILURE);
    }
    matrix->array[x * matrix->col + y] = value;
}

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

int main()
{

    // read file
    //char* input = read_file("../inputs/input_day12.txt");
    char* input = strdup("Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi\n");

    // find first new line
    int n_col = strchr(input, '\n') - input;
    // length of input
    int n_row = strlen(input) / (n_col + 1);

    // create heights
    matrix_t* heights = createMatrix(n_row, n_col);

    char* c = input;
    for(int i = 0; *c != '\0'; i++, c++){
        if (*c == '\n'){
            i--;
        } else if (*c == 'E'){
            setMatrixValue(heights, i / n_col, i % n_col, 25);
        } else if (*c == 'S'){
            setMatrixValue(heights, i / n_col, i % n_col, 0);
        } else {
            setMatrixValue(heights, i / n_col, i % n_col, *c - 'a');
        }
    }


    // free input
    free(input);

    // Print heights
    printMatrix(heights);

    // free heights
    deleteMatrix(heights);

    return EXIT_SUCCESS;  
}
