// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ZoraCoin.sol";

contract ZoraCoinFactory is Script {
    function run() external {
        // Get the private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the factory contract
        ZoraCoinFactory factory = new ZoraCoinFactory();

        // Log the deployed factory address
        console.log("ZoraCoinFactory deployed at:", address(factory));

        // Example of creating a coin through the factory (optional)
        // string memory name = "Test Coin";
        // string memory symbol = "TEST";
        // string memory metadataUri = "ipfs://Qm...";
        // address payoutRecipient = vm.envAddress("DEPLOYER_ADDRESS");
        // address platformReferrer = address(0);
        // uint256 initialPurchaseWei = 0;
        
        // address newCoin = factory.createCoin(
        //     name,
        //     symbol,
        //     metadataUri,
        //     payoutRecipient,
        //     platformReferrer,
        //     initialPurchaseWei
        // );
        
        // console.log("New ZoraCoin created at:", newCoin);

        vm.stopBroadcast();
    }
}