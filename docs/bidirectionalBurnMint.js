// This script does a burn on domain 0, mint on domain 1, and then the opposite.
// Configuration values must be set in .env file.

// Sample .env for smokebox test of Ethereum <-> Avalanche:
// DOMAIN_0_RPC=https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161
// DOMAIN_1_RPC=https://api.avax-test.network/ext/bc/C/rpc
// DOMAIN_0_PRIVATE_KEY=668d353bd5d1596aca29d89c9c974f690455d114add37101d058da128a00c953
// DOMAIN_1_PRIVATE_KEY=0eaf394a0e01edb787d272ae3db51053259adddf087f7756b9233a87d472760e
// DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS=0x0273f0bd27c2c6c11213e55463d07c1722e8cdc3
// USDC_DOMAIN_0_CONTRACT_ADDRESS=0x07865c6e87b9f70255377e024ace6630c1eaa37f
// DOMAIN_0_MESSAGE_CONTRACT_ADDRESS=0xf8068f3ca905b6d0f5e54dc7c7ebbc6814fc7137
// DOMAIN_1_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS=0xf6e708cdf867fa830c3be45f5a0ebd87048a28d0
// DOMAIN_1_TOKEN_MESSENGER_CONTRACT_ADDRESS=0x98b19cc4f587fec30c20e4699c431d7e6df26981
// USDC_DOMAIN_1_CONTRACT_ADDRESS=0x5425890298aed601595a70AB815c96711a31Bc65
// DOMAIN_1_MESSAGE_CONTRACT_ADDRESS=0xb8c8078a38c98f9a4d34a7a6e1e9d689a10d5328
// DOMAIN_0_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS=0x24df4fdee80bef6fe53a6e67e7fc37b1bf3f093c
// DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS=0x0273f0bd27c2c6c11213e55463d07c1722e8cdc3
// DOMAIN_0_ID=0
// DOMAIN_1_ID=1
// AMOUNT=1
// IRIS_API_URL=https://iris-api-smokebox.circle.com

// Instructions to run:
// npm install
// node ./bidirectionalBurnMint.js

require("dotenv").config()
const Web3 = require('web3')

const tokenMessengerAbi = require('./abis/cctp/TokenMessenger.json')
const messageAbi = require('./abis/cctp/Message.json')
const usdcAbi = require('./abis/Usdc.json')
const messageTransmitterAbi = require('./abis/cctp/MessageTransmitter.json')

const waitForTransaction = async(web3, txHash) => {
    let transactionReceipt = await web3.eth.getTransactionReceipt(txHash)
    while(transactionReceipt != null && transactionReceipt.status === 'FALSE') {
        transactionReceipt = await web3.eth.getTransactionReceipt(txHash)
        await new Promise(r => setTimeout(r, 4000))
    }
    return transactionReceipt
}

