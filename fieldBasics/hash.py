import hashlib


def hash_string(data, algorithm='sha256'):
    """
    Hash a string using the specified algorithm.
    
    Args:
        data: String or bytes to hash
        algorithm: Hash algorithm to use ('md5', 'sha1', 'sha256', 'sha512')
    
    Returns:
        Hexadecimal hash string
    
    Example:
        >>> hash_string("hello world")
        'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9'
    """
    if isinstance(data, str):
        data = data.encode('utf-8')
    
    if algorithm == 'md5':
        return hashlib.md5(data).hexdigest()
    elif algorithm == 'sha1':
        return hashlib.sha1(data).hexdigest()
    elif algorithm == 'sha256':
        return hashlib.sha256(data).hexdigest()
    elif algorithm == 'sha512':
        return hashlib.sha512(data).hexdigest()
    else:
        raise ValueError(f"Unsupported algorithm: {algorithm}. Use 'md5', 'sha1', 'sha256', or 'sha512'")


def simple_hash(data):
    """
    Simple hash function using Python's built-in hash() function.
    
    Args:
        data: String or object to hash
    
    Returns:
        Integer hash value
    
    Example:
        >>> simple_hash("hello world")
        4617008640573942311
    """
    return hash(data)


if __name__ == "__main__":
    # Example usage
    test_string = "hello world"
    print(f"String: {test_string}")
    print(f"MD5:    {hash_string(test_string, 'md5')}")
    print(f"SHA1:   {hash_string(test_string, 'sha1')}")
    print(f"SHA256: {hash_string(test_string, 'sha256')}")
    print(f"SHA512: {hash_string(test_string, 'sha512')}")
    print(f"Simple: {simple_hash(test_string)}")

