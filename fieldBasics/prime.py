import math

# ============================================================================
# PRIME NUMBER UTILITIES FOR CRYPTOGRAPHY
# ============================================================================
# In cryptography, we need prime numbers for:
# - Creating finite fields (like GF(p) where p is prime)
# - RSA encryption (uses large primes)
# - Diffie-Hellman key exchange (needs prime modulus)
# - Elliptic curve cryptography (works over prime fields)
# ============================================================================


def is_prime(n):
    """
    Check if a number is prime.
    
    A prime number is only divisible by 1 and itself.
    This is super important in crypto because we need primes for secure systems!
    
    Args:
        n: The number we want to check
    
    Returns:
        True if n is prime, False otherwise
    """
    # Numbers less than 2 are not prime (by definition)
    if n < 2:
        return False
    
    # 2 is the only even prime number
    if n == 2:
        return True
    
    # If n is even (and not 2), it's not prime
    # This saves us time - we don't need to check even numbers
    if n % 2 == 0:
        return False
    
    # Now we check if n is divisible by any odd number from 3 to sqrt(n)
    # Why sqrt(n)? Because if n has a factor larger than sqrt(n),
    # it must also have a factor smaller than sqrt(n)
    # Example: 100 = 10 * 10, so we only need to check up to 10
    sqrt_n = int(math.isqrt(n))
    
    # Check only odd numbers (we already checked 2)
    for i in range(3, sqrt_n + 1, 2):
        # If n is divisible by i, it's not prime
        if n % i == 0:
            return False
    
    # If we got here, n is prime!
    return True


def find_prime_around(target):
    """
    Find a prime number near a target value.
    
    In crypto, we often need primes of a specific size.
    For example, RSA-2048 needs primes around 2^1024.
    
    Args:
        target: The number we want to find a prime near
    
    Returns:
        A prime number >= target
    """
    # Start from the target number
    num = target
    
    # If target is even, make it odd (primes > 2 are always odd)
    if num % 2 == 0:
        num += 1
    
    # Keep checking numbers until we find a prime
    # This is a simple approach - in real crypto, we use more sophisticated methods
    while True:
        if is_prime(num):
            return num
        # Only check odd numbers (skip even ones)
        num += 2


if __name__ == "__main__":
    # Test the functions
    import time
    
    # Try to find a prime near 1 billion
    target = 10**15 
    print(f"Searching for prime near {target:,}...")
    
    start_time = time.time()
    prime = find_prime_around(target)
    elapsed = time.time() - start_time
    
    print(f"Found prime: {prime:,}")
    print(f"Time taken: {elapsed:.4f} seconds")
