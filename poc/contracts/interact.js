const Web3 = require('web3');
const fs = require('fs');

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

const contractAddress = "0x007D066Bd98829d74d25aF5fAf8816e938df4C8c"
const contractAbi = JSON.parse(fs.readFileSync("hs.abi", "utf-8"));


(async () => {
    const accounts = await web3.eth.getAccounts();

    const contractInstance = new web3.eth.Contract(contractAbi, contractAddress);

    const sentData = await contractInstance.methods.verify("0x49a3b989cc30a4d6dabc7fb7758e65176a1bbe1f6d70de61cd3f73ae81690b71")
                        .send({from: accounts[0], gas: '1500000', gasPrice: '30000000000'})
                        .catch(err => console.log(`${err}`));
        
    const listData = await contractInstance.methods.getTestList().call();
    const testData = await contractInstance.methods.getTestValue().call();

    console.log(`TestList: `);
    console.log(listData)

    console.log(`TestValue: `);
    console.log(testData)
})();