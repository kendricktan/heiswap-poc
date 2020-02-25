from stealthaddress import *

# Alice's secret key & public key
alice_sk = randsp()
alice_pk = ecMul(G, alice_sk)

# Bob's secret key
bob_sk = randsp()
bob_pk = ecMul(G, bob_sk)

# Alice generates a stealth address for Bob
random_sk = randsp()
random_pk = ecMul(G, random_sk)

d = ecMul(bob_pk, random_sk)

# Hash d to make it unlinkable
stealth_sk = decode_int(
    Web3.soliditySha3(["bytes"], ["0x" + serialize(d).hex()]).hex()
)
stealth_address = ecMul(G, stealth_sk)

# Alice publishes the stealth_pk along with the random_pk

# Given the random_pk and the stealth_pk
# Bob checks if the stealth address belongs to him
bob_d = ecMul(random_pk, bob_sk)
bob_stealth_sk = decode_int(
    Web3.soliditySha3(["bytes"], ["0x" + serialize(bob_d).hex()]).hex()
)
bob_stealth_address = ecMul(G, bob_stealth_sk)

assert bob_stealth_address == stealth_address

# Construct the one-time private key associated with the stealth address
assert ecMul(G, bob_stealth_sk) == stealth_address
assert ecMul(G, stealth_sk) == bob_stealth_address
