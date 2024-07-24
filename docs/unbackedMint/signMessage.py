import os
from web3 import Web3

messageBytes = os.environ['MESSAGE_BYTES']
privateKey = os.environ['ATTESTER_PRIVATE_KEY']

messageHash = Web3.keccak(hexstr=messageBytes)
w3 = Web3()
signature = w3.eth.account.signHash(messageHash, privateKey).signature

print("Attestation: ", Web3.toHex(signature))
