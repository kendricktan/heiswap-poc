const Secp256k1 = artifacts.require("Secp256k1");
const LSAG = artifacts.require("LSAG");
const HeiswapV0 = artifacts.require("HeiswapV0");

module.exports = function(deployer) {
  deployer.deploy(Secp256k1);
  deployer.link(Secp256k1, LSAG);
  deployer.deploy(LSAG);
  deployer.link(LSAG, HeiswapV0);
  deployer.link(Secp256k1, HeiswapV0);
  deployer.deploy(HeiswapV0);
};
