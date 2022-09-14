// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
import "../src/ERC4883Composer.sol";
import "../src/ExecutionLayerBear.sol";
import "./mocks/MockERC4883.sol";
import "./mocks/MockERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract ExecutionLayerBearTest is Test, ERC721Holder {
    ExecutionLayerBear public token;
    MockERC721 public erc721;
    MockERC4883 public background;
    MockERC4883 public accessory1;
    MockERC4883 public accessory2;
    MockERC4883 public accessory3;
    MockERC4883 public accessory4;

    string public constant NAME = "Execution Layer Bear";
    string public constant SYMBOL = "ELB";
    uint256 public constant OWNER_ALLOCATION = 119; // 119 Protocol Guild members
    uint256 public constant SUPPLY_CAP = 3675; // https://eips.ethereum.org/EIPS/eip-3675/
    uint256 constant PRICE = 0.00042 ether;

    string constant TOKEN_NAME = "Token Name";
    address constant OTHER_ADDRESS = address(23);

    function setUp() public {
        token = new ExecutionLayerBear();
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
        address recipient = address(2);

        vm.assume(amount >= PRICE);
        token.mint{value: amount}();

        token.withdraw(recipient);

        assertEq(address(recipient).balance, amount);
        assertEq(address(token).balance, 0 ether);
    }

    function testSetMergeBearNotOwner(address nonOwner) public {
        vm.assume(nonOwner != address(this));
        vm.assume(nonOwner != address(0));

        address mergeBear = address(42);

        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMergeBear(mergeBear);
    }

    function testSetMergeBearAlreadySet(address mergeBear) public {
        vm.assume(mergeBear != address(0));

        token.setMergeBear(mergeBear);

        vm.expectRevert(ExecutionLayerBear.MergeBearAlreadySet.selector);
        token.setMergeBear(mergeBear);
    }

    function testSetJwt() public {
        address mergeBear = address(42);
        uint256 tokenId = 1;
        uint256 consensusLayerTokenId = 1;

        token.setMergeBear(mergeBear);

        token.mint{value: PRICE}();

        vm.prank(mergeBear);
        token.setJwt(tokenId, consensusLayerTokenId);
    }

    function testSetJwtNotMergeBear(address nonMergeBear) public {
        address mergeBear = address(42);
        uint256 tokenId = 1;
        uint256 consensusLayerTokenId = 1;

        vm.assume(nonMergeBear != address(0));
        vm.assume(nonMergeBear != mergeBear);

        token.setMergeBear(mergeBear);

        token.mint{value: PRICE}();

        vm.expectRevert(ExecutionLayerBear.NotMergeBear.selector);
        vm.prank(nonMergeBear);
        token.setJwt(tokenId, consensusLayerTokenId);
    }

    function testSetJwtNonexistentToken(uint256 tokenId) public {
        address mergeBear = address(42);
        uint256 consensusLayerTokenId = 1;

        token.setMergeBear(mergeBear);

        vm.expectRevert(ERC4883.NonexistentToken.selector);
        vm.prank(mergeBear);
        token.setJwt(tokenId, consensusLayerTokenId);
    }

    function testSetJwtAlreadySet() public {
        address mergeBear = address(42);
        uint256 tokenId = 1;
        uint256 consensusLayerTokenId = 1;

        token.setMergeBear(mergeBear);

        token.mint{value: PRICE}();

        vm.prank(mergeBear);
        token.setJwt(tokenId, consensusLayerTokenId);

        vm.expectRevert(ExecutionLayerBear.JwtAlreadySet.selector);
        vm.prank(mergeBear);
        token.setJwt(tokenId, consensusLayerTokenId);
    }

    function testClientIdNonexistentToken(uint256 tokenId) public {
        vm.expectRevert(ERC4883.NonexistentToken.selector);
        token.clientId(tokenId);
    }

    function testColourIdNonexistentToken(uint256 tokenId) public {
        vm.expectRevert(ERC4883.NonexistentToken.selector);
        token.colourId(tokenId);
    }
}
