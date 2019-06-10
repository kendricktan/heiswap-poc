const path = require('path')
const fs = require('fs');
const Web3 = require('web3');

const web3 = new Web3("http://127.0.0.1:8545");

const artifactPath = path.resolve(
    path.resolve(__dirname, 'contracts'),
    'artifacts'
)

const contractAddress = "0xF6509Dbe75aA026fE19766E5e35b63815af967E6"
const contractArtifact = JSON.parse(fs.readFileSync(path.resolve(artifactPath, 'compiled.json'), "utf-8"));

(async () => {
    const accounts = await web3.eth.getAccounts();

    const contractInstance = new web3.eth.Contract(contractArtifact.abi, contractAddress);

    // const sentData = await contractInstance.methods.verify("0x49a3b989cc30a4d6dabc7fb7758e65176a1bbe1f6d70de61cd3f73ae81690b71")
    //     .send({ from: accounts[0], gas: '1500000', gasPrice: '30000000000' })
    //     .catch(err => console.log(`${err}`));

    const listData = await contractInstance.methods.func(10, 2).call();

    console.log(`TestList: `);
    console.log(listData)
})();