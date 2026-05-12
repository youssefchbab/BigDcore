// test.c

// Tests loops and addition
int sum_array(int arr[], int len) {
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum += arr[i];
    }
    return sum;
}

// Tests recursion and stack depth
int factorial(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        int temp = 0;
        for (int j = 0; j < i; j++) {
            temp += result;  // multiply by repeated addition
        }
        result = temp;
    }
    return result;
}
// Tests pointer manipulation
int find_max(int arr[], int len) {
    int max = arr[0];
    for (int i = 1; i < len; i++) {
        if (arr[i] > max)
            max = arr[i];
    }
    return max;
}

// Tests bitwise operations
unsigned int count_bits(unsigned int n) {
    unsigned int count = 0;
    while (n) {
        count += n & 1;
        n >>= 1;
    }
    return count;
}

int main() {
    int arr[] = {3, 7, 2, 9, 1};
    int s = sum_array(arr, 5);       // expected: 22
    int f = factorial(5);             // expected: 120
    int m = find_max(arr, 5);        // expected: 9
    unsigned int b = count_bits(255); // expected: 8
    return 0;
}