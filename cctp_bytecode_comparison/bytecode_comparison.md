# Bytecode comparison

## Overview
The purpose of this comparison is to prove that there are no unexpected differences in the bytecode of each deployed contract from the bytecode at the commit when each contract was audited.

Process:
1. Get the local bytecode by checking out commit hash 40111601620071988e94e39274c8f48d6f406d6d (final commit from ChainSecurity audit)
2. Build local ETH contracts: `forge inspect {ContractName} bytecode --optimizer-runs 100000`
3. Build local AVAX contracts: `forge inspect {ContractName} bytecode --optimizer-runs 200`
4. Get ETH contracts from Etherscan
- MessageTransmitter: 0x0a992d191DEeC32aFe36203Ad87D7d289a738F81
- TokenMessenger: 0xBd3fa81B58Ba92a82136038B25aDec7066af3155
- TokenMinter: 0xc4922d64a24675E16e1586e3e3Aa56C06fABe907
- Message: 0xb2f38107a18f8599331677c14374fd3a952fb2c8

5. Get AVAX contracts from Snowtrace
- MessageTransmitter: 0x8186359af5f57fbb40c6b14a588d2a59c0c29880
- TokenMessenger: 0x6B25532e1060CE10cc3B0A99e5683b91BFDe6982
- TokenMinter: 0x420f5035fd5dc62a167e7e7f08b604335ae272b8
- Message: 0x21f337db7a718f23e061262470af8c1fd01232d1, 0x58d896fc62f98917ff4635de794e6ad93c1b156d.
(Note: there are two Message library contracts used on the AVAX side with identical bytecode.)

6. Compare each local bytecode to its associated deployed bytecode on the explorer, verifying that there are no differences, except the following:
    1. Swarm source: 64-character hash used to lookup contract's metadata on Swarm (distributed file system)
    2. Message library variables are replaced by deployed library address
    3. constructor params: these are encoded at the end of deployed bytecode

