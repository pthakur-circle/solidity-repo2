# Unbacked Mint Testing Script Overview

This directory includes a script and instructions for triggering an unbacked mint of USDC.
**This should be used in smokebox only and is for verification that Retina is working as expected.**

To do this we use the randomly generated keypair below as an attester so we can sign a fake burn
message locally, triggering the unbacked mint.

Fraudulent Attester:

- Address: `0x8C446B149AfB2c3E71fbC140C18B3C15D144093d`
- Private Key: `0x2f1b057ca7cf464dcfd922f998ac00e65ef6dd0890c0cc86f1e9a106d545a56f` 

To Trigger the unbacked mint follow these steps:

1. Enable the random key below as an attester. The `attester_manager_private_key` can be found in 1Password in the `Testnet CCTP Private Keys / Addresses` note.
    - `cast send {MessageTransmitter contract address} "enableAttester(address)" 0x8C446B149AfB2c3E71fbC140C18B3C15D144093d --rpc-url {rpc_url} --private-key {attester_manager_private_key}`

2. Decrease the signature threshold to 1 so only our fraudulent attester has to sign the attestation.
    - `cast send {MessageTransmitter contract address} "setSignatureThreshold(uint256)" 1 --rpc-url {rpc url} --private-key {attester_manager_private_key}`

3. Generate a fake burn message.
    - We can do this via [Tenderly](https://tenderly.co/). Create a free account and then create a Fork of a previously CCTP integrated testnet like AVAX Fuji C-Chain. 
    - Then, create a simulation on this fork, using a custom contract with the `TokenMessenger` contract address of the forked network. Click `Use fetched ABI` and select `DepositForBurn`. 
    - Fill in the parameters, using the domain of the new chain you are wanting to test. 
    - Run the simulation, then click on the Events tab, and copy the message emitted from the `MessageSent` event.

4. Sign the fake message locally.
    - `export MESSAGE_BYTES={message emitted from Tenderly tx}`
    - `export ATTESTER_PRIVATE_KEY=0x2f1b057ca7cf464dcfd922f998ac00e65ef6dd0890c0cc86f1e9a106d545a56f`
    - `python3 signMessage.py`

5. Receive the message on the chain you are testing.
    - `cast send {MessageTransmitter contract address} "receiveMessage(bytes, bytes)" {fraudulent_message} {fraudulent_attestation}  --rpc-url {rpc url}`

6. Clean up.
    - `cast call {MessageTransmitter contract address} "disableAttester(address)" 0x8C446B149AfB2c3E71fbC140C18B3C15D144093d --rpc-url {rpc_url} --private-key {attester_manager_private_key}`
    - `cast call {MessageTransmitter contract address} ""setSignatureThreshold(uint256)"" 2 --rpc-url {rpc url} --private-key {attester_manager_private_key}`
    - Once you verify the mint is not matched with a burn and an alert is loggged in Retina, create a techops ticket marking the MintAndWithdraw event as analyzed - https://circle-engineering.zendesk.com/hc/en-us/requests/92962.
