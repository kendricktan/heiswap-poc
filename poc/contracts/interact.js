const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

const contractAddress = "0x60d834624a75c60453008a140142152f0d15ade7"
const contractAbi = [{"outputs": [], "inputs": [{"type": "bytes32", "name": "_name"}], "constant": false, "payable": false, "type": "constructor"}, {"name": "verify", "outputs": [], "inputs": [{"type": "bytes32", "name": "_bytes"}], "constant": false, "payable": false, "type": "function", "gas": 35295}, {"name": "getTestValue", "outputs": [{"type": "uint256", "name": "out"}], "inputs": [], "constant": false, "payable": false, "type": "function", "gas": 513}, {"name": "name", "outputs": [{"type": "bytes32", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 543}, {"name": "verified", "outputs": [{"type": "bool", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 573}, {"name": "testValue", "outputs": [{"type": "uint256", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 603}];

(async () => {
    const accounts = await web3.eth.getAccounts();

    const contractInstance = new web3.eth.Contract(contractAbi, contractAddress);

    const sentData = await contractInstance.methods.verify("0xd29707323fca6e8ef1270b3fb3098d3e716cf60af5e4307b2ce86587b839dcb9").send({from: accounts[0]});
        
    const callData = await contractInstance.methods.getTestValue().call();

    console.log(`Value: `);
    console.log(callData)
})();