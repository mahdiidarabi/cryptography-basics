def integer_sqrt(n):
    """
    Calculate integer square root of n using binary search.
    
    Args:
        n: Non-negative integer
    
    Returns:
        Largest integer x such that x*x <= n
    """
    if n == 0:
        return 0
    if n == 1:
        return 1
    
    left = 1
    right = n
    
    while left <= right:
        mid = (left + right) // 2
        square = mid * mid
        
        if square == n:
            return mid
        elif square < n:
            left = mid + 1
        else:
            right = mid - 1
    
    return right


def factorize(n):
    """
    Factorize a number into its prime factors.
    Implemented without using any libraries or built-in functions.
    
    Args:
        n: Integer to factorize
    
    Returns:
        Dictionary with prime factors as keys and their powers as values
    
    Example:
        >>> factorize(12)
        {2: 2, 3: 1}
    """
    if n < 1:
        raise ValueError("Number must be positive")
    if n == 1:
        return {}
    
    factors = {}
    original_n = n
    
    # Check for factor 2
    count_2 = 0
    while n % 2 == 0:
        count_2 = count_2 + 1
        n = n // 2
    if count_2 > 0:
        factors[2] = count_2
    
    # Check for odd factors
    sqrt_n = integer_sqrt(n)
    i = 3
    while i <= sqrt_n:
        count_i = 0
        while n % i == 0:
            count_i = count_i + 1
            n = n // i
        if count_i > 0:
            factors[i] = count_i
            sqrt_n = integer_sqrt(n)
        i = i + 2
    
    # If n is still greater than 1, it's a prime factor
    if n > 1:
        if n in factors:
            factors[n] = factors[n] + 1
        else:
            factors[n] = 1
    
    return factors


def number_to_string(num):
    """
    Convert a number to string manually without using str().
    """
    if num == 0:
        return "0"
    
    digits = []
    n = num
    while n > 0:
        digits.append(n % 10)
        n = n // 10
    
    result = ""
    for i in range(len(digits) - 1, -1, -1):
        result = result + chr(ord('0') + digits[i])
    
    return result


def get_prime_factors(n):
    """
    Get only the prime factors of a number (without their powers).
    Uses the factorize function.
    
    Args:
        n: Integer to factorize
    
    Returns:
        List of prime factors (e.g., [2, 3] for 144)
    
    Example:
        >>> get_prime_factors(144)
        [2, 3]
        >>> get_prime_factors(12)
        [2, 3]
        >>> get_prime_factors(7)
        [7]
    """
    factors = factorize(n)
    
    if len(factors) == 0:
        return []
    
    # Extract prime factors (keys from the dictionary)
    primes = []
    for prime in factors:
        primes.append(prime)
    
    # Sort primes manually using bubble sort
    for i in range(len(primes)):
        for j in range(len(primes) - 1 - i):
            if primes[j] > primes[j + 1]:
                temp = primes[j]
                primes[j] = primes[j + 1]
                primes[j + 1] = temp
    
    return primes


def format_factorization(n):
    """
    Get the prime factorization of a number in formatted string format.
    Implemented without using libraries or built-in functions like str().
    
    Args:
        n: Integer to factorize
    
    Returns:
        Formatted string representation (e.g., "2^2 * 3")
    
    Example:
        >>> format_factorization(12)
        '2^2 * 3'
        >>> format_factorization(8)
        '2^3'
        >>> format_factorization(7)
        '7'
    """
    factors = factorize(n)
    
    if len(factors) == 0:
        return "1"
    
    # Sort primes manually using bubble sort
    primes = []
    for prime in factors:
        primes.append(prime)
    
    for i in range(len(primes)):
        for j in range(len(primes) - 1 - i):
            if primes[j] > primes[j + 1]:
                temp = primes[j]
                primes[j] = primes[j + 1]
                primes[j + 1] = temp
    
    # Build result string
    parts = []
    for prime in primes:
        power = factors[prime]
        prime_str = number_to_string(prime)
        
        if power == 1:
            parts.append(prime_str)
        else:
            power_str = number_to_string(power)
            parts.append(prime_str + "^" + power_str)
    
    # Join parts with " * " manually
    result = ""
    for i in range(len(parts)):
        if i > 0:
            result = result + " * "
        result = result + parts[i]
    
    return result


def divide_prime_by_factors_of_p_minus_one(P):
    """
    Get a prime number P, calculate prime factors of (P-1),
    then return (P-1) divided by each prime factor of (P-1).
    
    Uses get_prime_factors function.
    
    Args:
        P: Prime number
    
    Returns:
        List of (P-1) divided by each prime factor of (P-1)
    
    Example:
        >>> divide_prime_by_factors_of_p_minus_one(7)
        [3.0, 2.0]  # 6/2 and 6/3, since 6 = 2 * 3
        >>> divide_prime_by_factors_of_p_minus_one(11)
        [5.0, 2.0]  # 10/2 and 10/5, since 10 = 2 * 5
    """
    # Calculate P-1
    p_minus_one = P - 1
    
    # Get prime factors of (P-1)
    factors = get_prime_factors(p_minus_one)
    
    # Calculate (P-1) divided by each factor
    results = []
    for factor in factors:
        result = p_minus_one / factor
        results.append(result)
    
    return results


def modular_power(base, exponent, modulus):
    """
    Calculate (base^exponent) mod modulus using fast exponentiation.
    Implemented manually without using libraries.
    
    Args:
        base: Base number
        exponent: Exponent (should be integer)
        modulus: Modulus
    
    Returns:
        (base^exponent) mod modulus
    """
    if modulus == 1:
        return 0
    
    result = 1
    base = base % modulus
    
    # Convert exponent to integer if it's a float
    exp = int(exponent)
    
    while exp > 0:
        if exp % 2 == 1:
            result = (result * base) % modulus
        exp = exp // 2
        base = (base * base) % modulus
    
    return result


def find_generators(P):
    """
    Find generators of the multiplicative group modulo P.
    
    A generator g satisfies: g^((P-1)/q) != 1 (mod P) for all prime factors q of (P-1).
    
    Uses divide_prime_by_factors_of_p_minus_one(P) and checks for each i from 1 to P-1.
    
    Args:
        P: Prime number
    
    Returns:
        List of generators (primitive roots) modulo P
    
    Example:
        >>> find_generators(7)
        [3, 5]  # Generators of Z_7*
    """
    # Get (P-1) divided by each prime factor of (P-1)
    divisors = divide_prime_by_factors_of_p_minus_one(P)
    
    # Convert divisors to integers (they should be integers)
    int_divisors = []
    for d in divisors:
        int_divisors.append(int(d))
    
    generators = []
    
    # Iterate from 1 to P-1
    for i in range(1, P):
        is_generator = True
        
        # Check if i^divisor mod P != 1 for all divisors
        for divisor in int_divisors:
            power_result = modular_power(i, divisor, P)
            if power_result == 1:
                is_generator = False
                break
        
        # If all powers are not 1, i is a generator
        if is_generator:
            generators.append(i)
    
    return generators


if __name__ == "__main__":
    # Example usage
    test_numbers = [2003]
    
    print("=== Prime Factorization ===\n")
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

