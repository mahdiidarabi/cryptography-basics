# ============================================================================
# GENERATOR AND FACTORIZATION UTILITIES FOR CRYPTOGRAPHY
# ============================================================================
# Generators (also called primitive roots) are super important in crypto!
# They help us create cyclic groups which are used in:
# - Diffie-Hellman key exchange
# - ElGamal encryption
# - Digital signatures (DSA)
# - And many other protocols
# ============================================================================

import math


def factorize(n):
    """
    Factorize a number into its prime factors with their powers.
    
    Example: 12 = 2^2 * 3^1, so we return {2: 2, 3: 1}
    
    Why is this important in crypto?
    - We need to factorize (P-1) to find generators
    - The security of RSA depends on factoring being hard
    - Understanding factors helps us understand group structure
    
    Args:
        n: The number to factorize (must be positive)
    
    Returns:
        Dictionary: {prime_factor: power, ...}
        Example: factorize(12) returns {2: 2, 3: 1}
    """
    if n < 1:
        raise ValueError("Number must be positive")
    
    # 1 has no prime factors
    if n == 1:
        return {}
    
    # This dictionary will store our factors: {prime: power}
    factors = {}
    
    # Step 1: Check if 2 is a factor (handle even numbers)
    # We do this separately because 2 is the only even prime
    count_2 = 0
    while n % 2 == 0:
        count_2 += 1
        n = n // 2  # Divide n by 2
    
    # If we found some 2's, add them to our factors
    if count_2 > 0:
        factors[2] = count_2
    
    # Step 2: Check odd factors from 3 onwards
    # We only need to check up to sqrt(n) because:
    # If n = a * b and both a and b > sqrt(n), then a * b > n (impossible!)
    sqrt_n = int(math.isqrt(n))
    i = 3  # Start from 3 (first odd prime after 2)
    
    while i <= sqrt_n:
        count_i = 0
        
        # Count how many times i divides n
        while n % i == 0:
            count_i += 1
            n = n // i
        
        # If i is a factor, add it to our dictionary
        if count_i > 0:
            factors[i] = count_i
            # Update sqrt_n because n got smaller
            sqrt_n = int(math.isqrt(n))
        
        # Move to next odd number
        i += 2
    
    # Step 3: If n is still > 1, it's a prime factor itself
    # This happens when n is prime or has one large prime factor
    if n > 1:
        if n in factors:
            factors[n] += 1
        else:
            factors[n] = 1
    
    return factors


def get_prime_factors(n):
    """
    Get only the prime factors (without their powers).
    
    Example: 12 = 2^2 * 3^1, so we return [2, 3] (not [2, 2, 3])
    
    This is useful when we only care about which primes divide n,
    not how many times.
    
    Args:
        n: The number to factorize
    
    Returns:
        List of prime factors (sorted)
    """
    # First get the full factorization
    factors_dict = factorize(n)
    
    # If no factors, return empty list
    if len(factors_dict) == 0:
        return []
    
    # Extract just the prime numbers (keys of the dictionary)
    primes = list(factors_dict.keys())
    
    # Sort them (simple approach - in real code we'd use sorted())
    # Using bubble sort because it's simple to understand
    for i in range(len(primes)):
        for j in range(len(primes) - 1 - i):
            if primes[j] > primes[j + 1]:
                # Swap them
                temp = primes[j]
                primes[j] = primes[j + 1]
                primes[j + 1] = temp
    
    return primes


def format_factorization(n):
    """
    Get the prime factorization as a nice string.
    
    Example: format_factorization(12) returns "2^2 * 3"
    
    This is just for display purposes - makes it easier to read.
    
    Args:
        n: The number to factorize
    
    Returns:
        String like "2^2 * 3" or "7" or "2^3"
    """
    factors = factorize(n)
    
    # Special case: 1 has no factors
    if len(factors) == 0:
        return "1"
    
    # Sort the primes
    primes = sorted(factors.keys())
    
    # Build the string
    parts = []
    for prime in primes:
        power = factors[prime]
        if power == 1:
            # If power is 1, just write the prime (e.g., "3" not "3^1")
            parts.append(str(prime))
        else:
            # If power > 1, write it with exponent (e.g., "2^2")
            parts.append(f"{prime}^{power}")
    
    # Join all parts with " * "
    return " * ".join(parts)


