pragma solidity >=0.5.0 <0.6.0;

import "./AltBn128.sol";

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
        uint256 y;
        uint256 beta;

        while (true) {
            (beta, y) = AltBn128.evalCurve(x);

            if (AltBn128.onCurveBeta(beta, y)) {
                return [x, y];
            }

            x = AltBn128.addmodn(x, 1);
        }
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
        bytes32[] memory signature
    ) public view
        returns (uint256[2] memory)
    {
        // Signature is encoded as follows
        // Signature length = (N*2)+2
        // signature[0]             - c_0
        // signature[1]             - y_tilde (key image, compressed)
        // signature[2:2+N]         - s
        // signature[2+N:2+(2*N)]   - publicKey (compressed)

        // Offset is encoded as follows
        // Offset length = N+1
        // offset[0]     - y_tilde offset
        // offset[1:1+N] - public key offsets

        // Mininum signature size (2 public keys) = (2*2)+2
        require(signature.length >= 6, "Signature size too small");

        // Makes sure that signature is length is correct
        require(signature.length % 2 == 0, "Signature incorrect length");

        return [uint256(0x00), uint256(0x00)];
    }

}