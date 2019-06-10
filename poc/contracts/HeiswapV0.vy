# Ring Signature Verifier in Vyper

name: public(bytes32)
verified: public(bool)
testValue: public(uint256)

@public
def __init__(_name: bytes32):
    self.name = _name
    self.verified = False


@public
def verify(
    _bytes: bytes32,
):
    # Signature
    # bytes 0-32: C_0
    # bytes 32-288: S_0, ..., S_n (where n is the number of public_keys)
    # bytes 288-256: y_tilde (use this for linkability)
    self.testValue = convert(_bytes, uint256)

@public
def getTestValue() -> uint256:
    return self.testValue

# def verify(
#     _message: bytes32,
#     _public_keys: address[8],
#     _signature: bytes32[11],
# ):
#     # Signature
#     # bytes 0-32: C_0
#     # bytes 32-288: S_0, ..., S_n (where n is the number of public_keys)
#     # bytes 288-256: y_tilde (use this for linkability)
#     testValue: uint256 = convert(_signature[0], uint256)


    