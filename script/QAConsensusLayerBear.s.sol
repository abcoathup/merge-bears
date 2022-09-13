// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ConsensusLayerBear.sol";
import "../src/NounsGlasses.sol";
import "../src/Crown.sol";
import "../src/Box.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract QAConsensusLayerBearScript is Script, ERC721Holder {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        ConsensusLayerBear token = new ConsensusLayerBear();
        token.mint{value: token.price()}();

        Box background = new Box();
        background.mint{value: background.price()}();

        NounsGlasses glasses = new NounsGlasses();
        glasses.mint{value: glasses.price()}();

        Crown crown = new Crown();
        crown.mint{value: crown.price()}();

        background.approve(address(token), 1);
        token.addBackground(1, address(background), 1);

        glasses.approve(address(token), 1);
        token.addAccessory(1, address(glasses), 1);

        crown.approve(address(token), 1);
        token.addAccessory(1, address(crown), 1);


        console.log(token.tokenURI(1));

        vm.stopBroadcast();
    }
}
