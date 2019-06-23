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

/**
 * BN.js reduction context for bn128 curve group's prime modulus
 * @memberof module:bn128
 */
bn128.groupReduction = BN.red(bn128.curve.n);

/**
 * Get a random BN in the bn128 curve group's reduction context
 * @method randomGroupScalar
 * @memberof module:bn128
 * @returns {BN} BN.js instance
 */
bn128.randomGroupScalar = () => {
    return new BN(crypto.randomBytes(32), 16).toRed(bn128.groupReduction);
};

/**
 * Get a random point on the curve
 * @method randomPoint
 * @memberof module:bn128
 * @returns {Point} a random point
 */
bn128.randomPoint = () => {
    const recurse = () => {
        const x = new BN(crypto.randomBytes(32), 16).toRed(bn128.curve.red);
        const y2 = x.redSqr().redMul(x).redIAdd(bn128.curve.b);
        const y = y2.redSqrt();
        if (y.redSqr(y).redSub(y2).cmp(bn128.curve.a)) {
            return recurse();
        }
        return bn128.curve.point(x, y);
    }
    return recurse();
};

// Point is a type array [BN, BN]
// Scalar is type BN
// Returns [BN, BN]

sk = bn128.randomGroupScalar()
pk = bn128.curve.g.mul(sk)
pk2 = pk.add(pk)

console.log(`sk: ${sk}`)
console.log(`pk: ${pk.getX()}, ${pk.getY()}`)
console.log(`pk + pk: ${pk2.getX()}, ${pk2.getY()}`)