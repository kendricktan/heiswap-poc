const AltBn128 = artifacts.require("AltBn128");
const LSAG = artifacts.require("LSAG");
const HeiswapV0 = artifacts.require("HeiswapV0");

module.exports = function(deployer) {
  deployer.deploy(AltBn128);
  deployer.link(AltBn128, LSAG);
  deployer.deploy(LSAG);
  deployer.link(LSAG, HeiswapV0);
  deployer.link(Secp256k1, HeiswapV0);
  deployer.deploy(HeiswapV0);
};