## Diffs
### ETH MessageTransmitter: Local (100k optimizer runs) Vs. Etherscan
1. a9a77e6a797fb6e9b83a1153ef1552c5a40dce7158ef22ad109af5e3f77f3182 vs. e2eab27571cb9d2ecf49a592b1b78e24c28061c662fef829a376f797fcfcd158: Swarm Source (see e2...58 on https://etherscan.io/address/0x0a992d191DEeC32aFe36203Ad87D7d289a738F81#code)
2. __$8c977731748aa4504deed57239565df533$__ vs. b2f38107a18f8599331677c14374fd3a952fb2c8: Message Library
3. 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0ea8e1be37f346c7ea7ec708834d0db18a1736100000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _localDomain (uint32): 0
- Arg [1] : _attester (address): 0xb0Ea8E1bE37F346C7EA7ec708834D0db18A17361
- Arg [2] : _maxMessageBodySize (uint32): 8192
- Arg [3] : _version (uint32): 0

### ETH TokenMessenger: Local (100k optimizer runs) vs. Etherscan
1. d07122efa0c3599571c81c376aba5ef5f1adf0746c63b6a3b94b6b2ef4ce805c vs. 6b689f34f4e15f499706461beeb293d1cec2381023fbd21a46dcbc1856ad2388: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs. b2f38107a18f8599331677c14374fd3a952fb2c8: Message Library
3. 0000000000000000000000000a992d191deec32afe36203ad87d7d289a738f810000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _messageTransmitter (address): 0x0a992d191DEeC32aFe36203Ad87D7d289a738F81
- Arg [1] : _messageBodyVersion (uint32): 0

### ETH TokenMinter: Local (100k optimizer runs) vs. Etherscan
1. 79dd51b1ffda453fbaec48b9b924c984aa0be0c348c9b93981fb34e117e40af364736f6c63430007060033 vs. 37224bb8cd1d6105c267ba4d98325c99695b35022354f9a8c5badd2eea50bf1a: Swarm Source
2. N/A
3. 0000000000000000000000003e6ec8b95763a740692dd28a5bba0ac7a2f14209 is the constructor args:
- Arg [0] : _tokenController (address): 0x3e6EC8b95763a740692dd28a5BBA0AC7a2F14209

### ETH Message Library (100k optimizer runs) vs. Etherscan
1. ebc5e416fdd00987910adebc9b19bcb677fe3ef08cc3bf2a8492a878b7472697 vs. 9c0e0302de62378b5fb807b07acbde44d29479df481f5b62e2cebbe0a7229b8d: Swarm Source
2. N/A
3. N/A

---

### AVAX MessageTransmitter: Local (200 optimizer runs) vs. Snowtrace
1. d5ae62666899cb9b32ae1968ecd63c3a31a0cce23910ad96bf3aaed675aa0abd vs. ef2b7d268bf27b37974b5f902f755dabb92dd41112ac4aef706b8c044a69b008: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs 21f337db7a718f23e061262470af8c1fd01232d1: Message Library
3. 0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000b0ea8e1be37f346c7ea7ec708834d0db18a1736100000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _localDomain (uint32): 1
- Arg [1] : _attester (address): 0xb0ea8e1be37f346c7ea7ec708834d0db18a17361
- Arg [2] : _maxMessageBodySize (uint32): 8192
- Arg [3] : _version (uint32): 0

### AVAX TokenMessenger: Local (200 optimizer runs) vs. Snowtrace
1. 84724fde49aa4fe13970ac0b5300ea07a7ba89ad7d195221dbc321316a99789d vs. f3fa53371a6ece086d941db2c14ab177fcc1a79582d1bc3e398e3854634a196c: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs. 58d896fc62f98917ff4635de794e6ad93c1b156d: Message library
3. 0000000000000000000000008186359af5f57fbb40c6b14a588d2a59c0c298800000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _messageTransmitter (address): 0x8186359af5f57fbb40c6b14a588d2a59c0c29880
- Arg [1] : _messageBodyVersion (uint32): 0

### AVAX TokenMinter: Local (200 optimizer runs) vs. Snowtrace
1. bcce08cb506508c197a4f8c0490f170491c33baf356c581d389177dd537503fd vs. c4c385622d91f435ff5131d58f06ef7dd45e5f67a6241b89ba1c575fbb6eea1f: Swarm Source
2. N/A
3. 00000000000000000000000009bd965b694608f245f7880e462e0933829732a2: constructor args
- Arg [0] : _tokenController (address): 0x09bd965b694608f245f7880e462e0933829732a2

### AVAX Message Library (200 optimizer runs) vs. Snowtrace
1. 1cc86b5d46f2e96998d810b543fc457e49963bc53efadec8227fb79ce961b180 vs 8404296badaef08d58c3bff31538c0b3255dac6b929ac372cc285c74383ad77c: Swarm Source
2. N/A
3. N/A

---

### ARB MessageTransmitter: Local (100k optimizer runs) Vs. Arbiscan
1. a9a77e6a797fb6e9b83a1153ef1552c5a40dce7158ef22ad109af5e3f77f3182 vs. e2eab27571cb9d2ecf49a592b1b78e24c28061c662fef829a376f797fcfcd158: Swarm Source (see e2...58 on https://arbiscan.io/address/0xC30362313FBBA5cf9163F0bb16a0e01f01A896ca#code)
2. __$8c977731748aa4504deed57239565df533$__ vs. e189bdcfbcecec917b937247666a44ed959d81e4: Message Library
3. 0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000b0ea8e1be37f346c7ea7ec708834d0db18a1736100000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _localDomain (uint32): 3
- Arg [1] : _attester (address): 0xb0Ea8E1bE37F346C7EA7ec708834D0db18A17361
- Arg [2] : _maxMessageBodySize (uint32): 8192
- Arg [3] : _version (uint32): 0

### ARB TokenMessenger: Local (100k optimizer runs) vs. Arbiscan
1. d07122efa0c3599571c81c376aba5ef5f1adf0746c63b6a3b94b6b2ef4ce805c vs. 6b689f34f4e15f499706461beeb293d1cec2381023fbd21a46dcbc1856ad2388: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs. e189bdcfbcecec917b937247666a44ed959d81e4: Message Library
3. 000000000000000000000000c30362313fbba5cf9163f0bb16a0e01f01a896ca0000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _messageTransmitter (address): 0xc30362313fbba5cf9163f0bb16a0e01f01a896ca
- Arg [1] : _messageBodyVersion (uint32): 0

### ARB TokenMinter: Local (100k optimizer runs) vs. Etherscan
1. 79dd51b1ffda453fbaec48b9b924c984aa0be0c348c9b93981fb34e117e40af364736f6c63430007060033 vs. 37224bb8cd1d6105c267ba4d98325c99695b35022354f9a8c5badd2eea50bf1a: Swarm Source
2. N/A
3. 00000000000000000000000074b721389e632f213e0fdde5f2e4170375ddddfc is the constructor args:
- Arg [0] : _tokenController (address): 0x74b721389e632f213e0fdde5f2e4170375ddddfc

### ARB Message Library (100k optimizer runs) vs. Etherscan
1. ebc5e416fdd00987910adebc9b19bcb677fe3ef08cc3bf2a8492a878b7472697 vs. 9c0e0302de62378b5fb807b07acbde44d29479df481f5b62e2cebbe0a7229b8d: Swarm Source
2. N/A
3. N/A

---

### OP MessageTransmitter: Local (100k optimizer runs) Vs. Optimistic Etherscan
1. a9a77e6a797fb6e9b83a1153ef1552c5a40dce7158ef22ad109af5e3f77f3182 vs. e2eab27571cb9d2ecf49a592b1b78e24c28061c662fef829a376f797fcfcd158: Swarm Source (see e2...58 on https://optimistic.etherscan.io/address/0x4D41f22c5a0e5c74090899E5a8Fb597a8842b3e8#code)
2. __$8c977731748aa4504deed57239565df533$__ vs. db2831eaf163be1b564d437a97372deb0046c70d: Message Library
3. 0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000b0ea8e1be37f346c7ea7ec708834d0db18a1736100000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _localDomain (uint32): 2
- Arg [1] : _attester (address): 0xb0ea8e1be37f346c7ea7ec708834d0db18a17361
- Arg [2] : _maxMessageBodySize (uint32): 8192
- Arg [3] : _version (uint32): 0

### OP TokenMessenger: Local (100k optimizer runs) vs. Optimistic Etherscan
1. d07122efa0c3599571c81c376aba5ef5f1adf0746c63b6a3b94b6b2ef4ce805c vs. 6b689f34f4e15f499706461beeb293d1cec2381023fbd21a46dcbc1856ad2388: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs. db2831eaf163be1b564d437a97372deb0046c70d: Message Library
3. 0000000000000000000000004d41f22c5a0e5c74090899e5a8fb597a8842b3e80000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _messageTransmitter (address): 0x4d41f22c5a0e5c74090899e5a8fb597a8842b3e8
- Arg [1] : _messageBodyVersion (uint32): 0

### OP TokenMinter: Local (100k optimizer runs) vs. Optimistic Etherscan
1. 79dd51b1ffda453fbaec48b9b924c984aa0be0c348c9b93981fb34e117e40af364736f6c63430007060033 vs. 37224bb8cd1d6105c267ba4d98325c99695b35022354f9a8c5badd2eea50bf1a: Swarm Source
2. N/A
3. 0000000000000000000000007b7909b6932bc755d06fe43c88008e7aaf56a0da is the constructor args:
- Arg [0] : _tokenController (address): 0x7b7909b6932bc755d06fe43c88008e7aaf56a0da

### OP Message Library (100k optimizer runs) vs. Optimistic Etherscan
1. ebc5e416fdd00987910adebc9b19bcb677fe3ef08cc3bf2a8492a878b7472697 vs. 9c0e0302de62378b5fb807b07acbde44d29479df481f5b62e2cebbe0a7229b8d: Swarm Source
2. N/A
3. N/A

---

### BASE MessageTransmitter: Local (100k optimizer runs) Vs. Basescan
1. a9a77e6a797fb6e9b83a1153ef1552c5a40dce7158ef22ad109af5e3f77f3182 vs. e2eab27571cb9d2ecf49a592b1b78e24c28061c662fef829a376f797fcfcd158: Swarm Source (see e2...58 on https://basescan.org/address/0xAD09780d193884d503182aD4588450C416D6F9D4#code)
2. __$8c977731748aa4504deed57239565df533$__ vs. 827ae40e55c4355049ab91e441b6e269e4091441: Message Library
3.0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000b0ea8e1be37f346c7ea7ec708834d0db18a1736100000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _localDomain (uint32): 6
- Arg [1] : _attester (address): 0xb0ea8e1be37f346c7ea7ec708834d0db18a17361
- Arg [2] : _maxMessageBodySize (uint32): 8192
- Arg [3] : _version (uint32): 0

### Base TokenMessenger: Local (100k optimizer runs) vs. Basescan
1. d07122efa0c3599571c81c376aba5ef5f1adf0746c63b6a3b94b6b2ef4ce805c vs. 6b689f34f4e15f499706461beeb293d1cec2381023fbd21a46dcbc1856ad2388: Swarm Source
2. __$8c977731748aa4504deed57239565df533$__ vs. 827ae40e55c4355049ab91e441b6e269e4091441: Message Library
3. 000000000000000000000000ad09780d193884d503182ad4588450c416d6f9d40000000000000000000000000000000000000000000000000000000000000000 is the constructor args:
- Arg [0] : _messageTransmitter (address): 0xad09780d193884d503182ad4588450c416d6f9d4
- Arg [1] : _messageBodyVersion (uint32): 0

### Base TokenMinter: Local (100k optimizer runs) vs. Basescan
1. 79dd51b1ffda453fbaec48b9b924c984aa0be0c348c9b93981fb34e117e40af364736f6c63430007060033 vs. 37224bb8cd1d6105c267ba4d98325c99695b35022354f9a8c5badd2eea50bf1a: Swarm Source
2. N/A
3. 000000000000000000000000ba5f8595045eda51282f3606e01581cb5a6f08e4 is the constructor args:
- Arg [0] : _tokenController (address): 0xba5f8595045eda51282f3606e01581cb5a6f08e4

### Base Message Library (100k optimizer runs) vs. Basescan
1. ebc5e416fdd00987910adebc9b19bcb677fe3ef08cc3bf2a8492a878b7472697 vs. 9c0e0302de62378b5fb807b07acbde44d29479df481f5b62e2cebbe0a7229b8d: Swarm Source
2. N/A
3. N/A