const main = async() => {
    let domain0Rpc = process.env.DOMAIN_0_RPC
    const web3 = new Web3(domain0Rpc)
    
    // Add domain 0 private key used for signing transactions
    const domain0Signer = web3.eth.accounts.privateKeyToAccount(process.env.DOMAIN_0_PRIVATE_KEY)
    web3.eth.accounts.wallet.add(domain0Signer)

    // Add domain 1 private key used for signing transactions
    const domain1Signer = web3.eth.accounts.privateKeyToAccount(process.env.DOMAIN_1_PRIVATE_KEY)
    web3.eth.accounts.wallet.add(domain1Signer)

    // Contract Addresses
    const DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS = process.env.DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS
    const USDC_DOMAIN_0_CONTRACT_ADDRESS = process.env.USDC_DOMAIN_0_CONTRACT_ADDRESS
    const DOMAIN_0_MESSAGE_CONTRACT_ADDRESS = process.env.DOMAIN_0_MESSAGE_CONTRACT_ADDRESS
    const DOMAIN_1_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS = process.env.DOMAIN_1_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS

    const DOMAIN_1_TOKEN_MESSENGER_CONTRACT_ADDRESS = process.env.DOMAIN_1_TOKEN_MESSENGER_CONTRACT_ADDRESS
    const USDC_DOMAIN_1_CONTRACT_ADDRESS = process.env.USDC_DOMAIN_1_CONTRACT_ADDRESS
    const DOMAIN_1_MESSAGE_CONTRACT_ADDRESS = process.env.DOMAIN_1_MESSAGE_CONTRACT_ADDRESS
    const DOMAIN_0_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS = process.env.DOMAIN_0_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS

    // initialize contracts using address and ABI
    const domain0TokenMessengerContract = new web3.eth.Contract(tokenMessengerAbi, DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS, {from: domain0Signer.address})
    const usdcDomain0Contract = new web3.eth.Contract(usdcAbi, USDC_DOMAIN_0_CONTRACT_ADDRESS, {from: domain0Signer.address})
    const domain0MessageContract = new web3.eth.Contract(messageAbi, DOMAIN_0_MESSAGE_CONTRACT_ADDRESS, {from: domain0Signer.address})
    const domain1MessageTransmitterContract = new web3.eth.Contract(messageTransmitterAbi, DOMAIN_1_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS, {from: domain1Signer.address})

    const domain1TokenMessengerContract = new web3.eth.Contract(tokenMessengerAbi, DOMAIN_1_TOKEN_MESSENGER_CONTRACT_ADDRESS, {from: domain1Signer.address})
    const usdcDomain1Contract = new web3.eth.Contract(usdcAbi, USDC_DOMAIN_1_CONTRACT_ADDRESS, {from: domain1Signer.address})
    const domain1MessageContract = new web3.eth.Contract(messageAbi, DOMAIN_1_MESSAGE_CONTRACT_ADDRESS, {from: domain1Signer.address})
    const domain0MessageTransmitterContract = new web3.eth.Contract(messageTransmitterAbi, DOMAIN_0_MESSAGE_TRANSMITTER_CONTRACT_ADDRESS, {from: domain0Signer.address})

    // Domain 0 destination address
    const mintRecipientDomain0 = domain1Signer.address
    const destinationAddressDomain0InBytes32 = await domain0MessageContract.methods.addressToBytes32(mintRecipientDomain0).call()
    const DOMAIN_0_ID = process.env.DOMAIN_0_ID
    const DOMAIN_1_ID = process.env.DOMAIN_1_ID

    // Amount that will be transferred
    const amount = process.env.AMOUNT

    // STEP 1: Approve messenger contract to withdraw from our domain 0 address
    await approve(web3, usdcDomain0Contract, DOMAIN_0_TOKEN_MESSENGER_CONTRACT_ADDRESS, amount * 10)

    console.log('after approve on domain 0, sleep 10s')
    await new Promise(r => setTimeout(r, 10000));

    // STEP 2: Burn USDC on domain 0
    let burnTxHashDomain0 = await burn(web3, amount, domain0TokenMessengerContract, DOMAIN_1_ID, destinationAddressDomain0InBytes32, USDC_DOMAIN_0_CONTRACT_ADDRESS)

    console.log('after depositForBurn on domain 0, sleep 10s')
    await new Promise(r => setTimeout(r, 10000));

    // STEP 3: Retrieve domain 0 burn message bytes from logs
    let messageBytesDomain0 = await getMessageBytes(web3, burnTxHashDomain0)

    const messageHashDomain0 = web3.utils.keccak256(messageBytesDomain0)
    console.log(`MessageHashDomain0: ${messageHashDomain0}`)

    // STEP 4: Fetch attestation signature
    let attestationSignatureDomain0 = await getAttestationSignature(messageHashDomain0)

    // STEP 5: Using the message bytes and signature, receive the funds on domain 1
    await receiveMessage(web3, process.env.DOMAIN_1_RPC, domain1MessageTransmitterContract, attestationSignatureDomain0, messageBytesDomain0)

    // Domain 1 destination address
    const mintRecipientDomain1 = domain0Signer.address
    const destinationAddressDomain1InBytes32 = await domain1MessageContract.methods.addressToBytes32(mintRecipientDomain1).call()

    // STEP 6: approve token messenger contract to withdraw on domain 1
    await approve(web3, usdcDomain1Contract, DOMAIN_1_TOKEN_MESSENGER_CONTRACT_ADDRESS, amount * 10)

    console.log('after approve on domain 1, sleep 10s')
    await new Promise(r => setTimeout(r, 10000));

    // STEP 7: Burn USDC on domain 1
    let burnTxHashDomain1 = await burn(web3, amount, domain1TokenMessengerContract, DOMAIN_0_ID, destinationAddressDomain1InBytes32, USDC_DOMAIN_1_CONTRACT_ADDRESS)

    console.log('after depositForBurn on domain 1, sleep 10s')
    await new Promise(r => setTimeout(r, 10000));

    // STEP 8: Retrieve domain 1 burn message bytes from logs
    let messageBytesDomain1 = await getMessageBytes(web3, burnTxHashDomain1)

    let messageHashDomain1 =  web3.utils.keccak256(messageBytesDomain1)
    console.log(`MessageHashDomain1: ${messageHashDomain1}`)

    // STEP 9: Fetch attestation signature for message from domain 1
    let attestationSignatureDomain1 = await getAttestationSignature(messageHashDomain1)

    // STEP 10: Using the message bytes and signature, receive the funds on domain 0
    await receiveMessage(web3, domain0Rpc, domain0MessageTransmitterContract, attestationSignatureDomain1, messageBytesDomain1)
}

