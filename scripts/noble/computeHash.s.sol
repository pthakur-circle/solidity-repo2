/*
 * Copyright (c) 2023, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity 0.7.6;

import "forge-std/Script.sol";

contract DeployScript is Script {
    string denom;

    /**
     * @notice main function that will be run by forge
     */
    function computeHash(string memory) public {
        bytes32 _hash = keccak256(abi.encodePacked(denom));
        console.logBytes32(_hash);
    }

    function setUp() public {
        denom = vm.envString("DENOM");
    }

    function run() public {
        setUp();

        computeHash(denom);
    }
}
