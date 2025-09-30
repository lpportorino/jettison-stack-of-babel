#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[50];
    int age;
} Person;

int main() {
    printf("=== Jon-Babylon C Test ===\n");

    // Test basic C
    Person p = {"Alice", 30};
    printf("Person: %s, age %d\n", p.name, p.age);

    // Test dynamic allocation
    int *arr = (int*)malloc(5 * sizeof(int));
    for(int i = 0; i < 5; i++) {
        arr[i] = i * i;
    }
    printf("Squares: ");
    for(int i = 0; i < 5; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
    free(arr);

    printf("✓ C tests passed!\n");
    return 0;
}