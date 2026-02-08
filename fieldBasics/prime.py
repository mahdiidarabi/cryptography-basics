import math


def is_prime(n):
    """
    Check if a number is prime.
    
    Args:
        n: Integer to check
    
    Returns:
        True if n is prime, False otherwise
    """
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    
    # Check divisibility by odd numbers up to sqrt(n)
    sqrt_n = int(math.isqrt(n))
    for i in range(3, sqrt_n + 1, 2):
        if n % i == 0:
            return False
    
    return True


def find_prime_around(target):
    """
    Find a prime number around the target value.
    
    Args:
        target: Target number (e.g., 10**9)
    
    Returns:
        A prime number near the target
    """
    # Start from target and search forward
    num = target
    if num % 2 == 0:
        num += 1  # Make it odd
    
    # Search forward for a prime
    while True:
        if is_prime(num):
            return num
        num += 2  # Only check odd numbers


if __name__ == "__main__":
    import time
    
    target = 10**9 
    print(f"Searching for prime near {target:,}...")
    start_time = time.time()
    prime = find_prime_around(target)
    elapsed = time.time() - start_time
    print(f"Found prime: {prime:,}")
    print(f"Time taken: {elapsed:.4f} seconds")

