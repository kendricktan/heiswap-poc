from ringsignatures import *
from binascii import unhexlify

msg = unhexlify("ec4be43dbf016ad1cd91fbfcbcd1bfc69120128de34f0987294a42c1d3394f8a")

public_keys = [ 
  ['0x220af4959bb8de46d1b345f9c451cdc20b2865f71fc16c30bb43d7e7f7f47863', '0x0e3e8ea1d1244639c9aae7357f780a47b9300d1995c674ab3b495e33d31ef542'],
  ['0x117f094f693ab4076f0e4771b8f894130481fb7d61a8e344f56114c53ff0c9dd', '0x0c0c8512c25babf149023dcbd8abdeb76cdc38399b2bef5740eb46f5062014aa'],
  ['0x10f89c9912985ae214c33dc69ded4619e2e28117ceef0d9ed4fee11f9c01776e', '0x250c4928887f23c0d00bc2ebe628928fbe268096b32849f21571e0db825f473c'],
  ['0x30298034a5667ed9e58fdb1dc682c440cf585f8cb5ca5b539afe1590e650d0a3', '0x004e548a42192acc6b687f35b71258cf3e382c1647a15e492c0a050b84042384'],
  ['0x02b29c88361a87c67ac5e49f8927851beca6b0d7d43de69b75d6622db0bd0ef7', '0x23030b38f0fce942abe923e2aabecb0dadba085c75680c7d36b1097ae8238610']
]
public_keys = list(map(lambda x: [int(x[0], 16), int(x[1], 16)], public_keys))

secret_key = 0x09e02047c4221e31d7e66c539fe7e6822d87ab9b9c6193b11a419ab83cec9bb1
secret_key_idx = 0

signature = sign(msg, public_keys, secret_key, secret_key_idx)
valid = verify(msg, public_keys, signature)

print("Valid signature: " + str(valid))
