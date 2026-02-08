# ============================================================================
# HASH FUNCTION UTILITIES FOR CRYPTOGRAPHY
# ============================================================================
# Hash functions are super important in cryptography! They're used for:
# - Digital signatures (hash the message first, then sign the hash)
# - Password storage (store hash, not the actual password)
# - Message authentication codes (HMAC)
# - Blockchain and cryptocurrencies (proof of work)
# - And many more applications
# ============================================================================

import hashlib


def hash_string(data, algorithm='sha256'):
    """
    Hash a string using a cryptographic hash function.
    
    What is a hash function?
    - Takes any input (string, file, etc.) and produces a fixed-size output
    - Same input always gives same output (deterministic)
    - Small change in input causes big change in output (avalanche effect)
    - Should be one-way (hard to reverse)
    - Should be collision-resistant (hard to find two inputs with same hash)
    
    Common hash algorithms:
    - MD5: Old, fast, but broken (don't use for security!)
    - SHA1: Also broken, don't use for new systems
    - SHA256: Currently secure, widely used (Bitcoin uses this!)
    - SHA512: More secure, but slower
    
    Args:
        data: The string or bytes to hash
        algorithm: Which hash algorithm to use
                   Options: 'md5', 'sha1', 'sha256', 'sha512'
    
    Returns:
        Hexadecimal string representing the hash
        Example: "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
    """
    # Convert string to bytes if needed
    # Hash functions work on bytes, not strings
    if isinstance(data, str):
        data = data.encode('utf-8')
    
    # Choose the hash algorithm and compute the hash
    if algorithm == 'md5':
        # MD5: 128-bit hash (32 hex characters)
        # WARNING: MD5 is broken! Don't use for security-critical applications
        return hashlib.md5(data).hexdigest()
    
    elif algorithm == 'sha1':
        # SHA1: 160-bit hash (40 hex characters)
        # WARNING: SHA1 is also broken! Don't use for new systems
        return hashlib.sha1(data).hexdigest()
    
    elif algorithm == 'sha256':
        # SHA256: 256-bit hash (64 hex characters)
        # This is the one you should use! It's secure and widely used.
        # Bitcoin uses SHA256 for proof-of-work
        return hashlib.sha256(data).hexdigest()
    
    elif algorithm == 'sha512':
        # SHA512: 512-bit hash (128 hex characters)
        # Even more secure than SHA256, but slower
        return hashlib.sha512(data).hexdigest()
    
    else:
        raise ValueError(f"Unsupported algorithm: {algorithm}. Use 'md5', 'sha1', 'sha256', or 'sha512'")


def simple_hash(data):
    """
    Simple hash function using Python's built-in hash().
    
    WARNING: This is NOT cryptographically secure!
    - It's fast, but not secure
    - Can be reversed or collisions can be found easily
    - Only use for non-security purposes (like hash tables)
    
    In real cryptography, always use proper hash functions like SHA256!
    
    Args:
        data: String or object to hash
    
    Returns:
        Integer hash value
    """
    return hash(data)


if __name__ == "__main__":
    # Test the hash functions
    test_string = "hello world"
    
    print(f"String: {test_string}")
    print()
    print("Hash values:")
    print(f"MD5:    {hash_string(test_string, 'md5')}")
    print(f"SHA1:   {hash_string(test_string, 'sha1')}")
    print(f"SHA256: {hash_string(test_string, 'sha256')}")
    print(f"SHA512: {hash_string(test_string, 'sha512')}")
    print()
    print(f"Simple (not secure!): {simple_hash(test_string)}")
