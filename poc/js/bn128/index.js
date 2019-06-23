/*
* Referenced https://github.com/AztecProtocol/aztec-crypto-js/blob/master/bn128/bn128.js
*
*/

const EC = require('elliptic');
const crypto = require('crypto');
const BN = require('bn.js');
const { padLeft } = require('web3-utils');

// Field Modulus
P = new BN('21888242871839275222246405745257275088696311157297823662689037894645226208583', 10)
// Group Modulus
N = new BN('21888242871839275222246405745257275088548364400416034343698204186575808495617', 10)

const bn128 = {};

bn128.curve = new EC.curve.short({
    a: '0',
    b: '3',
    p: P.toString(16),
    n: N.toString(16),
    gRed: false,
    g: ['1', '2']
})

