import rsa
import sys

def encrypt_message():
    # Read Alice's public key
    with open('alice_public.key', 'rb') as f:
        pubkey = rsa.PublicKey.load_pkcs1(f.read())
    
    # Hardcoded message
    message = "Hello Alice! This is a secret message.       0111111111111111122222ffffffffffffffffffffffffffffffffffffffffff"
    
    # Encrypt message
    cipher_text = rsa.encrypt(message.encode('utf-8'), pubkey)
    
    # Save cipher text
    with open('cipher.txt', 'wb') as f:
        f.write(cipher_text)
    
    print("Message encrypted and saved to cipher.txt")

if __name__ == "__main__":
    encrypt_message()