import sys
import random
import multiprocessing
from multiprocessing import Pool

def validate_inputs(x, y, num_elements):
    """Validate the input parameters"""
    if x <= 1:
        sys.exit(f"x is invalid: {x}")
    if y <= 1:
        sys.exit(f"y is invalid: {y}")
    if not (num_elements < (x * y)):
        sys.exit("num_elements must be less than x*y")

def generate_element_connections(args):
    """Generate random connections for a single element"""
    i, names, num_elements, num_connections = args
    result = f"{names[i]}\t"
    
    # Type is either 1 or 2
    element_type = random.randint(1, 2)
    result += f"{element_type}\t"
    
    # Generate random connections
    for _ in range(num_connections):
        random_connection = random.randint(0, num_elements - 1)
        result += f"{names[random_connection]}\t"
    
    result += "END\n"
    return i, result

def main():
    # Parse command line arguments
    if len(sys.argv) < 4:
        sys.exit("Usage: python script.py x y num_elements")
    
    try:
        x = int(sys.argv[1])
        y = int(sys.argv[2])
        num_elements = int(sys.argv[3])
    except ValueError:
        sys.exit("All arguments must be integers")
    
    # Validate inputs
    validate_inputs(x, y, num_elements)
    
    num_connections = 5
    print(f"{num_elements}\t{x}\t{y}")
    
    # Create a set of names using ASCII values
    names = []
    name_char = ord('a')
    for i in range(num_elements):
        names.append(chr(name_char))
        name_char += 1
    
    # Prepare arguments for parallel processing
    args_list = [(i, names, num_elements, num_connections) for i in range(num_elements)]
    
    # Use multiprocessing to parallelize the work
    # Use number of available CPU cores
    num_processes = multiprocessing.cpu_count()
    
    with Pool(processes=num_processes) as pool:
        results = pool.map(generate_element_connections, args_list)
    
    # Sort results by index to maintain original order
    results.sort(key=lambda x: x[0])
    
    # Print results
    for _, result in results:
        print(result, end="")

if __name__ == "__main__":
    main()