"""
Stealth addresses in bitcoin

Basically a diffie-hellman with extra steps
"""

import math
import web3
import hashlib
import functools
import ecdsa

from random import randint
from web3 import Web3

from typing import Tuple, List, Union

from py_ecc import bn128
from py_ecc.bn128 import FQ, add, multiply, double

# Signature :: (Initial construction value, array of public keys, link of unique signer)
Point = Tuple[int, int]
Signature = Tuple[int, List[int], Point]
Scalar = int

asint = lambda x: x.n if isinstance(x, bn128.FQ) else x
fq2point = lambda x: (asint(x[0]), asint(x[1]))
randsn = lambda: randint(1, N - 1)
randsp = lambda: randint(1, P - 1)
sbmul = lambda s: bn128.multiply(G, asint(s))
addmodn = lambda x, y: (x + y) % N
addmodp = lambda x, y: (x + y) % P
mulmodn = lambda x, y: (x * y) % N
mulmodp = lambda x, y: (x * y) % P
submodn = lambda x, y: (x - y) % N
submodp = lambda x, y: (x - y) % P
negp = lambda x: (x[0], -x[1])


G: Point = fq2point(bn128.G1)
N: int = bn128.curve_order
P: int = bn128.field_modulus
A: int = 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52
MASK: int = 0x8000000000000000000000000000000000000000000000000000000000000000


def random_private_key() -> int:
    return randsp()
    

def private_to_public(k: int) -> Tuple[int, int]:
    return ecMul(G, k)


def hash_int(i: int) -> int:
    """
    Hashes int and returns 
    """
    b = "0x" + i.encode('utf-8').hex()

    return int(
        Web3.soliditySha3(["bytes"], [b]).hex(),
        16
     ) % N


def decode_int(b: bytes) -> int:
    return int(b, 16)


def ecMul(p: Point, x: int) -> Point:
    pt = FQ(p[0]), FQ(p[1])
    return fq2point(multiply(pt, x))


def ecAdd(p1: Point, p2: Point) -> Point:
    p1 = FQ(p1[0]), FQ(p1[1])
    p2 = FQ(p2[0]), FQ(p2[1])
    return fq2point(add(p1, p2))


def serialize(*args) -> bytes:
    """
    Helper function

    Serializes all supplied arguments into bytes
    """
    b = b""

    for i in range(len(args)):
        if type(args[i]) is int:
            b += args[i].to_bytes(32, 'big')
        elif type(args[i]) is Point:
            b += args[i].x().to_bytes(32, 'big')
            b += args[i].y().to_bytes(32, 'big')
        elif type(args[i]) is str:
            b += args[i].encode('utf-8')
        elif type(args[i]) is bytes:
            b += args[i]
        elif type(args[i]) is list:
            b += serialize(*args[i])

    return b


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
