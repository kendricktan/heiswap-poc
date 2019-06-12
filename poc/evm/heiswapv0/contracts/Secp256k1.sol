pragma solidity >=0.5.0 <0.6.0;

/*
Taken from https://github.com/HarryR/solcrypto

License: GPL-3.0
*/

library Secp256k1 {
    uint256 constant public gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 constant public gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 constant public n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint256 constant public m = 0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffff0c; // (n + 1) // 4
    uint256 constant public a = 0;
    uint256 constant public b = 7;

    uint256 constant public ecMask = 0x8000000000000000000000000000000000000000000000000000000000000000;

    function _jAdd(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2
    ) public pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            addmod(
                mulmod(z2, x1, n),
                mulmod(x2, z1, n),
                n
            ),
            mulmod(z1, z2, n)
        );
    }

    function _jSub(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2
    ) public pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            addmod(
                mulmod(z2, x1, n),
                mulmod(n - x2, z1, n),
                n
            ),
            mulmod(z1, z2, n)
        );
    }

    function _jMul(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2
    ) public pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            mulmod(x1, x2, n),
            mulmod(z1, z2, n)
        );
    }

    function _jDiv(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2
    ) public pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            mulmod(x1, z2, n),
            mulmod(z1, x2, n)
        );
    }

    function _inverse(uint256 val) public pure
        returns(uint256 invVal)
    {
        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = n;
        uint256 newR = val;
        uint256 q;
        while (newR != 0) {
            q = r / newR;

            (t, newT) = (newT, addmod(t, (n - mulmod(q, newT, n)), n));
            (r, newR) = (newR, r - q * newR );
        }

        return t;
    }

    function _ecAdd(
        uint256 x1, uint256 y1, uint256 z1,
        uint256 x2, uint256 y2, uint256 z2
    ) public pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 lx;
        uint256 lz;
        uint256 da;
        uint256 db;

        if (x1 == 0 && y1 == 0) {
            return (x2, y2, z2);
        }

        if (x2 == 0 && y2 == 0) {
            return (x1, y1, z1);
        }

        if (x1 == x2 && y1 == y2) {
            (lx, lz) = _jMul(x1, z1, x1, z1);
            (lx, lz) = _jMul(lx, lz, 3, 1);
            (lx, lz) = _jAdd(lx, lz, a, 1);

            (da,db) = _jMul(y1, z1, 2, 1);
        } else {
            (lx, lz) = _jSub(y2, z2, y1, z1);
            (da, db) = _jSub(x2, z2, x1, z1);
        }

        (lx, lz) = _jDiv(lx, lz, da, db);

        (x3, da) = _jMul(lx, lz, lx, lz);
        (x3, da) = _jSub(x3, da, x1, z1);
        (x3, da) = _jSub(x3, da, x2, z2);

        (y3, db) = _jSub(x1, z1, x3, da);
        (y3, db) = _jMul(y3, db, lx, lz);
        (y3, db) = _jSub(y3, db, y1, z1);

        if (da != db) {
            x3 = mulmod(x3, db, n);
            y3 = mulmod(y3, da, n);
            z3 = mulmod(da, db, n);
        } else {
            z3 = da;
        }
    }

    function _ecDouble(uint256 x1, uint256 y1, uint256 z1) public pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        (x3, y3, z3) = _ecAdd(x1, y1, z1, x1, y1, z1);
    }

    function _ecMul(uint256 d, uint256 x1, uint256 y1, uint256 z1) public pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 remaining = d;
        uint256 px = x1;
        uint256 py = y1;
        uint256 pz = z1;
        uint256 acx = 0;
        uint256 acy = 0;
        uint256 acz = 1;

        if (d == 0) {
            return (0, 0, 1);
        }

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                (acx,acy,acz) = _ecAdd(acx, acy, acz, px, py, pz);
            }
            remaining = remaining / 2;
            (px, py, pz) = _ecDouble(px, py, pz);
        }

        (x3, y3, z3) = (acx, acy, acz);
    }

    function ecadd(
        uint256 x1, uint256 y1,
        uint256 x2, uint256 y2)
        public
        pure
        returns(uint256 x3, uint256 y3)
    {
        uint256 z;
        (x3, y3, z) = _ecAdd(x1, y1, 1, x2, y2, 1);
        z = _inverse(z);
        x3 = mulmod(x3, z, n);
        y3 = mulmod(y3, z, n);
    }

    function ecmul(uint256 x1, uint256 y1, uint256 scalar) public pure
        returns(uint256 x2, uint256 y2)
    {
        uint256 z;
        (x2, y2, z) = _ecMul(scalar, x1, y1, 1);
        z = _inverse(z);
        x2 = mulmod(x2, z, n);
        y2 = mulmod(y2, z, n);
    }

    function ecmulG(uint256 scalar) public pure
        returns (uint256, uint256)
    {
        return ecmul(gx, gy, scalar);
    }

    function point_hash(uint256[2] memory point)
        public pure returns(address)
    {
        return address(uint256(keccak256(abi.encodePacked(point[0], point[1]))) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    /**
    * hash(g^a + B^c)
    */
    function sbmul_add_mul(uint256 _s, uint256[2] memory B, uint256 c)
        public pure returns(address)
    {
        uint256 s = _s;
        uint256 Q = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
        s = (Q - s) % Q;
        s = mulmod(s, B[0], Q);

        return ecrecover(bytes32(s), B[1] % 2 != 0 ? 28 : 27, bytes32(B[0]), bytes32(mulmod(c, B[0], Q)));
    }

    //
    // Based on the original idea of Vitalik Buterin:
    // https://ethresear.ch/t/you-can-kinda-abuse-ecrecover-to-do-ecmul-in-secp256k1-today/2384/9
    //
    function ecmulVerify(uint256 x1, uint256 y1, uint256 scalar, uint256 qx, uint256 qy) public pure
        returns(bool)
    {
        address signer = sbmul_add_mul(0, [x1, y1], scalar);
        return point_hash([qx, qy]) == signer;
    }

    function publicKey(uint256 privKey) public pure
        returns(uint256 qx, uint256 qy)
    {
        return ecmul(gx, gy, privKey);
    }

    function publicKeyVerify(uint256 privKey, uint256 x, uint256 y) public pure
        returns(bool)
    {
        return ecmulVerify(gx, gy, privKey, x, y);
    }

    function deriveKey(uint256 privKey, uint256 pubX, uint256 pubY) public pure
        returns(uint256 qx, uint256 qy)
    {
        uint256 z;
        (qx, qy, z) = _ecMul(privKey, pubX, pubY, 1);
        z = _inverse(z);
        qx = mulmod(qx, z, n);
        qy = mulmod(qy, z, n);
    }

    /*
       Checks if the points x, y exists on Curve Secp256k1
       Taken from: https://github.com/warner/python-ecdsa/blob/480b5f7d9fdaf9e70be4edfad04e6d0438b212e4/src/ecdsa/numbertheory.py#L180
    */
    function containsPoint(uint256 x, uint256 y) public pure
        returns(bool)
    {
        // x**3 + 7
        uint256 x_cubed_p7 = mulmod(x, x, n);
        x_cubed_p7 = mulmod(x_cubed_p7, x, n);
        x_cubed_p7 = addmod(x_cubed_p7, b, n);

        return (mulmod(y, y, n) - x_cubed_p7) % n == 0;
    }

    /*
    * Calculates point y value given x
    */
    function getPointY(uint256 x) public view
        returns (uint256)
    {
        uint256 x_cubed_p7 = mulmod(x, x, n);
        x_cubed_p7 = mulmod(x_cubed_p7, x, n);
        x_cubed_p7 = addmod(x_cubed_p7, 7, n);
        
        uint256 n_local = n;
        uint256 m_local = m;
        uint256 y;

        // Call Big Int Pow Mod (EIP 198)
        assembly {
            // Get Free Memory Pointer
            let p := mload(0x40)

            // Store Data for Big Int Mod Exp Call
            mstore(p, 0x20)                   // Length of Base
            mstore(add(p, 0x20), 0x20)        // Length of Exponent
            mstore(add(p, 0x40), 0x20)        // Length of Modulus
            mstore(add(p, 0x60), x_cubed_p7)  // Base
            mstore(add(p, 0x80), m_local)     // Exponent
            mstore(add(p, 0xA0), n_local)     // Modulus

            // Call Big Int Mod Exp
            let success := staticcall(sub(gas, 2000), 0x05, p, 0xC0, p, 0x20)

            // Use "invalid" to make gas estimation work
            switch success case 0 { revert(p, 0xC0) }

            //Store Return Data
            y := mload(p)
        }

        return y;
    }

    /*
    * Compresses public key
    */
    function compressPoint(uint256[2] memory point) public pure
        returns (uint256)
    {
        // Store x value
        uint256 x = point[0];

        // Determine sign
        if ((point[1] & 0x1) == 0x1) {
            x |= ecMask;
        }

        return x;
    }

    /*
    * Decompresses public key
    */
    function decompressPoint(uint256 _x) public view
        returns (uint256[2] memory)
    {
        uint256 x = _x & (~ecMask);
        uint256 y = getPointY(x);

        // Positive y
        if ((x & ecMask) != 0) {
            if (y & 0x1 != 0x1) {
                y = n - y;
            }
        }

        // Negative y
        else {
            if (y & 0x1 == 0x1) {
                y = n - y;
            }
        }

        // TODO: Better error handling
        if (!containsPoint(x, y)) {
            return [uint256(0), uint256(0)];
        }

        return [x, y];
    }
}