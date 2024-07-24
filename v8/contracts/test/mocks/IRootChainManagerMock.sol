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
 * @title IRootChainManagerMock
 * Mock contract for testing
 */
contract IRootChainManagerMock {
    function depositFor(address user, address rootToken, bytes calldata depositData) external {
        require(
            user != address(0),
            "IRootChainManagerMock: INVALID_USER"
        );
    }

    function exit(bytes calldata inputData) external {
        require(
            inputData.length != 0,
            "IRootChainManagerMock: INVALID INPUT DATA"
        );
    }
}
