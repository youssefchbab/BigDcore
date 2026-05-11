// test.c

// Tests loops and addition
int sum_array(int arr[], int len) {
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum += arr[i];
    }
    return sum;
}

int main() {
    int arr[] = {3, 7, 2, 9, 1};
    int s = sum_array(arr, 5);       // expected: 22
    return 0;
}