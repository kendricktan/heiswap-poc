pragma solidity >=0.5.0 <0.6.0;

// https://github.com/ethereum/py_ecc/blob/master/py_ecc/bn128/bn128_curve.py


library AltBn128 {
    uint256[2] constant G1 = [1, 2];
    
    // Curve Order
    uint256 constant public N = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;

    function ecAdd(uint256[2] memory p0, uint256[2] memory p1) public view
        returns (uint256[2] memory)
    {
        uint256[2] memory p2;

        assembly {
            //Get Free Memory Pointer
            let p := mload(0x40)

            //Store Data for ECAdd Call
            mstore(p, mload(p0))
            mstore(add(p, 0x20), mload(add(p0, 0x20)))
            mstore(add(p, 0x40), mload(p1))
            mstore(add(p, 0x60), mload(add(p1, 0x20)))

            //Call ECAdd
            let success := staticcall(sub(gas, 2000), 0x06, p, 0x80, p, 0x40)
            // Use "invalid" to make gas estimation work
 			switch success case 0 { revert(p, 0x80) }

 		    //Store Return Data
 			mstore(p2, mload(p))
 			mstore(add(p2, 0x20), mload(add(p,0x20)))
        }

        return p2;
    }

    function ecMul(uint256[2] memory p, uint256 s) public view
        returns (uint256[2] memory retP)
    {
        // With a public key (x, y), this computes p = scalar * (x, y).
        uint256[3] memory i = [p[0], p[1], s];
        
        assembly {
            // call ecmul precompile
            if iszero(staticcall(not(0), 0x07, i, 0x60, retP, 0x40)) {
                revert(0, 0)
            }
        }
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
            let success := staticcall(sub(gas, 1350), 0x05, p, 0xC0, p, 0x20)

            // Use "invalid" to make gas estimation work
            switch success case 0 { revert(p, 0xC0) }

            //Store Return Data
            y := mload(p)
        }

        return y;
    }

    /*
    * Compresses public key
    * https://bitcoin.stackexchange.com/a/76182
    */
    function compressPoint(uint256[2] memory point) public pure
        returns (bytes1, bytes32)
    {
        // Odd root
        if ((point[1] & 0x1) == 0x1) {
            return (bytes1(0x03), bytes32(point[0]));
        }
        
        // Event root
        return (bytes1(0x02), bytes32(point[0]));
    }

    /*
    * Decompresses public key
    * https://bitcoin.stackexchange.com/a/76182
    */
    function decompressPoint(bytes1 offset, bytes32 _x) public view
        returns (uint256[2] memory)
    {
        uint256 x = uint256(_x);
        uint256 y = getPointY(x);

        // Odd root
        if (offset == 0x03) {
            if (y % 2 == 0) {
                y = n - y;
            }
        }
        
        // Even root
        else {
            if (y % 2 != 0) {
                y = n - y;
            }
        }

        return [x, y];
    }
}