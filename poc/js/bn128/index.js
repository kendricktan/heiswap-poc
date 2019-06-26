/*
* Referenced https://github.com/AztecProtocol/aztec-crypto-js/blob/master/bn128/bn128.js
*
*/

const EC = require('elliptic');
const crypto = require('crypto');
const BN = require('bn.js');
const { soliditySha3, padLeft } = require('web3-utils');

// Field Modulus
P = new BN('21888242871839275222246405745257275088696311157297823662689037894645226208583', 10)
// Group Modulus
N = new BN('21888242871839275222246405745257275088548364400416034343698204186575808495617', 10)

A = new BN('5472060717959818805561601436314318772174077789324455915672259473661306552146', 10)

G = [
    new BN(1, 10),
    new BN(2, 10)
]

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


/**
 * Generates a ring signature for a message given a specific set of public keys
 * and a secret key which corresponds to the public key at `secretKeyIdx`
 * arr: array
 * returns: string
 */
const serialize = (arr) => {
    if (!Array.isArray(arr)) {
        throw "arr should be of type array"
    }

    return arr.reduce((acc, x, idx) => {
        // String
        if (typeof x === 'string') {
            acc = acc + Buffer.from(x).toString('hex')
        }
        // Array
        else if (Array.isArray(x)) {
            acc = acc + serialize(x)
        }
        // Point
        else if (x.getX !== undefined && x.getY !== undefined) {
            acc = acc + padLeft(x.getX().toString(16), 64, '0');
            acc = acc + padLeft(x.getY().toString(16), 64, '0');
        }
        else if (x.toString !== undefined) {
            acc = acc + padLeft(x.toString(16), 64, '0');
        }

        return acc
    }, "")
}

/*
 * Efficient powmod
 * Args: a: BN, b: BN, n: BN
 * returns: (a**b) % n, type (BN)
*/
const powmod = (a, b, n) => {
    let c = new BN('0', 10)
    let f = new BN('1', 10)
    let k = new BN(parseInt(Math.log(b) / Math.log(2)), 10)

    let shiftedK

    const one = new BN(1, 10)
    const two = new BN(2, 10)

    while (k >= 0) {
        c = c.mul(two)
        f = f.mul(f).mod(n)

        shiftedK = new BN('1' + '0'.repeat(k), 2)

        if (b.and(shiftedK) > 0) {
            c = c.add(one)
            f = f.mul(a).mod(n)
        }

        k = k.sub(one)
    }
    return f
}

/*
* Returns (beta, y) given x for alt_bn_128
* x: BN
* return: (BN, BN)
*/
const evalCurve = (x) => {
    const three = new BN('3', 10)
    const beta = x.mul(x).mod(P).mul(x).mod(P).add(three).mod(P)
    const y = powmod(beta, A, P)

    return [beta, y]
}

/*
* Converts an int to a point
* _x: BN
* return: (BN, BN)
*/
const intToPoint = (_x) => {
    let x = _x.mod(N)

    let beta, y, yP

    const one = new BN(1, 10)

    while (true) {
        [beta, y] = evalCurve(x)
        yP = y.mul(y).mod(P)
        if (beta.cmp(yP) === 0) {
            return [x, y]
        }
        x = x.add(one).mod(N)
    }
}

/*
 * Let H1: {0, 1}* -> Z_q
 * Returns an integer representation of the hash of the input
 * s: string
 * return: BN
 */
const h1 = (s) => {
    if (s.indexOf("0x") !== 0) {
        s = "0x" + s;
    }

    const h = soliditySha3(s).slice(2); // Remove the '0x'
    const b = new BN(h, 16);

    return b.mod(N);
}

/*
 * Let H2: {0, 1}* -> G
 * Returns elliptic curve point of the integer representation of
 * the hash of the input
 * s: string in hex format
 * returns [BN, BN]
*/
const h2 = (hexStr) => {
    return intToPoint(h1(hexStr))
}


/*
 * ecMul
 * point: Tuple[BN, BN] (Point)
 * scalar: BN
 * returns: Tuple[BN, BN] (Point)
*/
const ecMul = (point, scalar) => {
    const p1 = bn128.curve.point(point[0], point[1])
    const p2 = p1.mul(scalar)

    return [p2.getX(), p2.getY()]
}


/*
 * ecAdd
 * point1: Tuple[BN, BN] (Point)
 * point1: Tuple[BN, BN] (Point)
 * returns: Tuple[BN, BN] (Point)
*/
const ecAdd = (point1, point2) => {
    const p1 = bn128.curve.point(point1[0], point1[1])
    const p2 = bn128.curve.point(point2[0], point2[1])
    const fp = p1.add(p2)

    return [fp.getX(), fp.getY()]
}



/**
 * Generates a ring signature for a message given a specific set of public keys
 * and a secret key which corresponds to the public key at `secretKeyIdx`
 * message: str
 * publicKeys: List<Point>; Point: [BN, BN]
 * secretKey: BN
 * secretKeyIdx: int
 * returns: Signature ([BN, List[BN], Point])
 */
const ringSign = (
    message,
    publicKeys,
    secretKey,
    secretKeyIdx
) => {
    keyCount = publicKeys.length

    let c = Array(keyCount).fill(new BN(0, 10))
    let s = Array(keyCount).fill(new BN(0, 10))

    // Step 1
    let h = h2(serialize(publicKeys))
    let yTilde = ecMul(h, secretKey)

    // Step 2
    let u = bn128.randomGroupScalar()
    c[(secretKeyIdx + 1) % keyCount] = h1(
        serialize(
            [publicKeys, yTilde, message, ecMul(G, u), ecMul(h, u)]
        )
    )

    // Step 3
    const indexes = Array(keyCount)
        .fill(0)
        .map((x, idx) => idx)
        .slice(secretKeyIdx + 1, keyCount)
        .concat(
            Array(secretKeyIdx)
                .fill(0)
                .map((_x, _idx) => _idx)
        )
    
    let z1, z2

    indexes.forEach(i => {
        s[i] = bn128.randomGroupScalar()

        z1 = ecAdd(ecMul(G, s[i]), ecMul(publicKeys[i], c[i]))    
        z2 = ecAdd(ecMul(h, s[i]), ecMul(yTilde, c[i]))

        c[(i + 1) % keyCount] = h1(
            serialize([publicKeys, yTilde, message, z1, z2])
        )
    });

    // Step 4
    const sci = secretKey.mul(c[secretKeyIdx]).mod(N)

    s[secretKeyIdx] = u.sub(sci).mod(N)

    // JavaScript negative modulo bug -_-
    if (s[secretKeyIdx] < 0) {
        s[secretKeyIdx] = s[secretKeyIdx].add(N)
    }

    s[secretKeyIdx] = s[secretKeyIdx].mod(N)

    return [c[0], s, yTilde]
}


// Testing
secretNum = 4

message = "ETH for you and everyone!"

secretKeys = Array(secretNum).fill(0).map(() => bn128.randomGroupScalar())
publicKeys = secretKeys.map(x => ecMul(G, x))

signIdx = 1
signKey = secretKeys[signIdx]

signature = ringSign(message, publicKeys, signKey, signIdx)

// Print out for easier verification
console.log("--public keys--")
console.log("[")
publicKeys.map(x => { console.log("[" + x[0].toString(10) + ", " + x[1].toString(10) + "],") })
console.log("]")
console.log("--signature--")
console.log("[" + signature[0].toString(10) + ", [")
signature[1].map(x => { console.log(x + ",") })
console.log("],[")
console.log(signature[2][0].toString(10) + ", " + signature[2][1].toString(10))
console.log("]]")