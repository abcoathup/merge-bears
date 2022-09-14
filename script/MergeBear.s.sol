// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ConsensusLayerBear.sol";
import "../src/ExecutionLayerBear.sol";
import "../src/MergeBear.sol";

contract MergeBearScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // constructor(address consensusLayerBear_, address executionLayerBear_)
        MergeBear token =
            new MergeBear(0xfb3999711d4f309F6B71504268F79b3fD578DA6F, 0x22Cd0e2680f4B9aE140E3b9AbFA3463532e290Ff);

        vm.stopBroadcast();
    }
}
