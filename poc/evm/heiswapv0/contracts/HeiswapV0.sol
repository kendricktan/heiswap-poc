pragma solidity >0.4.99 <0.6.0;

import "./Secp256k1.sol";

contract HeiswapV0 {
    function testFunc(uint256 x, uint256 y) public pure returns (bool) {
        return Secp256k1.containsPoint(x, y);
    }
}