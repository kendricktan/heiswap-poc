# Ring Signature Verifier in Vyper

# SECP256k1 Properties
Gx: uint256
Gy: uint256
G: uint256[2]

name: public(bytes32)
verified: public(bool)
testValue: public(uint256)
testList: public(uint256[2])

@public
def __init__(_name: bytes32):
    self.name = _name
    self.verified = False

    self.Gx = 55066263022277343669578718895168534326250603453777594175500187360389116729240
    self.Gy = 32670510020758816978083085130507043184471273380659243275938904335757337482424
    self.G = [self.Gy, self.Gx]


@public
def verify(
    _bytes: bytes32,
):
    # Signature
    # bytes 0-32: C_0
    # bytes 32-288: S_0, ..., S_n (where n is the number of public_keys)
    # bytes 288-256: y_tilde (use this for linkability)
    value: uint256 = convert(_bytes, uint256)

    self.testValue = value
    
    self.testList = ecadd(self.G, self.G)

@public
def getTestValue() -> uint256:
    return self.testValue

@public
def getTestList() -> uint256[2]:
    return self.testList

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


    