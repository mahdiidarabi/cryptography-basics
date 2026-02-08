import random
from math import gcd


def extended_gcd(a, b):
    """Extended Euclidean Algorithm to find modular inverse"""
    if a == 0:
        return b, 0, 1
    gcd_val, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b // a) * x1
    y = x1
    return gcd_val, x, y


def mod_inverse(a, m):
    """Find modular inverse of a mod m"""
    gcd_val, x, _ = extended_gcd(a % m, m)
    if gcd_val != 1:
        raise ValueError(f"Modular inverse does not exist for {a} mod {m}")
    return (x % m + m) % m


def is_prime(n, k=5):
    """Simple probabilistic primality test (Miller-Rabin)"""
    if n < 2:
        return False
    if n == 2 or n == 3:
        return True
    if n % 2 == 0:
        return False
    
    # Write n-1 as d * 2^r
    r = 0
    d = n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    # Witness loop
    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def generate_prime(bits=512):
    """Generate a random prime number with approximately 'bits' bits"""
    while True:
        # Generate a random odd number
        candidate = random.randrange(2**(bits-1), 2**bits)
        if candidate % 2 == 0:
            candidate += 1
        if is_prime(candidate):
            return candidate


class SimpleRSA:
    def __init__(self, p=None, q=None, d=None):
        """
        Initialize RSA with:
        - p, q: prime numbers (if None, will be generated)
        - d: secret key (private exponent, if None, will be generated)
        """
        # Generate or use provided primes
        if p is None:
            p = generate_prime(256)  # 256-bit primes for n ~512 bits
        if q is None:
            q = generate_prime(256)
        
        if not is_prime(p) or not is_prime(q):
            raise ValueError("p and q must be prime numbers")
        
        self.p = p
        self.q = q
        
        # Compute n = p * q
        self.n = p * q
        
        # Compute phi(n) = (p-1) * (q-1)
        self.phi_n = (p - 1) * (q - 1)
        
        # Generate or use provided secret key d
        if d is None:
            # Generate a valid d (must be coprime with phi(n))
            while True:
                d = random.randrange(2, self.phi_n)
                if gcd(d, self.phi_n) == 1:
                    break
        else:
            # Verify d is valid
            if gcd(d, self.phi_n) != 1:
                raise ValueError(f"d must be coprime with phi(n) = {self.phi_n}")
        
        self.d = d
        
        # Compute e = d^-1 mod phi(n) (public exponent)
        self.e = mod_inverse(self.d, self.phi_n)
    
    def encrypt(self, message):
        """Encrypt a message using public key (e, n)"""
        if isinstance(message, str):
            message = int.from_bytes(message.encode('utf-8'), 'big')
        if message >= self.n:
            raise ValueError(f"Message too large. Must be < n = {self.n}")
        return pow(message, self.e, self.n)
    
    def decrypt(self, ciphertext):
        """Decrypt a ciphertext using private key (d, n)"""
        message_int = pow(ciphertext, self.d, self.n)
        return message_int.to_bytes((message_int.bit_length() + 7) // 8, 'big').decode('utf-8')
    
    def get_public_key(self):
        """Return public key (e, n)"""
        return (self.e, self.n)
    
    def get_private_key(self):
        """Return private key (d, n)"""
        return (self.d, self.n)
    
    def __repr__(self):
        return f"SimpleRSA(p={self.p}, q={self.q}, n={self.n}, d={self.d}, e={self.e})"


# Example usage
if __name__ == "__main__":
    # Create RSA instance
    rsa = SimpleRSA()
    print("RSA Parameters:")
    print(f"p = {rsa.p}")
    print(f"q = {rsa.q}")
    print(f"n = p * q = {rsa.n}")
    print(f"phi(n) = (p-1) * (q-1) = {rsa.phi_n}")
    print(f"d (secret key) = {rsa.d}")
    print(f"e = d^-1 mod phi(n) = {rsa.e}")
    print()
    
    # Test encryption/decryption
    message = "Hello, RSA!"
    print(f"Original message: {message}")
    
    ciphertext = rsa.encrypt(message)
    print(f"Ciphertext: {ciphertext}")
    
    decrypted = rsa.decrypt(ciphertext)
    print(f"Decrypted message: {decrypted}")
    print()
    
    # Show keys
    public_key = rsa.get_public_key()
    private_key = rsa.get_private_key()
    print(f"Public key (e, n): {public_key}")
    print(f"Private key (d, n): {private_key}")
    print("\n" + "="*60)
    print("Using cryptography library RSA package:")
    print("="*60)
    
    # Using cryptography library RSA
    try:
        from cryptography.hazmat.primitives.asymmetric import rsa as crypto_rsa
        from cryptography.hazmat.primitives import serialization, hashes
        from cryptography.hazmat.primitives.asymmetric import padding
        from cryptography.hazmat.backends import default_backend
        
        # Generate RSA key pair using cryptography library
        private_key_crypto = crypto_rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=default_backend()
        )
        public_key_crypto = private_key_crypto.public_key()
        
        print("\nGenerated RSA key pair using cryptography library:")
        print(f"Key size: 2048 bits")
        print(f"Public exponent: 65537")
        
        # Get key components
        private_numbers = private_key_crypto.private_numbers()
        public_numbers = public_key_crypto.public_numbers()
        
        print(f"\nPublic key components:")
        print(f"n (modulus): {public_numbers.n}")
        print(f"e (public exponent): {public_numbers.e}")
        
        print(f"\nPrivate key components:")
        print(f"d (private exponent): {private_numbers.d}")
        print(f"p (prime 1): {private_numbers.p}")
        print(f"q (prime 2): {private_numbers.q}")
        
        # Test encryption/decryption with cryptography library
        message_bytes = b"Hello from cryptography RSA!"
        print(f"\nOriginal message: {message_bytes.decode('utf-8')}")
        
        # Encrypt with public key
        ciphertext_crypto = public_key_crypto.encrypt(
            message_bytes,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        print(f"Ciphertext (hex): {ciphertext_crypto.hex()}")
        
        # Decrypt with private key
        decrypted_crypto = private_key_crypto.decrypt(
            ciphertext_crypto,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        print(f"Decrypted message: {decrypted_crypto.decode('utf-8')}")
        
        # Serialize keys
        print("\nSerialized keys:")
        private_pem = private_key_crypto.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        public_pem = public_key_crypto.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        print("Private key (PEM):")
        print(private_pem.decode('utf-8')[:100] + "...")
        print("Public key (PEM):")
        print(public_pem.decode('utf-8')[:100] + "...")
        
    except ImportError:
        print("\nNote: cryptography library not installed.")
        print("Install it with: pip install cryptography")

