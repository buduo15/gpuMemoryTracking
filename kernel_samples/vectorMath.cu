#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>

__global__ void matrixAdd(int *A, int *B, int *result, int *length) {
    int threadId = blockIdx.x * blockDim.x + threadIdx.x;
    if (threadId < *length) {
        result[threadId] = A[threadId] + B[threadId];
    }
}

void runMatrixAdd() {
    srand(0);
    int length = rand() + 100; // make sure the length is at least 100
    
    // create arrays for algorithm
    int A[length];
    int B[length];
    int results[length];

    // fill arrays with random numbers
    for (int i = 0; i < length; i++) {
        A[i] = rand();
        B[i] = rand();
    }

    int *d_A;
    
    if (cudaMalloc((void**) &d_A, length * sizeof(int)) != cudaSuccess) {
        printf("Error allocating for matrix A on gpu");
        exit(-1);
    }

    if (cudaMemcpy(d_A, A, length * sizeof(int), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("Error copying matrix A onto gpu");
        exit(-1);
    }
    
    int *d_B;
    if (cudaMalloc((void**) &d_B, length * sizeof(int)) != cudaSuccess) {
        printf("Error allocating for matrix B on gpu");
        exit(-1);
    }

    if (cudaMemcpy(d_B, B, length * sizeof(int), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("Error copying matrix B onto gpu");
        exit(-1);
    }

    int *d_results;

    if (cudaMalloc((void**) &d_results, length * sizeof(int)) != cudaSuccess) {
        printf("Error allocating for results matrix on gpu");
        exit(-1);
    }

    if (cudaMemcpy(d_results, results, length * sizeof(int), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("Error copying results matrix onto gpu");
        exit(-1);
    }

    int *d_length;

    if (cudaMalloc((void**) &d_length, sizeof(int)) != cudaSuccess) {
        printf("Error allocating for length variable on gpu");
        exit(-1);
    }

    if (cudaMemcpy(d_length, &length, sizeof(int), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("Error copying length variable onto gpu");
        exit(-1);
    }

    // TODO: choose more appropriate blocks and threads
    matrixAdd<<<100,100>>>(d_A, d_B, d_results, d_length);
    cudaDeviceSynchronize();
    
    // get results back
    if (cudaMemcpy(results, d_results, length * sizeof(int), cudaMemcpyDeviceToHost) != cudaSuccess) {
        printf("error getting results back from device");
        exit(-1);
    }

    // print results
    for (int i = 0; i < length; i++) {
        printf("%d", results[i]);
        if (i+1 != length) {
            printf(", ");
        }
    }
}


int main(int argc, char** argv) {
    runMatrixAdd();
    return 0;
}
