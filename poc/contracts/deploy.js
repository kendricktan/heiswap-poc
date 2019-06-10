const Web3 = require('web3');
const fs = require('fs')

const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

const contractAbi = JSON.parse(fs.readFileSync("hs.abi", "utf-8"));
const contractBytecode = fs.readFileSync("hs.bytecode", "utf-8").toString("hex").replace("\n", "").replace(" ", "");


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