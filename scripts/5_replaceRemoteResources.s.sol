pragma solidity 0.7.6;

import "forge-std/Script.sol";
import "../src/TokenMessenger.sol";
import "../src/TokenMinter.sol";
import "../src/messages/Message.sol";

contract ReplaceRemoteResourcesScript is Script {
    address private usdcRemoteContractAddress;
    address private usdcRemoteContractAddressDeprecated;
    address private usdcContractAddress;
    address private remoteTokenMessengerAddress;
    address private tokenMessengerContractAddress;
    address private tokenMinterContractAddress;

    uint32 private remoteDomain;

    uint256 private tokenMessengerDeployerPrivateKey;
    uint256 private tokenControllerPrivateKey;

    /**
     * @notice link current chain and remote chain tokens
     */
    function linkTokenPair(TokenMinter tokenMinter, uint256 privateKey)
        private
    {
        // Start recording transactions
        vm.startBroadcast(privateKey);

        bytes32 remoteUsdcContractAddressInBytes32 = Message.addressToBytes32(
            usdcRemoteContractAddress
        );

        tokenMinter.linkTokenPair(
            usdcContractAddress,
            remoteDomain,
            remoteUsdcContractAddressInBytes32
        );

        // Stop recording transactions
        vm.stopBroadcast();
    }

    /**
     * @notice unlink current chain and remote chain tokens
     */
    function unlinkTokenPair(TokenMinter tokenMinter, uint256 privateKey)
        private
    {
        // Start recording transactions
        vm.startBroadcast(privateKey);

        bytes32 remoteUsdcContractAddressInBytes32 = Message.addressToBytes32(
            usdcRemoteContractAddressDeprecated
        );

        tokenMinter.unlinkTokenPair(
            usdcContractAddress,
            remoteDomain,
            remoteUsdcContractAddressInBytes32
        );

        // Stop recording transactions
        vm.stopBroadcast();
    }

    /**
     * @notice add address of TokenMessenger deployed on another chain
     */
    function addRemoteTokenMessenger(
        TokenMessenger tokenMessenger,
        uint256 privateKey
    ) private {
        // Start recording transactions
        vm.startBroadcast(privateKey);
        bytes32 remoteTokenMessengerAddressInBytes32 = Message.addressToBytes32(
            remoteTokenMessengerAddress
        );
        tokenMessenger.addRemoteTokenMessenger(
            remoteDomain,
            remoteTokenMessengerAddressInBytes32
        );

        // Stop recording transactions
        vm.stopBroadcast();
    }

    /**
     * @notice remove address of TokenMessenger deployed on another chain
     */
    function removeRemoteTokenMessenger(
        TokenMessenger tokenMessenger,
        uint256 privateKey
    ) private {
        // Start recording transactions
        vm.startBroadcast(privateKey);
        tokenMessenger.removeRemoteTokenMessenger(remoteDomain);

        // Stop recording transactions
        vm.stopBroadcast();
    }

    /**
     * @notice initialize variables from environment
     */
    function setUp() public {
        tokenMessengerDeployerPrivateKey = vm.envUint(
            "TOKEN_MESSENGER_DEPLOYER_KEY"
        );
        tokenControllerPrivateKey = vm.envUint("TOKEN_CONTROLLER_KEY");

        tokenMessengerContractAddress = vm.envAddress(
            "TOKEN_MESSENGER_CONTRACT_ADDRESS"
        );
        tokenMinterContractAddress = vm.envAddress(
            "TOKEN_MINTER_CONTRACT_ADDRESS"
        );
        usdcContractAddress = vm.envAddress(
            "USDC_CONTRACT_ADDRESS"
        );
        usdcRemoteContractAddress = vm.envAddress(
            "REMOTE_USDC_CONTRACT_ADDRESS"
        );
        usdcRemoteContractAddressDeprecated = vm.envAddress(
            "REMOTE_USDC_CONTRACT_ADDRESS_DEPRECATED"
        );
        remoteTokenMessengerAddress = vm.envAddress(
            "REMOTE_TOKEN_MESSENGER_ADDRESS"
        );

        remoteDomain = uint32(vm.envUint("REMOTE_DOMAIN"));
    }

    /**
     * @notice main function that will be run by forge
     *         this unlinks the deprecated remote usdc token and the remote token messenger
     *         and relinks the updated remote usdc token and the remote token messenger
     */
    function run() public {
        TokenMessenger tokenMessenger = TokenMessenger(tokenMessengerContractAddress);
        TokenMinter tokenMinter = TokenMinter(tokenMinterContractAddress);

        unlinkTokenPair(tokenMinter, tokenControllerPrivateKey);
        removeRemoteTokenMessenger(tokenMessenger, tokenMessengerDeployerPrivateKey);

        linkTokenPair(tokenMinter, tokenControllerPrivateKey);
        addRemoteTokenMessenger(tokenMessenger, tokenMessengerDeployerPrivateKey);
    }
}