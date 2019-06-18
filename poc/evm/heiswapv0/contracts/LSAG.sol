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
    * Helper function to prevent stack nested variables
    *
    */
    // function ringCalcZ1(
    //     uint256 c,
    //     uint256 s,
    //     bytes memory publicKey // Compressed public key
    // ) public view
    //     returns (uint256[2] memory)
    // {
    //     uint256[2] memory pub = Secp256k1.decompressPoint(publicKey);

    //     uint256 tempx;
    //     uint256 tempy;
    //     uint256 z_x;
    //     uint256 z_y;

    //     (tempx, tempy) = Secp256k1.ecMulG(s);
    //     (z_x, z_y) = Secp256k1.ecMul(pub[0], pub[1], c);
    //     (z_x, z_y) = Secp256k1.ecAdd(tempx, tempy, z_x, z_y);

    //     return [z_x, z_y];
    // }

    // function ringCalcZ2(
    //     uint256 c,
    //     uint256 s,
    //     uint256 hx, uint256 hy,
    //     uint256 keyImageX, uint256 keyImageY // (y_tilde) keyImage is compressed
    // ) public view
    //     returns (uint256[2] memory)
    // {
    //     uint256 tempx;
    //     uint256 tempy;
    //     uint256 a_x;
    //     uint256 a_y;

    //     (tempx, tempy) = Secp256k1.ecmul(hx, hy, s);
    //     (a_x, a_y) = Secp256k1.ecmul(keyImageX, keyImageY, c);
    //     (a_x, a_y) = Secp256k1.ecadd(tempx, tempy, a_x, a_y);

    //     return [a_x, a_y];
    // }

    /**
    * Verifies the ring signature
    * Section 4.2 of the paper https://eprint.iacr.org/2004/027.pdf
    */
    function verify(
        bytes memory message,
        bytes32[] memory signature,
        bytes1[] memory offset // Used to determine of the point is odd or even
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

        // Memory registers
        uint256 i = 0;
        uint256 ringSize = (signature.length - 2) / 2;
        uint256 c = uint256(signature[0]);

        require(offset.length == ringSize + 1, "Offset incorrect length");

        // Calculate H (with public keys)
        bytes memory hBytes = "";

        for (i = 0; i < ringSize; i++) {
            // public key x = signature[2+N+i]
            // offset public key x = signature[1+i]
            hBytes = abi.encodePacked(hBytes, Secp256k1.decompressPoint(
                offset[1+i], signature[2+ringSize+i]
            ));
        }
        uint256[2] memory h = H2(hBytes);
        
        // uint256[2] memory z_1;
        // uint256[2] memory z_2;

        // for (i = 0; i < ringSize; i++) {
        //     z_1 = ringCalcZ1(
        //         c,
        //         uint256(signature[2+i]),  // s
        //         abi.encodePacked(offset[1+i], signature[2+ringSize+i]) // public key
        //     );
        // }

        // i = 2;
        // z_1 = ringCalcZ1(
        //     c,
        //     BytesLib.toUint(abi.encodePacked(signature[2+i]), 0), // s
        //     abi.encodePacked(offset[1+i], signature[2+ringSize+i]) // public key
        // );

            // z_2 = ringCalcZ2(
            //     c,
            //     signature[3+(ringSize*2)+i],
            //     h[0], h[1],
            //     signature[1], signature[2]
            // );

            // if (i < ringSize - 1) {
            //     c = H1(
            //         abi.encodePacked(hBytes, signature[1], signature[2], message, z_1, z_2)
            //     );
            // }
        // }

        // return c == H1(
        //     abi.encodePacked(hBytes, signature[1], signature[2], message, z_1, z_2)
        // );

        return h;
    }

}