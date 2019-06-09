const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

const contractAbi = [{"outputs": [], "inputs": [{"type": "bytes32", "name": "_name"}], "constant": false, "payable": false, "type": "constructor"}, {"name": "verify", "outputs": [], "inputs": [{"type": "bytes32", "name": "_bytes"}], "constant": false, "payable": false, "type": "function", "gas": 35295}, {"name": "getTestValue", "outputs": [{"type": "uint256", "name": "out"}], "inputs": [], "constant": false, "payable": false, "type": "function", "gas": 513}, {"name": "name", "outputs": [{"type": "bytes32", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 543}, {"name": "verified", "outputs": [{"type": "bool", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 573}, {"name": "testValue", "outputs": [{"type": "uint256", "name": "out"}], "inputs": [], "constant": true, "payable": false, "type": "function", "gas": 603}];
const contractBytecode = "0x740100000000000000000000000000000000000000006020526f7fffffffffffffffffffffffffffffff6040527fffffffffffffffffffffffffffffffff8000000000000000000000000000000060605274012a05f1fffffffffffffffffffffffffdabf41c006080527ffffffffffffffffffffffffed5fa0e000000000000000000000000000000000060a05260206102256101403934156100a157600080fd5b61014051600055600060015561020d56600035601c52740100000000000000000000000000000000000000006020526f7fffffffffffffffffffffffffffffff6040527fffffffffffffffffffffffffffffffff8000000000000000000000000000000060605274012a05f1fffffffffffffffffffffffffdabf41c006080527ffffffffffffffffffffffffed5fa0e000000000000000000000000000000000060a0526375e3661660005114156100bd57602060046101403734156100b457600080fd5b61014051600255005b63a420e5d260005114156100e35734156100d657600080fd5b60025460005260206000f3005b6306fdde0360005114156101095734156100fc57600080fd5b60005460005260206000f3005b63bbb82d89600051141561012f57341561012257600080fd5b60015460005260206000f3005b638af5de72600051141561015557341561014857600080fd5b60025460005260206000f3005b60006000fd5b6100b261020d036100b26000396100b261020d036000f3";


(async () => {
    const accounts = await web3.eth.getAccounts();

    const deployedContract = await new web3.eth.Contract(contractAbi).deploy({
                                    data: contractBytecode,
                                    arguments: ["0x0000000000000000000000000000000000000000000000000000000000000020"]
                                }).send({
                                    from: accounts[0],
                                    gas: '1500000',
                                    gasPrice: '30000000000'
                                });

    console.log(`Contract deployed at: ${deployedContract.options.address}`);
})();