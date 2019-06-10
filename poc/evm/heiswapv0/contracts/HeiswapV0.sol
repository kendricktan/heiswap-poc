pragma solidity >0.4.99 <0.6.0;

import "./ECSol.sol";


contract HeiswapV0 {
    constructor () public {
    }
    
    function func(uint x, uint y) public pure returns (uint) {
        return x * (y + 42);
    }
}