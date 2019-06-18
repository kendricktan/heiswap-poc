pragma solidity >=0.5.0 <0.6.0;

// https://github.com/ethereum/py_ecc/blob/master/py_ecc/bn128/bn128_curve.py


library AltBn128 {    
    // https://github.com/ethereum/py_ecc/blob/master/py_ecc/bn128/bn128_curve.py
    uint256 constant public G1x = uint256(0x01);
    uint256 constant public G1y = uint256(0x02);

    // Number of elements in the field (often called `q`)
    // n = n(u) = 36u^4 + 36u^3 + 18u^2 + 6u + 1
    uint256 constant public N = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;

    // p = p(u) = 36u^4 + 36u^3 + 24u^2 + 6u + 1
    // Field Order
    uint256 constant public P = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;

    // (p+1) / 4
    uint256 constant public A = 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52;

    uint256 constant public ECSignMask = 0x8000000000000000000000000000000000000000000000000000000000000000;

    /* ECC Functions */
    function ecAdd(uint256[2] memory p0, uint256[2] memory p1) public view
        returns (uint256[2] memory retP)
    {
        uint256[4] memory i = [p0[0], p0[1], p1[0], p1[1]];
        
        assembly {
            // call ecadd precompile
            // inputs are: x1, y1, x2, y2
            if iszero(staticcall(not(0), 0x06, i, 0x80, retP, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function ecMul(uint256[2] memory p, uint256 s) public view
        returns (uint256[2] memory retP)
    {
        // With a public key (x, y), this computes p = scalar * (x, y).
        uint256[3] memory i = [p[0], p[1], s];
        
        assembly {
            // call ecmul precompile
            // inputs are: x, y, scalar
            if iszero(staticcall(not(0), 0x07, i, 0x60, retP, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function powmod(uint256 base, uint256 e, uint256 m) public view
        returns (uint256 o)
    {
        // returns pow(base, e) % m
        assembly {
            // define pointer
            let p := mload(0x40)

            // Store data assembly-favouring ways
            mstore(p, 0x20)             // Length of Base
            mstore(add(p, 0x20), 0x20)  // Length of Exponent
            mstore(add(p, 0x40), 0x20)  // Length of Modulus
            mstore(add(p, 0x60), base)  // Base
            mstore(add(p, 0x80), e)     // Exponent
            mstore(add(p, 0xa0), m)     // Modulus

            // call modexp precompile! -- old school gas handling
            let success := staticcall(sub(gas, 2000), 0x05, p, 0xc0, p, 0x20)

            // gas fiddling
            switch success case 0 {
                revert(0, 0)
            }

            // data
            o := mload(p)
        }
    }

    /*
       Checks if the points x, y exists on alt_bn_128 curve
    */
    function onCurve(uint256 x, uint256 y) public pure
        returns(bool)
    {
        uint256 beta = mulmod(x, x, P);
        beta = mulmod(beta, x, P);
        beta = addmod(beta, 3, P);

        return beta == mulmod(y, y, P);
    }

    /*
    * Calculates point y value given x
    */
    function evalCurve(uint256 x) public view
        returns (uint256)
    {
        uint256 beta = mulmod(x, x, P);
        beta = mulmod(beta, x, P);
        beta = addmod(beta, 3, P);

        uint256 y = powmod(beta, A, P);

        // Requires y to be on curve
        require(beta == mulmod(y, y, P), "Invalid x for evalCurve");

        return y;
    }

    /*
    * Compresses point
    * https://github.com/solidblu1992/ethereum/blob/master/SimpleRingMixer/contracts/RingMixerV2.sol#L216
    */
    function compressPoint(uint256[2] memory p) public pure
        returns (uint256)
    {
        uint256 x = p[0];

        if (p[1] & 0x01 == 0x01) {
            x |= ECSignMask;
        }

        return x;
    }

    /*
    * Decompresses point
    * https://github.com/solidblu1992/ethereum/blob/master/SimpleRingMixer/contracts/RingMixerV2.sol#L282
    */
    function decompressPoint(uint256 _x) public view
        returns (uint256[2] memory)
    {
        uint256 x = _x & (~ECSignMask);
        uint256 y = evalCurve(x);

        // Positive Y
        if ((x & ECSignMask) != 0) {
            if ((y & 0x1) != 0x1) {
                y = P - y;
            }
        }
        // Negative Y
        else {
            if ((y & 0x1) == 0x1) {
                y = P - y;
            }
        }

        return [x, y];
    }
}