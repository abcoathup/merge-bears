// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ConsensusLayerBear.sol";

contract ConsensusLayerBearScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ConsensusLayerBear token = new ConsensusLayerBear();

        vm.stopBroadcast();
    }
}
