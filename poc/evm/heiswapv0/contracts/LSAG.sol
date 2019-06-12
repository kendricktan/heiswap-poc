pragma solidity >=0.5.0 <0.6.0;

import "./Secp256k1.sol";

/*
Linkable Spontaneous Anonymous Groups

https://eprint.iacr.org/2004/027.pdf
*/

library LSAG {
    // abi.encodePacked is the "concat" or "serialization"
    // of all supplied arguments into one long bytes value
    // i.e. abi.encodePacked :: [a] -> bytes

    /**
    * Converts an integer to an elliptic curve point
    */
    function intToPoint(uint256 _x) public view
        returns (uint256[2] memory)
    {
        uint256 x = _x;
        uint256 y = Secp256k1.getPointY(x);

        while (!Secp256k1.containsPoint(x, y)) {
            x = x + 1;
            y = Secp256k1.getPointY(x);
        }

        return [x, y];
    }

    /**
    * Returns an integer representation of the hash
    * of the input
    */
    function H1(bytes memory b) public pure
        returns (uint256)
    {
        return uint256(keccak256(b));
    }

    /**
    * Returns elliptic curve point of the integer representation
    * of the hash of the input
    */
    function H2(bytes memory b) public view
        returns (uint256[2] memory)
    {
        return intToPoint(H1(b));
    }

    /**
    * Verifies the ring signature
    * Section 4.2 of the paper https://eprint.iacr.org/2004/027.pdf
    */
    function verify(
        bytes memory message,
        uint256[] memory signature
    ) public pure
        returns (bool)
    {
        // Signature is encoded as follows
        // signature size: (2*N)+3
        // signature[0]        - c_0
        // signature[1]        - N (number of public keys)
        // signature[2:2+N]    - publicKey (compressed)
        // signature[2+N:2+N]  - s
        // signature[N+3]      - y (compressed)
        return true;
    }

}