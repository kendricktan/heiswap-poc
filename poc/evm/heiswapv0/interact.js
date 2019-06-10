const path = require('path')
const fs = require('fs');
const Web3 = require('web3');

const web3 = new Web3("http://127.0.0.1:8545");

const artifactPath = path.resolve(
    path.resolve(__dirname, 'contracts'),
    'artifacts'
)

const contractAddress = "0xC2fd440CAF60081A104C8785751Edb5F064C2857"
const contractArtifact = JSON.parse(fs.readFileSync(path.resolve(artifactPath, 'compiled.json'), "utf-8"));

(async () => {
    const accounts = await web3.eth.getAccounts();

    const contractInstance = new web3.eth.Contract(contractArtifact.abi, contractAddress);

    // const sentData = await contractInstance.methods.verify("0x49a3b989cc30a4d6dabc7fb7758e65176a1bbe1f6d70de61cd3f73ae81690b71")
    //     .send({ from: accounts[0], gas: '1500000', gasPrice: '30000000000' })
    //     .catch(err => console.log(`${err}`));

    const testData = await contractInstance.methods.ecmul(
        "0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        "0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8",
        "0x080c2232dac42fd1872da1c3d51f72f418c7c492d2e8d0428ea7bc389522c369",
    ).call({ gas: '1500000', gasPrice: '30000000000' });

    console.log(`testData: `);
    console.log(testData)
})();