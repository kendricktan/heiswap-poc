"""
Stealth addresses in bitcoin

Basically a diffie-hellman with extra steps
"""

import hashlib
import functools
import ecdsa

from typing import Tuple, List, Union

from ecdsa import numbertheory, ellipticcurve
from ecdsa.curves import SECP256k1
from ecdsa.ecdsa import curve_secp256k1
from ecdsa.ellipticcurve import Point
from ecdsa.util import string_to_number, number_to_string, randrange

G = SECP256k1.generator
P = SECP256k1.order
hash_function = hashlib.sha256

Scalar = int


def hash_int(i: int) -> int:
    """
    Hashes int and returns 
    """
    return int(hash_function(str(i).encode('utf-8')).hexdigest(), 16)


def decode_int(b: bytes) -> int:
    return int(b, 16)


def random_scalar() -> Scalar:
    """
    Helper function

    Returns a random scalar (secret key)
    """
    return randrange(SECP256k1.order)


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
alice_sk = random_scalar()
alice_pk = G * alice_sk

# Bob's secret key
bob_sk = random_scalar()
bob_pk = G * bob_sk

# Alice generates a stealth address for Bob
random_sk = random_scalar()
random_pk = G * random_sk

d_partial = random_sk * bob_pk
# This has to do with n==0 mod 8 by definition, c.f.
# the top paragraph of page 5 of http://cr.yp.to/ecdh/curve25519-20060209.pdf
d = d_partial * 8

# Hash d to make it unlinkable
stealth_sk = decode_int(
    hash_function(serialize(d)).hexdigest()
)
stealth_address = G * stealth_sk

# Alice publishes the stealth_pk along with the random_pk

# Given the random_pk and the stealth_pk
# Bob checks if the stealth address belongs to him
bob_d_partial = bob_sk * random_pk
bob_d = bob_d_partial * 8
bob_stealth_sk = decode_int(
    hash_function(serialize(bob_d)).hexdigest()
)
bob_stealth_address = G * bob_stealth_sk

assert bob_stealth_address == stealth_address

# Construct the one-time private key associated with the stealth address
assert G * bob_stealth_sk == stealth_address
assert G * stealth_sk == bob_stealth_address