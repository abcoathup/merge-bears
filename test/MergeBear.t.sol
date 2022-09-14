// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
import "../src/ERC4883Composer.sol";
import "../src/ExecutionLayerBear.sol";
import "../src/ConsensusLayerBear.sol";
import "../src/MergeBear.sol";
import "./mocks/MockERC4883.sol";
import "./mocks/MockERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract MergeBearTest is Test, ERC721Holder {
    ExecutionLayerBear public elToken;
    ConsensusLayerBear public clToken;
    MergeBear public token;
    MockERC721 public erc721;
    MockERC4883 public background;
    MockERC4883 public accessory1;
    MockERC4883 public accessory2;
    MockERC4883 public accessory3;
    MockERC4883 public accessory4;

    string public constant NAME = "Merge Bear";
    string public constant SYMBOL = "MB";
    uint256 public constant OWNER_ALLOCATION = 0; // set by client bears
    uint256 public constant SUPPLY_CAP = 0; // set by client bears
    uint256 constant PRICE = 0.00042 ether;

    string constant TOKEN_NAME = "Token Name";
    address constant OTHER_ADDRESS = address(23);

    function setUp() public {
        elToken = new ExecutionLayerBear();
        clToken = new ConsensusLayerBear();
        token = new MergeBear(address(clToken), address(elToken));

        elToken.setMergeBear(address(token));
        clToken.setMergeBear(address(token));

        erc721 = new MockERC721("ERC721", "NFT");
        background = new MockERC4883("Background", "BACK", 0, 10, 100);
        accessory1 = new MockERC4883("Accessory1", "ACC1", 0, 10, 100);
        accessory2 = new MockERC4883("Accessory2", "ACC2", 0, 10, 100);
        accessory3 = new MockERC4883("Accessory3", "ACC3", 0, 10, 100);
        accessory4 = new MockERC4883("Accessory4", "ACC4", 0, 10, 100);
    }

    function testMetadata() public {
        assertEq(token.name(), NAME);
        assertEq(token.symbol(), SYMBOL);
        assertEq(token.price(), PRICE);
    }

    function testOwner() public {
        assertEq(token.owner(), address(this));
    }

    function testSupportsERC4883() public {
        assertEq(token.supportsInterface(type(IERC4883).interfaceId), true);
    }

    function testWithdraw(uint96 amount) public {
        vm.assume(amount >= PRICE);
        vm.assume(amount < 42 ether);

        address recipient = address(2);

        elToken.mint{value: elToken.price()}();
        clToken.mint{value: clToken.price()}();
        token.mint{value: amount}(1, 1);

        token.withdraw(recipient);

        assertEq(address(recipient).balance, amount);
        assertEq(address(token).balance, 0 ether);
    }

    // // Set JWT
    // consensusLayerBear.setJwt(consensusLayerBearTokenId, executionLayerBearTokenId);
    // executionLayerBear.setJwt(executionLayerBearTokenId, consensusLayerBearTokenId);

    function testMintNotExecutionLayerBearOwner() public {
        elToken.mint{value: elToken.price()}();
        clToken.mint{value: clToken.price()}();

        elToken.safeTransferFrom(address(this), OTHER_ADDRESS, 1);

        vm.expectRevert(MergeBear.NotExecutionLayerBearOwner.selector);
        token.mint{value: PRICE}(1, 1);
    }

    function testMintNotConsensusLayerBearOwner() public {
        elToken.mint{value: elToken.price()}();
        clToken.mint{value: clToken.price()}();

        clToken.safeTransferFrom(address(this), OTHER_ADDRESS, 1);

        vm.expectRevert(MergeBear.NotConsensusLayerBearOwner.selector);
        token.mint{value: PRICE}(1, 1);
    }

    function testMintCLJwtAlreadySet() public {
        elToken.mint{value: elToken.price()}();
        clToken.mint{value: clToken.price()}();

        elToken.mint{value: elToken.price()}();

        token.mint{value: PRICE}(1, 1);

        vm.expectRevert(ConsensusLayerBear.JwtAlreadySet.selector);
        token.mint{value: PRICE}(1, 2);
    }

    function testMintELJwtAlreadySet() public {
        elToken.mint{value: elToken.price()}();
        clToken.mint{value: clToken.price()}();

        clToken.mint{value: clToken.price()}();

        token.mint{value: PRICE}(1, 1);

        vm.expectRevert(ConsensusLayerBear.JwtAlreadySet.selector);
        token.mint{value: PRICE}(2, 1);
    }
}
