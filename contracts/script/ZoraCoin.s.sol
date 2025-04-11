// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ZoraCoin.sol";

contract ZoraCoin is Script {
    function run() external {
        // Get the private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the factory contract
        ZoraCoinFactory factory = new ZoraCoinFactory();

        // Log the deployed factory address
        console.log("ZoraCoinFactory deployed at:", address(factory));

        vm.stopBroadcast();
    }
}