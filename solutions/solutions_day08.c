#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct matrix {
    int rows;
    int cols;
    int *data;
} matrix;

matrix *matrix_create(int rows, int cols) {
    matrix *m = malloc(sizeof(matrix));

    m->rows = rows;
    m->cols = cols;
    m->data = malloc(cols * rows * sizeof(int *));
    return m;
}

void free_matrix(matrix *m) {
    free(m->data);
    free(m);
}

int* get_row(matrix *m, int row) {
    int* res = malloc(m->cols * sizeof(int));
    for (int i = 0; i < m->cols; i++) {
        res[i] = m->data[row * m->cols + i];
    }
    return res;
}

int* get_col(matrix *m, int col) {
    int* res = malloc(m->rows * sizeof(int));
    for (int i = 0; i < m->rows; i++) {
        res[i] = m->data[i * m->cols + col];
    }
    return res;
}

int is_visible(int* row, int idx, int n) {
    if (idx == 0 || idx == n - 1) {
        return 1;
    }
    int left = 1;
    int right = 1;
    int val = row[idx];
    for(int i = idx - 1; i >= 0; i--) {
        if (row[i] >= val) {
            left = 0;
            break;
        }
    }
    for(int i = idx + 1; i < n; i++) {
        if (row[i] >= val) {
            right = 0;
            break;
        }
    }

    return left || right;
}

int viewing_distance(int* row, int idx, int n) {
    int left = 0;
    int right = 0;
    int val = row[idx];
    for(int i = idx - 1; i >= 0; i--) {
        left++;
        if (row[i] >= val) {
            break;
        }
    }
    for(int i = idx + 1; i < n; i++) {
        right++;
        if (row[i] >= val) {
            break;
        }
    }

    return left * right;
}

void print_matrix(matrix *m) {
    for (int i = 0; i < m->rows; i++) {
        for (int j = 0; j < m->cols; j++) {
            printf("%d ", m->data[i * m->cols + j]);
        }
        printf("\n");
    }
    printf("\n");
}

int sum_matrix(matrix *m) {
    int sum = 0;
    for (int i = 0; i < m->rows; i++) {
        for (int j = 0; j < m->cols; j++) {
            sum += m->data[i * m->cols + j];
        }
    }
    return sum;
}

int max_matrix(matrix *m) {
    int max = 0;
    for (int i = 0; i < m->rows; i++) {
        for (int j = 0; j < m->cols; j++) {
            if (m->data[i * m->cols + j] > max) {
                max = m->data[i * m->cols + j];
            }
        }
    }
    return max;
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

    // test string
    //char* str = strdup("30373\n25512\n65332\n33549\n35390");
    char* str = read_file("../inputs/input_day08.txt");

    int n_elem = strlen(str);
    
    // get first line
    char* line = strsep(&str, "\n");
    int n_cols = strlen(line);
    int n_rows = n_elem / (n_cols + 1);

    matrix *m = matrix_create(n_rows, n_cols);
    for(int i = 0; i < n_rows; i++) {
        for(int j = 0; j < n_cols; j++) {
            m->data[i * n_cols + j] = line[j] - '0';
        }
        line = strsep(&str, "\n");
    }

    // free str
    free(str);

    // print matrix
    print_matrix(m);
    

    matrix *result_matrix = matrix_create(n_rows, n_cols);

    for(int i = 0; i < n_rows; i++) {
        for(int j = 0; j < n_cols; j++) {
            int* row = get_row(m, i);
            int* col = get_col(m, j);
            int visible = is_visible(row, j, n_cols) || is_visible(col, i, n_rows);
            result_matrix->data[i * n_cols + j] = visible;
            free(row);
            free(col);
        }
    }

    // print result matrix
    print_matrix(result_matrix);

    printf("\n Sum: %d\n", sum_matrix(result_matrix));

    matrix *result_matrix2 = matrix_create(n_rows, n_cols);

    for(int i = 0; i < n_rows; i++) {
        for(int j = 0; j < n_cols; j++) {
            int* row = get_row(m, i);
            int* col = get_col(m, j);
            int visible = viewing_distance(row, j, n_cols) * viewing_distance(col, i, n_rows);
            result_matrix2->data[i * n_cols + j] = visible;
            free(row);
            free(col);
        }
    }

    // print result matrix
    // print_matrix(result_matrix2);

    printf("\n Max: %d\n", max_matrix(result_matrix2));

    // free matrix
    free_matrix(m);
    free_matrix(result_matrix);

    return 0;
    
}
