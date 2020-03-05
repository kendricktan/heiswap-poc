from stealthaddress import *

# Alice's secret key & public key
alice_sk = random_private_key()
alice_pk = private_to_public(alice_sk)

# Bob's secret key & public key
bob_sk = random_private_key()
bob_pk = private_to_public(bob_sk)

# Shared key generation
shared_sk_alice = ecMul(bob_pk, alice_sk)
shared_sk_bob = ecMul(alice_pk, bob_sk)

same_shared_key = shared_sk_alice == shared_sk_bob

print("Generated same shared key: " + str(same_shared_key))