def modular_power(base, exponent, modulus):
    """
    Calculate (base^exponent) mod modulus using fast exponentiation.
    
    This is SUPER important in cryptography! We use it everywhere:
    - RSA encryption/decryption
    - Diffie-Hellman key exchange
    - Digital signatures
    - And many more...
    
    Why "fast" exponentiation? Instead of multiplying base by itself
    exponent times (which is slow), we use binary method.
    
    Example: 3^13 mod 7
    - Normal way: 3 * 3 * 3 * ... * 3 (13 times) = too slow!
    - Fast way: Use binary representation of 13 = 1101
      We compute 3^1, 3^2, 3^4, 3^8 and combine them
    
    Args:
        base: The base number
        exponent: The power to raise base to
        modulus: The modulus (usually a prime in crypto)
    
    Returns:
        (base^exponent) mod modulus
    """
    # Special case: anything mod 1 is 0
    if modulus == 1:
        return 0
    
    # Start with result = 1
    result = 1
    
    # Reduce base modulo modulus first (makes numbers smaller)
    base = base % modulus
    
    # Make sure exponent is an integer
    exp = int(exponent)
    
    # Fast exponentiation algorithm (also called "square and multiply")
    # The idea: write exponent in binary, then square base repeatedly
    while exp > 0:
        # If current bit is 1, multiply result by base
        if exp % 2 == 1:
            result = (result * base) % modulus
        
        # Square the base (this corresponds to next bit in binary)
        base = (base * base) % modulus
        
        # Move to next bit (divide exponent by 2)
        exp = exp // 2
    
    return result


def divide_prime_by_factors_of_p_minus_one(P):
    """
    Calculate (P-1) divided by each prime factor of (P-1).
    
    This is a key step in finding generators (primitive roots)!
    
    Why do we need this?
    - To check if a number g is a generator, we need to verify:
      g^((P-1)/q) != 1 (mod P) for all prime factors q of (P-1)
    - So we need to compute (P-1)/q for each prime factor q
    
    Example: P = 7
    - P-1 = 6
    - Prime factors of 6: [2, 3]
    - (P-1)/2 = 6/2 = 3
    - (P-1)/3 = 6/3 = 2
    - So we return [3, 2]
    
    Args:
        P: A prime number
    
    Returns:
        List of (P-1)/q for each prime factor q of (P-1)
    """
    # Calculate P-1
    # In finite fields, P-1 is the size of the multiplicative group
    p_minus_one = P - 1
    
    # Get all prime factors of (P-1)
    prime_factors = get_prime_factors(p_minus_one)
    
    # Calculate (P-1) divided by each factor
    results = []
    for factor in prime_factors:
        result = p_minus_one // factor  # Integer division
        results.append(result)
    
    return results


def find_generators(P):
    """
    Find all generators (primitive roots) of the multiplicative group modulo P.
    
    This is one of the most important functions in this file!
    
    What is a generator?
    - A generator g is a number such that {g^0, g^1, g^2, ..., g^(P-2)} 
      gives us ALL numbers from 1 to P-1
    - In other words, g "generates" the entire multiplicative group
    
    Why are generators important in crypto?
    - Diffie-Hellman uses generators for key exchange
    - ElGamal encryption needs generators
    - Many protocols rely on generators
    
    How do we find generators?
    - A number g is a generator if: g^((P-1)/q) != 1 (mod P)
      for ALL prime factors q of (P-1)
    - This is based on Lagrange's theorem from group theory
    
    Example: P = 7
    - P-1 = 6, prime factors of 6: [2, 3]
    - We need to check: g^(6/2) = g^3 != 1 and g^(6/3) = g^2 != 1
    - Generators of Z_7*: [3, 5]
    
    Args:
        P: A prime number
    
    Returns:
        List of all generators (primitive roots) modulo P
    """
    # Get (P-1)/q for each prime factor q of (P-1)
    # These are the exponents we need to check
    divisors = divide_prime_by_factors_of_p_minus_one(P)
    
    # Convert to integers (they should already be integers, but just to be safe)
    int_divisors = [int(d) for d in divisors]
    
    # This list will store all generators we find
    generators = []
    
    # Check every number from 1 to P-1
    # (0 is not in the multiplicative group, so we start from 1)
    for candidate in range(1, P):
        is_generator = True
        
        # Check if candidate^divisor mod P != 1 for all divisors
        # If ANY divisor gives us 1, then candidate is NOT a generator
        for divisor in int_divisors:
            power_result = modular_power(candidate, divisor, P)
            
            # If we get 1, this candidate is not a generator
            # (it means the order of candidate is smaller than P-1)
            if power_result == 1:
                is_generator = False
                break  # No need to check other divisors
        
        # If all checks passed, candidate is a generator!
        if is_generator:
            generators.append(candidate)
    
    return generators


if __name__ == "__main__":
    # Test the functions
    print("=== Prime Factorization ===\n")
    test_numbers = [2003]
    for num in test_numbers:
        result = format_factorization(num)
        print(f"{num:4d} = {result}")
    
    print("\n=== Prime Factors Only ===\n")
    for num in test_numbers:
        primes = get_prime_factors(num)
        print(f"{num:4d} -> {primes}")
    
    print("\n=== (P-1) / (Prime Factors of P-1) ===\n")
    test_primes = [97]
    for P in test_primes:
        factors_of_p_minus_one = get_prime_factors(P - 1)
        results = divide_prime_by_factors_of_p_minus_one(P)
        print(f"P = {P}")
        print(f"  P-1 = {P-1}, Prime factors: {factors_of_p_minus_one}")
        print(f"  (P-1) / (each factor): {results}")
        print()
    
    print("\n=== Generators (Primitive Roots) ===\n")
    for P in test_primes:
        generators = find_generators(P)
        print(f"P = {P}")
        print(f"  Generators: {generators}")
        print()
