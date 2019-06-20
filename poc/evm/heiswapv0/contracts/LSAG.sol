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
        return AltBn128.modn(uint256(keccak256(b)));
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
    * Helper function to calculate Z1
    * Avoids stack too deep problem
    */
    function ringCalcZ1(
        bytes32[] memory signature,
        uint256 c,
        uint256 i,
        uint256 ringSize
    ) public view
        returns (uint256[2] memory)
    {
        return AltBn128.ecAdd(
            AltBn128.ecMulG(uint256(signature[2+i])),
            AltBn128.ecMul(
                AltBn128.decompressPoint(uint256(signature[2+ringSize+i])),
                c
            )
        );
    }

    /**
    * Helper function to calculate Z2
    * Avoids stack too deep problem
    */
    function ringCalcZ2(
        bytes32[] memory signature,
        uint256[2] memory h,
        uint256 c,
        uint256 i
    ) public view
        returns (uint256[2] memory)
    {
        return AltBn128.ecAdd(
            AltBn128.ecMul(h, uint256(signature[2+i])),
            AltBn128.ecMul(
                AltBn128.decompressPoint(uint256(signature[1])),
                c
            )
        );
    }


    /**
    * Verifies the ring signature
    * Section 4.2 of the paper https://eprint.iacr.org/2004/027.pdf
    */
    function verify(
        bytes memory message,
        bytes32[] memory signature
    ) public view
        returns (bool)
    {
        // Signature is encoded as follows
        // Signature length = (N*2)+2
        // signature[0]             - c_0
        // signature[1]             - y_tilde (key image, compressed)
        // signature[2:2+N]         - s
        // signature[2+N:2+(2*N)]   - publicKey (compressed)

        // Mininum signature size (2 public keys) = (2*2)+2
        require(signature.length >= 6, "Signature size too small");

        // Makes sure that signature is length is correct
        require(signature.length % 2 == 0, "Signature incorrect length");
        
        uint256 c = uint256(signature[0]);
        uint256 i = 0;
        uint256 ringSize = (signature.length - 2) / 2;

        // Step 1
        // Extract out public key bytes
        bytes memory hBytes = "";

        for (i = 0; i < ringSize; i++) {
            hBytes = abi.encodePacked(
                hBytes,
                AltBn128.decompressPoint(
                    uint256(signature[2+ringSize+i])
                )
            );
        }

        uint256[2] memory h = H2(hBytes);

        // Step 2
        uint256[2] memory z_1;
        uint256[2] memory z_2;

        for (i = 0; i < ringSize; i++) {
            z_1 = ringCalcZ1(signature, c, i, ringSize);
            z_2 = ringCalcZ2(signature, h, c, i);

            if (i < ringSize - 1) {
                c = H1(
                    abi.encodePacked(
                        hBytes,
                        AltBn128.decompressPoint(uint256(signature[1])),
                        message,
                        z_1,
                        z_2
                    )
                );
            }
        }

        return uint256(signature[0]) == H1(
            abi.encodePacked(
                hBytes,
                AltBn128.decompressPoint(uint256(signature[1])),
                message,
                z_1,
                z_2
            )
        );
    }

}