// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IClientBear is IERC165, IERC721 {
    function setJwt(uint256 tokenId, uint256 clientTokenId) external;

    function clientId(uint256 tokenId) external view returns (uint8);

    function colourId(uint256 tokenId) external view returns (uint8);
}
