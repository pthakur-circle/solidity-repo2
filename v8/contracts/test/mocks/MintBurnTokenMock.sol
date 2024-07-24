/* SPDX-License-Identifier: UNLICENSED
 *
 * Copyright (c) 2021, Circle Internet Financial Trading Company Limited.
 * All rights reserved.
 *
 * Circle Internet Financial Trading Company Limited CONFIDENTIAL
 *
 * This file includes unpublished proprietary source code of Circle Internet
 * Financial Trading Company Limited, Inc. The copyright notice above does not
 * evidence any actual or intended publication of such source code. Disclosure
 * of this source code or any related proprietary information is strictly
 * prohibited without the express written permission of Circle Internet Financial
 * Trading Company Limited.
 */

pragma solidity 0.8.3;

/**
 * @title MintBurnTokenMock
 * Mock contract for testing
 */
contract MintBurnTokenMock {
    mapping(address => uint256) internal mockMinterAllowed;

    function mint(address _to, uint256 _amount) external returns (bool) {
        uint256 mintingAllowedAmount = mockMinterAllowed[msg.sender];
        require(
            _amount <= mintingAllowedAmount,
            "MintBurnTokenMock: mint amount exceeds minterAllowance"
        );
    }

    function burn(uint256 _amount) external {
        // mock that the balance is only 10
        require(10 >= _amount, "MintBurnTokenMock: burn amount exceeds balance");

    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "MintBurnTokenMock: approve to the zero address");
    }

    function mockConfigureMinter(address minter, uint256 minterAllowedAmount) external {
        mockMinterAllowed[minter] = minterAllowedAmount;
    }
}
