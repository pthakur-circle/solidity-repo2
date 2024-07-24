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

import "@openzeppelin/contracts/access/Ownable.sol";
import "./thirdparty/matic/IRootChainManager.sol";
import "./thirdparty/MintBurnTokenInterface.sol";

contract CircleMaticBridge is Ownable {

    event MintAndBridge(address indexed parentToken, address indexed maticReserve, uint256 amount);
    event UnbridgeAndBurn(address indexed parentToken, uint256 amount);
    event TransferAndBridge(address indexed parentToken, address indexed ethReserve, address indexed maticReserve, uint256 amount);
    event UnbridgeAndTransfer(address indexed parentToken, address indexed ethReserve, uint256 amount);

    /**
     * @dev Function to mint erc20 tokens to a side chain, by first minting the parent asset on the main chain,
     * then locking up the parent asset and bridging the child asset to the side chain.
     * @param parentToken The address of the parent asset to be minted.
     * @param erc20Predicate The address of the ERC20Predicate to be approved for locking up the parent asset.
     * @param rootChainManager The address of the RootChainManager to perform the bridging.
     * @param maticReserve The address on the side chain to receive the child assets.
     * @param amount The number of tokens to lock up and mint.
     */
    function mintAndBridge(address parentToken, address erc20Predicate, address rootChainManager, address maticReserve, uint256 amount) public onlyOwner {
        require(amount > 0, "Invalid number of tokens to mintAndBridge: must be positive.");

        MintBurnTokenInterface token = MintBurnTokenInterface(parentToken);

        // Step 1: mint to the circle bridge contract on main chain.
        token.mint(address(this), amount);

        // Step 2: approve the ERC20Predicate to lock up the bridge contract's minted tokens.
        token.approve(erc20Predicate, amount);

        // Step 3: perform bridge by locking up the parent tokens on the main chain and depositing child tokens on side chain.
        bytes memory data = abi.encode(amount);
        IRootChainManager manager = IRootChainManager(rootChainManager);
        manager.depositFor(maticReserve, parentToken, data);

        // emit MintAndBridge event
        emit MintAndBridge(parentToken, maticReserve, amount);
    }

    /**
     * @dev Function to transfer erc20 token to bridge contract address from the eth reserve
     * then bridge to side chain
     * @param parentToken The address of the parent asset
     * @param erc20Predicate The address of the ERC20Predicate to be approved for locking up the parent asset.
     * @param rootChainManager The address of the RootChainManager to perform the bridging.
     * @param ethReserve The address of the eth reserve address to transfer tokens in order to bridge.
     * @param maticReserve The address on the matic reserve address.
     * @param amount The number of tokens to lock up.
     */
    function transferAndBridge(address parentToken, address erc20Predicate, address rootChainManager, address ethReserve, address maticReserve, uint256 amount) public onlyOwner {
        require(amount > 0, "Invalid number of tokens to transferAndBridge: must be positive.");

        MintBurnTokenInterface token = MintBurnTokenInterface(parentToken);

        // Step 1: transfer funds from reserve address to the bridge contract address
        token.transferFrom(ethReserve, address(this), amount);

        // Step 2: approve the ERC20Predicate to lock up the bridge contract's tokens.
        token.approve(erc20Predicate, amount);

        // Step 3: perform bridge by locking up the parent tokens on the main chain and syncing state to the side chain
        bytes memory data = abi.encode(amount);
        IRootChainManager manager = IRootChainManager(rootChainManager);
        manager.depositFor(maticReserve, parentToken, data);

        // emit TransferAndBridge event
        emit TransferAndBridge(parentToken, ethReserve, maticReserve, amount);
    }

    /**
     * @dev Function to burn erc20 tokens on the main chain, by first calling exit on the RootChainManager
     * with proof of the side chain burn to unlock the parent asset, transferring the released assets
     * to this CircleMaticBridge contract, then burning the unlocked parent asset.
     * @param parentToken The address of the parent asset to be burned.
     * @param rootChainManager The address of the RootChainManager to perform the unlocking.
     * @param maticReserve The Matic reserve address that initiated the side chain burn.
     * @param proofOfBurnData The proof of burn calldata, includes encoded fields: https://github.com/maticnetwork/pos-portal/blob/d06271188412a91ab9e4bdea4bbbfeb6cb9d7669/contracts/root/RootChainManager/RootChainManager.sol#L325-L334
     * @param amount The number of tokens to unlock and burn.
     */
    function unbridgeAndBurn(address parentToken, address rootChainManager, address maticReserve, bytes calldata proofOfBurnData, uint256 amount) public onlyOwner {
        require(amount > 0, "Invalid number of tokens to unbridgeAndBurn: must be positive.");

        MintBurnTokenInterface token = MintBurnTokenInterface(parentToken);

        // Step 1: call exit to unlock assets on the main chain.
        // The assets will be released to the address that initiated the side chain burn.
        IRootChainManager manager = IRootChainManager(rootChainManager);
        manager.exit(proofOfBurnData);

        // Step 2: transfer the released assets to the bridge contract.
        token.transferFrom(maticReserve, address(this), amount);

        // Step 3: burn the parent asset.
        token.burn(amount);

        // emit UnbridgeAndBurn event
        emit UnbridgeAndBurn(parentToken, amount);
    }

    /**
     * @dev Function to transfer erc20 token to the eth reserve address from side chain
     * @param parentToken The address of the parent asset
     * @param rootChainManager The address of the RootChainManager to perform the unlocking.
     * @param ethReserve The reserve address on the main chain to receive the child assets.
     * @param maticReserve The Matic reserve address to transfer
     * @param proofOfBurnData The proof of burn calldata, includes encoded fields: https://github.com/maticnetwork/pos-portal/blob/d06271188412a91ab9e4bdea4bbbfeb6cb9d7669/contracts/root/RootChainManager/RootChainManager.sol#L325-L334
     * @param amount The number of tokens to transfer.
     */
    function unbridgeAndTransfer(address parentToken, address rootChainManager, address ethReserve, address maticReserve, bytes calldata proofOfBurnData, uint256 amount) public onlyOwner {
        require(amount > 0, "Invalid number of tokens to unbridgeAndTransfer: must be positive.");

        MintBurnTokenInterface token = MintBurnTokenInterface(parentToken);

        // Step 1: call exit to unlock assets on the main chain.
        // The assets will be released to the address that initiated the side chain burn.
        IRootChainManager manager = IRootChainManager(rootChainManager);
        manager.exit(proofOfBurnData);

        // Step 2: transfer the released assets to the reserve address.
        token.transferFrom(maticReserve, ethReserve, amount);

        // emit UnbridgeAndTransfer event
        emit UnbridgeAndTransfer(parentToken, ethReserve, amount);
    }
}
