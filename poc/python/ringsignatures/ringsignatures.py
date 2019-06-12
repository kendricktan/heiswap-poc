"""
Provide an implementation of Linkable Spontaneus Anonymous Group Signature
over elliptic curve cryptography.

Original paper: https://eprint.iacr.org/2004/027.pdf
"""

import web3
import hashlib
import functools
import ecdsa

from web3 import Web3

from typing import Tuple, List, Union

from ecdsa import numbertheory, ellipticcurve
from ecdsa.curves import SECP256k1
from ecdsa.ecdsa import int_to_string, string_to_int
from ecdsa.ellipticcurve import Point
from ecdsa.util import string_to_number, number_to_string, randrange


G = SECP256k1.generator
N = SECP256k1.order
P = SECP256k1.curve.p()
MASK = 0x8000000000000000000000000000000000000000000000000000000000000000
hash_function = hashlib.sha3_256

# to_hex


def print_hex(x):
    if type(x) is int:
        print("0x" + (x).to_bytes(32, 'big').hex())
    elif type(x) is Point:
        print("X: 0x" + (x.x()).to_bytes(32, 'big').hex())
        print("Y: 0x" + (x.y()).to_bytes(32, 'big').hex())


# Signature :: (Initial construction value, array of public keys, link of unique signer)
Signature = Tuple[int, List[Point], Point]
Scalar = int


def contains_point(x, y):
    """
    Does the point (x, y) exists on the curve?
    """
    # SECP256k1's a = 0
    # SECP256k1's b = 7
    # return (y * y - (x * x * x + A * x + B)) % P == 0
    return (pow(y, 2) - (pow(x, 3) + 7)) % P == 0


def compress_point(p: Point) -> int:
    """
    Compresses a point
    """
    x = p.x()

    if (p.y() & 0x1 == 0x1):
        x = x | MASK
    
    return x


def decompress_point(x: int) -> Point:
    """
    Reconstructs a pint
    """
    x = x & (~MASK)

    f_x = f_x = (x * x * x + 7) % P
    y = pow(f_x, (P + 1) // 4, P)

    if (x & MASK != 0):
        if (y & 0x1 != 0x1):
            y = P - y
    else:
        if (y & 0x1 == 0x1):
            y = P - y
    
    return Point(SECP256k1.curve, x, y)


def int_to_point(x: int) -> Point:
    """
    Helper function

    Converts an integer to an elliptic curve
    """
    # Stupid control flow :(
    x -= 1
    y = P

    while not contains_point(x, y):
        x += 1
        f_x = (x * x * x + 7) % P
        y = pow(f_x, (P + 1) // 4, P)

    return Point(SECP256k1.curve, x, y)


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


def random_scalar() -> Scalar:
    """
    Helper function

    Returns a random scalar (secret key)
    """
    return randrange(P)


def H1(b: Union[bytes, str]) -> int:
    """
    Let H1: {0, 1}* -> Z_q (Section 4)

    Returns an integer representation of the hash of the input
    """
    if type(b) is not bytes:
        b = b.encode('utf-8')

    b = "0x" + b.hex()

    return int(
        Web3.soliditySha3(["bytes"], [b]).hex(),
        16
    )


def H2(b: Union[bytes, str]) -> Point:
    """
    Let H2: {0, 1}* -> G

    Returns elliptic curve point of the integer representation
    of the hash of the input
    """
    if type(b) is not bytes:
        b = b.encode('utf-8')
    return int_to_point(H1(b))


def sign(
    message: Union[bytes, str],
    public_keys: List[Point],
    secret_key: Scalar,
    secret_key_idx: int
) -> Signature:
    """
    Generates ring signature for a message given a specific set of public keys
    and a secret key which corresponds to the public key at `secret_key_idx`
    """
    key_count = len(public_keys)

    c = [0] * key_count
    s = [0] * key_count

    # Step 1 (Section 4.2)
    # L :: public_keys
    # x_pi :: The secret key
    # h = H2(L)
    # y_tilde = h^x_pi
    h = H2(serialize(public_keys))
    y_tilde = h * secret_key

    # Step 2
    # Randomly generate scalar u
    # and compure c[signing_key_idx + 1] = H1(L, y_tilde, m, g**u, h**u)
    u = random_scalar()
    c[secret_key_idx + 1 % key_count] = H1(
        serialize(public_keys, y_tilde, message, G * u, h * u)
    )

    # Step 3
    for i in list(range(secret_key_idx + 1, key_count)) + list(range(secret_key_idx)):
        s[i] = random_scalar()

        # g**s_i * y_i**c_i
        z_1 = (G * s[i]) + (public_keys[i] * c[i])

        # h**s_i * y_tilde**c_i
        z_2 = (h * s[i]) + (y_tilde * c[i])

        c[(i + 1) % key_count] = H1(
            serialize(public_keys, y_tilde, message, z_1, z_2)
        )

    # Step 4
    # s_pi = u - x_pi*c_pi mod q
    s[secret_key_idx] = (u - secret_key * c[secret_key_idx]) % N

    # Signature is (C1, S1, ..., Sn, y_tilde)
    return (c[0], s, y_tilde)


def verify(
    message: Union[bytes, str],
    public_keys: List[Point],
    signature: Signature
) -> bool:
    """
    Verifies if the signature was generated by someone in the set of public keys
    """
    key_count = len(public_keys)

    c_0, s, y_tilde = signature
    c = c_0

    # Step 1
    h = H2(serialize(public_keys))

    for i in range(key_count):
        z_1 = (G * s[i]) + (public_keys[i] * c)
        z_2 = (h * s[i]) + (y_tilde * c)

        if i is not key_count - 1:
            c = H1(
                serialize(public_keys, y_tilde, message, z_1, z_2)
            )

    # Step 2
    return c_0 == H1(
        serialize(public_keys, y_tilde, message, z_1, z_2)
    )


if __name__ == "__main__":
    secret_num = 4

    # Secret and public keys
    secret_keys = [random_scalar() for i in range(secret_num)]
    public_keys = [G * s for s in secret_keys]

    # Message
    message = "ETH for you and everyone!"

    # Signing key and idx
    sign_idx = 2
    sign_key = secret_keys[sign_idx]

    # Sign test cases
    signature = sign(message, public_keys, sign_key, sign_idx)
    assert verify(message, public_keys, signature)

    wrong_sig1 = sign(message, public_keys, random_scalar(), sign_idx)
    assert False is verify(message, public_keys, wrong_sig1)

    wrong_sig2 = sign(message, public_keys, sign_key,
                      (sign_idx + 1) // secret_num)
    assert False is verify(message, public_keys, wrong_sig2)

    # To check for linkability (same signer)
    # we can compare the value of y_tilde with
    # other signatures
    # i.e.
    # (_, _, y_tilde1) = signature1
    # (_, _, y_tilde2) = signature2
    # if y_tilde1 == y_tilde2 -> same signer

    # Convert to bytes32 to be easily sent to the contract
    # def int_to_string2(i):
    #     return int_to_string(i).hex()

    # for i in signature:
    #     if type(i) is list:
    #         for j in i:
    #             print(j, int_to_string2(j))
    #     elif type(i) is Point:
    #         print(i.x(), int_to_string2(i.x()))
    #         print(i.y(), int_to_string2(i.y()))
    #     elif type(i) is int:
    #         print(i, int_to_string2(i))

    print("Works as expected!")