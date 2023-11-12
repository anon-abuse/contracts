const ethers = require('ethers');
const fs = require('fs');
const path = require('path');


async function main() {
    // const rpcUrl = "http://localhost:8545"; // Replace with your Ethereum RPC URL
    const provider = new ethers.providers.JsonRpcProvider();
    const zeroAddress = "0x0000000000000000000000000000000000000000";

    // Construct the path to the keys.json file
    const keysFilePath = path.join(__dirname, '../keys.json');

    // Read and parse the JSON file
    const keys = JSON.parse(fs.readFileSync(keysFilePath, "utf8"));
    
    for (const keyObj of keys) {
        const wallet = new ethers.Wallet(keyObj.private_key, provider);

        // Define the transaction
        const tx = {
            to: zeroAddress,
            value: ethers.utils.parseEther("0.1") // Amount of Ether to send
        };

        console.log(`Sending transaction from ${wallet.address}...`);
        const response = await wallet.sendTransaction(tx);
        await response.wait();
        console.log(`Transaction hash: ${response.hash}`);
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
