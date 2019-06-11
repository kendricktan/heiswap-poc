pragma solidity >=0.5.0 <0.6.0;

import "./Secp256k1.sol";

/*
Linkable Spontaneous Anonymous Groups

https://eprint.iacr.org/2004/027.pdf
*/

library LSAG {
    /**
    * Converts an integer to an elliptic curve point
    */
    function intToPoint(uint256 x) public
        returns (uint256[2] memory)
    {
        uint256 py = Secp256k1.getPointY(x);

        return [x, py];
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
}