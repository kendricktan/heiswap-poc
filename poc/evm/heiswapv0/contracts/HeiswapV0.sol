pragma solidity >=0.5.0 <0.6.0;

import "./Secp256k1.sol";
import "./LSAG.sol";

contract HeiswapV0 {
    function testFunc(uint256[] memory args) public pure returns (bytes memory) {
        return abi.encodePacked(args);
    }
}