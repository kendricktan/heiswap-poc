const path = require('path')
const fs = require('fs')
const solc = require('solc')
const artifactPath = path.resolve(
    path.resolve(__dirname, 'contracts'),
    'artifacts'
)

const resolveSol = (x) => {
    const contractsPath = path.resolve(__dirname, 'contracts', x)
    return fs.readFileSync(contractsPath, 'utf8')
}

const writeArtifacts = (x, data) => {
    const f = path.resolve(artifactPath, x)
    fs.writeFileSync(f, data)
}

// Get all solidity sources
const soliditySources = fs.readdirSync('./contracts')
    .filter(x => x.indexOf('.sol') !== -1)
    .reduce((acc, x) => {
        acc[x] = {
            'content': resolveSol(x)
        }

        return acc
    }, {})

// Compiled contracts
const compiled = JSON.parse(solc.compile(
    JSON.stringify({
        language: "Solidity",
        sources: soliditySources,
        settings: { outputSelection: { '*': { '*': ['*'] } } }
    })
))

// Create folder if doesn't exist
if (!fs.existsSync(artifactPath)) {
    fs.mkdirSync(artifactPath)
}

const heiswapContract = compiled.contracts['HeiswapV0.sol'].HeiswapV0

// Write artifacts
writeArtifacts('compiled.json', JSON.stringify(heiswapContract, null, 2))

module.exports = {
    abi: heiswapContract.abi,
    bytecode: heiswapContract.evm.bytecode.object
}