async function approve(web3, usdcContract, tokenMessengerContractAddress, amount) {
    const approveTxGas = await usdcContract.methods.approve(tokenMessengerContractAddress, amount).estimateGas()
    const approveTx = await usdcContract.methods.approve(tokenMessengerContractAddress, amount).send({gas: approveTxGas})
    const approveTxReceipt = await waitForTransaction(web3, approveTx.transactionHash)
    console.log('ApproveTxReceipt: ', approveTxReceipt)
}

async function burn(web3, amount, tokenMessengerContract, domainId, destinationAddressBytes32, usdcContractAddress) {
    const burnTxGas = await tokenMessengerContract.methods.depositForBurn(amount, domainId, destinationAddressBytes32, usdcContractAddress).estimateGas()
    const burnTx = await tokenMessengerContract.methods.depositForBurn(amount, domainId, destinationAddressBytes32, usdcContractAddress).send({gas: burnTxGas})
    const burnTxReceipt = await waitForTransaction(web3, burnTx.transactionHash)
    console.log('BurnTxReceipt: ', burnTxReceipt)
    return burnTx.transactionHash
}

async function getMessageBytes(web3, burnTxHash) {
    const transactionReceipt = await web3.eth.getTransactionReceipt(burnTxHash)
    const eventTopic = web3.utils.keccak256('MessageSent(bytes)')
    const log = transactionReceipt.logs.find((l) => l.topics[0] === eventTopic)
    const messageBytes = web3.eth.abi.decodeParameters(['bytes'], log.data)[0]

    console.log(`MessageBytes: ${messageBytes}`)
    return messageBytes
}

async function getAttestationSignature(messageHash) {
    let attestationResponse = {status: 'pending'}
    while(attestationResponse.status != 'complete') {
        const response = await fetch(`${process.env.IRIS_API_URL}/attestations/${messageHash}`)
        attestationResponse = await response.json()
        await new Promise(r => setTimeout(r, 2000))
    }

    console.log(`Signature: ${attestationResponse.attestation}`)
    return attestationResponse.attestation 
}

async function receiveMessage(web3, rpcUrl, messageTransmitterContract, attestation, messageBytes) {
    web3.setProvider(rpcUrl)
    const receiveTxGas = await messageTransmitterContract.methods.receiveMessage(messageBytes, attestation).estimateGas()
    const receiveTx = await messageTransmitterContract.methods.receiveMessage(messageBytes, attestation).send({gas: receiveTxGas})
    const receiveTxReceipt = await waitForTransaction(web3, receiveTx.transactionHash)
    console.log('ReceiveTxReceipt: ', receiveTxReceipt)
}

main()
