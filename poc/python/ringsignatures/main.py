from ringsignatures import *
from binascii import unhexlify

# Length of ring
ring_signature_length = 4

# Message to sign
msg = unhexlify("abcdef")

# Secret keys & their corresponding public keys
secret_keys = [random_private_key() for i in range(ring_signature_length)]
public_keys = [private_to_public(s) for s in secret_keys]

secret_key_idx = 0
secret_key = secret_keys[0]

# Generate signature
signature = sign(msg, public_keys, secret_key, secret_key_idx)

# Verify signature
valid = verify(msg, public_keys, signature)

print("Valid signature: " + str(valid))
