pragma solidity >=0.5.0 <0.6.0;

import "./Secp256k1.sol";
import "./LSAG.sol";

contract HeiswapV0 {
    function testFunc(uint256 x, uint256 y) public pure returns (bool) {
        return Secp256k1.containsPoint(x, y);
    }
    
    function testFunc2(bytes memory b) public pure returns (uint256) {
        return LSAG.H1(b);
    }
}