#include <iostream>
#include <unistd.h>
#include <random>
#include <chrono>
#include <vector>

#define NUM_ELEMENTS 100000000 // 10 billion elements

const uint64_t seed = 42;
void flush_cache()
{
    const size_t cache_size = 1024UL * 1024 * 1024 * 2; // 1 GB
    volatile char* array = new char[cache_size];
    #pragma omp parallel for
    for (size_t i = 0; i < cache_size; ++i) {
        array[i] = i % 256;
    }
    // Prevent compiler optimization by reading from the array
    volatile char dummy = 0;
    for (size_t i = 0; i < cache_size; ++i) {
        dummy += array[i];
    }
    delete[] array;
}

int main(int argc, char** argv)
{
    size_t stride = 1;
    if (argc > 1) {
        stride = std::stoul(argv[1]);
        stride = stride / sizeof(uint64_t);
    }
    
    std::vector<uint64_t> vec(NUM_ELEMENTS);
    // align the vector to page size
    size_t page_size = 4096; // 4 KB
    size_t aligned_size = (NUM_ELEMENTS * sizeof(uint64_t) + page_size - 1) / page_size * page_size;
    vec.resize(aligned_size / sizeof(uint64_t));
    

    std::mt19937 rng(seed);
    std::uniform_int_distribution<int> dist(0, 100);
    #pragma omp parallel for
    for (size_t i = 0; i < NUM_ELEMENTS; ++i) {
        vec[i] = dist(rng);
    }

    flush_cache();

    uint64_t sum = 0;
    auto start = std::chrono::high_resolution_clock::now();
    
    for (size_t i = 0; i < NUM_ELEMENTS; i += stride) {
        sum += vec[i];
        // asm volatile("mfence" ::: "memory");
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end - start;
    std::cout << "Sum: " << sum << std::endl;
    std::cout << "Time taken: " << elapsed.count() << " seconds" << std::endl;
    std::cout << "Time taken per element: " << (elapsed.count() * 1e9 / NUM_ELEMENTS) * stride << std::endl;
}