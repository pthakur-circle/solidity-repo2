/* SPDX-License-Identifier: UNLICENSED
 *
 * Copyright (c) 2023, Circle Internet Financial Trading Company Limited.
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

pragma solidity ^0.8.3;

import "forge-std/Test.sol";
import "../contracts/CircleMaticBridge.sol";
import "../contracts/test/mocks/MintBurnTokenMock.sol";
import "../contracts/test/mocks/IRootChainManagerMock.sol";

contract ContractTest is Test {
    CircleMaticBridge _circleMaticBridge;
    MintBurnTokenMock _parentToken;
    IRootChainManagerMock _rootChainManager;
    address _parentTokenAddress;
    address _rootChainManagerAddress;
    address _erc20PredicateAddress;
    address _maticReserveAddress;
    address _ethReserveAddress;
    uint256 _amount;

    /**
     * @notice Emitted when a new mintAndBridge transaction happens
     * @param parentToken address of the parent token
     * @param maticReserve address of the matic reserve
     * @param amount amount to mint and bridge
     */
    event MintAndBridge(
        address indexed parentToken, 
        address indexed maticReserve, 
        uint256 amount
    );

    /**
     * @notice Emitted when a new unbridgeAndBurn transaction happens
     * @param parentToken address of the parent token
     * @param amount amount to unbridge and burn
     */
    event UnbridgeAndBurn(
        address indexed parentToken, 
        uint256 amount
    );

    /**
     * @notice Emitted when a new transferAndBridge transaction happens
     * @param parentToken address of the parent token
     * @param ethReserve address of the eth reserve
     * @param maticReserve address of the matic reserve
     * @param amount amount to unbridge and burn
     */
    event TransferAndBridge(
        address indexed parentToken, 
        address indexed ethReserve, 
        address indexed maticReserve, 
        uint256 amount
    );

    /**
     * @notice Emitted when a new unbridgeAndTransfer transaction happens
     * @param parentToken address of the parent token
     * @param ethReserve address of the eth reserve
     * @param amount amount to unbridge and burn
     */
    event UnbridgeAndTransfer(
        address indexed parentToken, 
        address indexed ethReserve, 
        uint256 amount
    );

    function setUp() public {
        _parentToken = new MintBurnTokenMock();
        _rootChainManager = new IRootChainManagerMock();
        _circleMaticBridge = new CircleMaticBridge();

        _parentTokenAddress = address(_parentToken);
        _rootChainManagerAddress = address(_rootChainManager);
        _erc20PredicateAddress = vm.addr(1);
        _maticReserveAddress = vm.addr(2);
        _ethReserveAddress = vm.addr(3);

        _amount = 3; // default valid amount to use for testing bridge functions
    }

    function testMintAndBridge_revertsWhenCallerIsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");

        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress, 
            _amount
        );
    }

    function testMintAndBridge_revertsWhenAmountIsZeroOrNegative() public {
        vm.expectRevert("Invalid number of tokens to mintAndBridge: must be positive.");
        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress, 
            0 /* amount */
        );
    }
    
    function testMintAndBridge_revertsWhenTokenMintFunctionReverts() public {
        _parentToken.mockConfigureMinter(address(_circleMaticBridge), 0);
        vm.expectRevert("MintBurnTokenMock: mint amount exceeds minterAllowance");
        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress, 
            _amount
        );
    }
    
    function testMintAndBridge_revertsWhenTokenApproveFunctionReverts() public {
        _parentToken.mockConfigureMinter(address(_circleMaticBridge), _amount);
        address zeroAddress = address(0);

        vm.expectRevert("MintBurnTokenMock: approve to the zero address");
        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            zeroAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress, 
            _amount
        );
    }
    
    function testMintAndBridge_revertsWhenRootChainManagerDepositForFunctionReverts() public {
        _parentToken.mockConfigureMinter(address(_circleMaticBridge), _amount);

        vm.expectRevert("IRootChainManagerMock: INVALID_USER");
        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            address(0), 
            _amount
        );
    }
    
    function testMintAndBridge_succeedsAndEmitsMintAndBridgeEvent() public {
        _parentToken.mockConfigureMinter(address(_circleMaticBridge), _amount);

        // assert that a MintAndBridge event was logged with expected fields.
        vm.expectEmit(true, true, true, true);
        emit MintAndBridge(_parentTokenAddress, _maticReserveAddress, _amount);
        _circleMaticBridge.mintAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress, 
            _amount
        );
    }
    
    function testUnbridgeAndBurn_revertsWhenCallerIsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        _circleMaticBridge.unbridgeAndBurn(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            _amount
        );
    }

    function testUnbridgeAndBurn_revertsWhenAmountIsZeroOrNegative() public {
        vm.expectRevert("Invalid number of tokens to unbridgeAndBurn: must be positive.");
        _circleMaticBridge.unbridgeAndBurn(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            0 /* amount */
        );
    }
    
    function testUnbridgeAndBurn_revertsWhenRootChainManagerExitFunctionReverts() public {
        vm.expectRevert("IRootChainManagerMock: INVALID INPUT DATA");
        _circleMaticBridge.unbridgeAndBurn(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress,
            abi.encode(), 
            _amount
        );
    }
    
    function testUnbridgeAndBurn_revertsWhenTokenBurnFunctionReverts() public {
        vm.expectRevert("MintBurnTokenMock: burn amount exceeds balance");
        _circleMaticBridge.unbridgeAndBurn(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            15
        );
    }
    
    function testUnbridgeAndBurn_succeedsAndEmitsUnbridgeAndBurnEvent() public {
        // assert that a UnbridgeAndBurn event was logged with expected fields.
        vm.expectEmit(true, true, true, true);
        emit UnbridgeAndBurn(_parentTokenAddress, _amount);
        _circleMaticBridge.unbridgeAndBurn(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            _amount
        );
    }
    
    function testUnbridgeAndTransfer_revertsWhenAmountIsZeroOrNegative() public {
        vm.expectRevert("Invalid number of tokens to unbridgeAndTransfer: must be positive.");
        _circleMaticBridge.unbridgeAndTransfer(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            0 /* amount */
        );
    }
    
    function testUnbridgeAndTransfer_revertsWhenTransferZeroAddressToken() public {
        vm.expectRevert(); // forge test does not return specific error message for general VM exceptions
        _circleMaticBridge.unbridgeAndTransfer(
            address(0), 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            _amount
        );
    }

    function testUnbridgeAndTransfer_revertsWhenRootChainManagerExitFunctionReverts() public {
        vm.expectRevert("IRootChainManagerMock: INVALID INPUT DATA");
        _circleMaticBridge.unbridgeAndTransfer(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress,
            abi.encode(), 
            _amount
        );
    }

    function testUnbridgeAndTransfer_succeedsAndEmitsUnbridgeAndTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit UnbridgeAndTransfer(_parentTokenAddress, _ethReserveAddress, _amount);
        _circleMaticBridge.unbridgeAndTransfer(
            _parentTokenAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress,
            abi.encode("Block Proof"), 
            _amount
        );
    }
    
    function testTransferAndBridge_revertsWhenAmountIsZeroOrNegative() public {
        vm.expectRevert("Invalid number of tokens to transferAndBridge: must be positive.");
        _circleMaticBridge.transferAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress, 
            0 /* amount */
        );
    }
    
    function testTransferAndBridge_revertsWhenRootChainManagerDepositForFunctionReverts() public {
        vm.expectRevert("IRootChainManagerMock: INVALID_USER");
        _circleMaticBridge.transferAndBridge(
            _parentTokenAddress, 
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            address(0), 
            _amount
        );
    }
    
    function testTransferAndBridge_revertsWhenTokenApproveFunctionReverts() public {
        vm.expectRevert("MintBurnTokenMock: approve to the zero address");
        _circleMaticBridge.transferAndBridge(
            _parentTokenAddress, 
            address(0), 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress, 
            _amount
        );
    }

    function testTransferAndBridge_succeedsAndEmitsTransferAndBridgeEvent() public {
        // assert that a TransferAndBridge event was logged with expected fields.
        vm.expectEmit(true, true, true, true);
        emit TransferAndBridge(_parentTokenAddress, _ethReserveAddress, _maticReserveAddress, _amount);
        _circleMaticBridge.transferAndBridge(
            _parentTokenAddress,
            _erc20PredicateAddress, 
            _rootChainManagerAddress, 
            _ethReserveAddress,
            _maticReserveAddress, 
            _amount
        );
    }
}
