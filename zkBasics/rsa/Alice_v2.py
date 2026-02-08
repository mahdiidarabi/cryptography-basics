# pip install --trusted-host https://mirror-pypi.runflare.com -i https://mirror-pypi.runflare.com/simple/ ipython  
import rsa
import sys

def generate_keys():
    # Generate public and private keys
    (pubkey, privkey) = rsa.newkeys(1024)  # Increased to 1024 bits to support longer messages
    
    # Save keys to files
    with open('alice_public.key', 'wb') as f:
        f.write(pubkey.save_pkcs1())
    
    with open('alice_private.key', 'wb') as f:
        f.write(privkey.save_pkcs1())
    
    print("Keys generated and saved successfully")

def decrypt_message():
    # Read private key
    with open('alice_private.key', 'rb') as f:
        privkey = rsa.PrivateKey.load_pkcs1(f.read())
    
    # Read cipher text
    with open('cipher.txt', 'rb') as f:
        cipher_text = f.read()
    
    # Decrypt message
    message = rsa.decrypt(cipher_text, privkey)
    print("Decrypted message:", message.decode('utf-8'))

if __name__ == "__main__":
   
    mode = "decrypt"
    
    if mode == "generate":
        generate_keys()
    elif mode == "decrypt":
        decrypt_message()
    else:
        print("Invalid mode. Use 'generate' or 'decrypt'")