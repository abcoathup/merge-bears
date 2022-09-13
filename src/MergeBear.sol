// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883Composer} from "./ERC4883Composer.sol";
import {IERC4883} from "./IERC4883.sol";
import {Colours} from "./Colours.sol";
import {EthereumClients} from "./EthereumClients.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IClientBear} from "./IClientBear.sol";

// ░█▄█░█▀▀░█▀▄░█▀▀░█▀▀░░░█▀▄░█▀▀░█▀█░█▀▄
// ░█░█░█▀▀░█▀▄░█░█░█▀▀░░░█▀▄░█▀▀░█▀█░█▀▄
// ░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░░▀▀░░▀▀▀░▀░▀░▀░▀
contract MergeBear is ERC4883Composer, Colours, EthereumClients, ERC721Holder {
    /// ERRORS

    /// @notice Thrown when not a client bear
    error NotClientBear();

    /// @notice Thrown when not the Consensus Layer Bear owner
    error NotConsensusLayerBearOwner();

    /// @notice Thrown when not the Execution Layer Bear owner
    error NotExecutionLayerBearOwner();

    /// EVENTS

    struct MergeData {
        uint8 consensusClientId;
        uint8 consensusColourId;
        uint8 executionClientId;
        uint8 executionColourId;
    }

    mapping(uint256 => MergeData) private _mergeData;

    IClientBear private immutable consensusLayerBear;
    IClientBear private immutable executionLayerBear;

    // Supply is controlled by supply of Consensus & Execution Layer Bears
    constructor(address consensusLayerBear_, address executionLayerBear_)
        ERC4883Composer("Merge Bear", "MB", 0.00042 ether, 0xeB10511109053787b3ED6cc02d5Cb67A265806cC, 0, 0)
    {
        consensusLayerBear = IClientBear(consensusLayerBear_);

        if (!consensusLayerBear.supportsInterface(type(IClientBear).interfaceId)) {
            revert NotClientBear();
        }

        executionLayerBear = IClientBear(executionLayerBear_);

        if (!executionLayerBear.supportsInterface(type(IClientBear).interfaceId)) {
            revert NotClientBear();
        }
    }

    function mint(uint256 consensusLayerBearTokenId, uint256 executionLayerBearTokenId) public payable {
        mint(msg.sender, consensusLayerBearTokenId, executionLayerBearTokenId);
    }

    function mint(address to, uint256 consensusLayerBearTokenId, uint256 executionLayerBearTokenId) public payable {
        if (msg.value < price) {
            revert InsufficientPayment();
        }

        // Check token owners match sender
        if (consensusLayerBear.ownerOf(consensusLayerBearTokenId) != msg.sender) {
            revert NotConsensusLayerBearOwner();
        }

        if (executionLayerBear.ownerOf(executionLayerBearTokenId) != msg.sender) {
            revert NotExecutionLayerBearOwner();
        }

        // Set JWT
        consensusLayerBear.setJwt(consensusLayerBearTokenId, executionLayerBearTokenId);
        executionLayerBear.setJwt(executionLayerBearTokenId, consensusLayerBearTokenId);

        unchecked {
            totalSupply++;
        }

        _mergeData[totalSupply] = MergeData(
            consensusLayerBear.clientId(consensusLayerBearTokenId),
            consensusLayerBear.colourId(consensusLayerBearTokenId),
            executionLayerBear.clientId(executionLayerBearTokenId),
            executionLayerBear.colourId(executionLayerBearTokenId)
        );

        _safeMint(to, totalSupply);
    }

    function _generateDescription(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat("Merge Bear.  Bear #", Strings.toString(tokenId), ".  ERC4883 composable NFT");
    }

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory attributes = string.concat(
            '{"trait_type": "Execution Client", "value": "',
            _generateExecutionClient(tokenId),
            '"}, {"trait_type": "Consensus Client", "value": "',
            _generateConsensusClient(tokenId),
            '"}, {"trait_type": "Execution Colour", "value": "',
            _generateExecutionColour(tokenId),
            '"}, {"trait_type": "Consensus Colour", "value": "',
            _generateConsensusColour(tokenId),
            '"}',
            _generateAccessoryAttributes(tokenId),
            _generateBackgroundAttributes(tokenId)
        );

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateSVG(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory svg = string.concat(
            '<svg id="merge-bear" width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            _generateBackground(tokenId),
            _generateSVGBody(tokenId),
            _generateAccessories(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateSVGBody(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory consensusColourValue = _generateConsensusColour(tokenId);
        string memory executionColourValue = _generateExecutionColour(tokenId);

        return string.concat(
            '<g id="merge-bear-',
            Strings.toString(tokenId),
            '">' "<desc>Merge Bear</desc>"
            '<g stroke="black" stroke-width="10" stroke-linecap="round" stroke-linejoin="round">'
            '<path d="M141.746 364.546C88.0896 338.166 67.7686 339.117 54.9706 378.618C58.0112 418.292 64.3272 429.537 80.7686 437.25C104.636 448.709 170.876 432.772 247.283 422.005C354.846 435.377 424.823 445.054 438.422 437.25C458.371 424.569 466.499 414.297 464.22 378.618C445.099 351.034 433.356 339.684 403.243 356.338L365.719 336.403L141.746 364.546Z" fill="#383838" />'
            '<path d="M289.498 101.876C331.996 80.7832 329.868 101.341 328.195 149.954L289.498 101.876Z" fill="#696969" />'
            '<path d="M166.371 134.71C159.627 93.6161 168.829 83.778 208.586 96.0128L166.371 134.71Z" fill="#696969" />'
            '<path d="M328.195 149.954C287.152 66.6969 206.241 66.6969 162.853 142.918C142.529 198.634 141.272 222.583 172.234 241.419C236.394 285.393 269.181 279.975 334.058 241.419C342.266 228.521 349.3 182.978 328.195 149.954Z" fill="#F8F8F8" />'
            '<path d="M182.788 416.142L172.234 319.986H305.915V425.523C267.207 438.31 226.501 448.015 182.788 416.142Z" fill="#F8F8F8" />'
            '<path d="M203.895 438.422C188.866 441.956 126.168 466.883 112.43 429.041C113.412 402.012 115.628 378.479 120.983 355.165C128.972 320.386 143.947 286.097 172.234 241.42C237.262 281.898 267.857 272.611 332.885 242.592C361.052 282.666 377.85 317.581 377.663 346.957C377.6 356.842 380.012 367.162 377.663 378.618C377.663 378.618 373.927 400.898 373.927 429.041C373.927 457.185 297.706 465.393 289.498 429.041C281.289 392.69 286.505 410.486 297.706 346.957C263.52 339.96 240.669 340.596 195.687 346.957C202.359 358.413 218.925 434.889 203.895 438.422Z" fill="#383838" />'
            '<path d="M294.188 133.537C278.558 140.565 272.033 146.383 264.872 160.508C283.729 170.948 293.316 180.152 308.26 203.895L321.159 186.306C315.382 159.43 310.699 146.264 294.188 133.537Z" fill="#696969" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M207.241 139.228C219.2 152.324 213.673 152.092 217.794 160.335C206.104 161.8 197.052 169.693 176.752 195.514C174.004 187.729 173.302 187.34 169.716 175.579C166.13 163.819 195.281 126.131 207.241 139.228Z" fill="#696969" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M244.5 271.287C324.5 271.287 334 160.882 240 160.882C146 160.882 164.5 271.287 244.5 271.287Z" fill="#F8F8F8" stroke="black" stroke-width="10"/>'
            '<path d="M215.622 195.687C226.175 185.133 255.491 189.824 260.182 198.032C248.455 209.758 227.348 207.413 215.622 195.687Z" fill="black" />'
            '<path d="M221.485 228.521C242.828 237.607 245.499 236.723 263.7 228.521" />' "</g>"
            '<circle cx="194.788" cy="165.645" r="10" fill="black"/>'
            '<circle cx="286.599" cy="166.99" r="10" fill="black"/>' '<g stroke="',
            consensusColourValue,
            '" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" fill="none">'
            '<path d="M287.216 286L286.968 286.843V311.308L287.216 311.556L298.572 304.843L287.216 286Z" />'
            '<path d="M287.216 286L275.86 304.843L287.216 311.556V299.681V286Z" />'
            '<path d="M287.216 311.556L298.572 304.843L287.216 299.681V311.556Z" />'
            '<path d="M275.86 304.843L287.216 311.556V299.681L275.86 304.843Z" />' "</g>" '<g stroke="',
            executionColourValue,
            '" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" fill="none">'
            '<path d="M287.216 323V313.706L275.86 306.997L287.216 323Z" />'
            '<path d="M287.216 313.706L287.076 313.877V322.592L287.216 323L298.579 306.997L287.216 313.706Z" />' "</g>"
            "</g>"
        );

        // Merge Bear SVG

        // <svg width="500" height="500" viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg">
        // <g stroke="black" stroke-width="10" stroke-linecap="round" stroke-linejoin="round">
        // <path d="M141.746 364.546C88.0896 338.166 67.7686 339.117 54.9706 378.618C58.0112 418.292 64.3272 429.537 80.7686 437.25C104.636 448.709 170.876 432.772 247.283 422.005C354.846 435.377 424.823 445.054 438.422 437.25C458.371 424.569 466.499 414.297 464.22 378.618C445.099 351.034 433.356 339.684 403.243 356.338L365.719 336.403L141.746 364.546Z" fill="#383838" />
        // <path d="M289.498 101.876C331.996 80.7832 329.868 101.341 328.195 149.954L289.498 101.876Z" fill="#696969" />
        // <path d="M166.371 134.71C159.627 93.6161 168.829 83.778 208.586 96.0128L166.371 134.71Z" fill="#696969" />
        // <path d="M328.195 149.954C287.152 66.6969 206.241 66.6969 162.853 142.918C142.529 198.634 141.272 222.583 172.234 241.419C236.394 285.393 269.181 279.975 334.058 241.419C342.266 228.521 349.3 182.978 328.195 149.954Z" fill="#F8F8F8" />
        // <path d="M182.788 416.142L172.234 319.986H305.915V425.523C267.207 438.31 226.501 448.015 182.788 416.142Z" fill="#F8F8F8" />
        // <path d="M203.895 438.422C188.866 441.956 126.168 466.883 112.43 429.041C113.412 402.012 115.628 378.479 120.983 355.165C128.972 320.386 143.947 286.097 172.234 241.42C237.262 281.898 267.857 272.611 332.885 242.592C361.052 282.666 377.85 317.581 377.663 346.957C377.6 356.842 380.012 367.162 377.663 378.618C377.663 378.618 373.927 400.898 373.927 429.041C373.927 457.185 297.706 465.393 289.498 429.041C281.289 392.69 286.505 410.486 297.706 346.957C263.52 339.96 240.669 340.596 195.687 346.957C202.359 358.413 218.925 434.889 203.895 438.422Z" fill="#383838" />
        // <path d="M294.188 133.537C278.558 140.565 272.033 146.383 264.872 160.508C283.729 170.948 293.316 180.152 308.26 203.895L321.159 186.306C315.382 159.43 310.699 146.264 294.188 133.537Z" fill="#696969" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>
        // <path d="M207.241 139.228C219.2 152.324 213.673 152.092 217.794 160.335C206.104 161.8 197.052 169.693 176.752 195.514C174.004 187.729 173.302 187.34 169.716 175.579C166.13 163.819 195.281 126.131 207.241 139.228Z" fill="#696969" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>
        // <path d="M244.5 271.287C324.5 271.287 334 160.882 240 160.882C146 160.882 164.5 271.287 244.5 271.287Z" fill="#F8F8F8" stroke="black" stroke-width="10"/>
        // <path d="M215.622 195.687C226.175 185.133 255.491 189.824 260.182 198.032C248.455 209.758 227.348 207.413 215.622 195.687Z" fill="black" />
        // <path d="M221.485 228.521C242.828 237.607 245.499 236.723 263.7 228.521" />
        // </g>
        // <circle cx="194.788" cy="165.645" r="10" fill="black"/>
        // <circle cx="286.599" cy="166.99" r="10" fill="black"/>
        // </svg>

        // Ethereum Logo SVG
        // <svg width="500" height="500" viewBox="0 0 500 500" fill="none" xmlns="http://www.w3.org/2000/svg">

        // <g stroke="blue" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" fill="none">
        // <path d="M287.216 286L286.968 286.843V311.308L287.216 311.556L298.572 304.843L287.216 286Z" />
        // <path d="M287.216 286L275.86 304.843L287.216 311.556V299.681V286Z" />
        // <path d="M287.216 311.556L298.572 304.843L287.216 299.681V311.556Z" />
        // <path d="M275.86 304.843L287.216 311.556V299.681L275.86 304.843Z" />
        // </g>

        // <g stroke="red" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" fill="none">
        // <path d="M287.216 323V313.706L275.86 306.997L287.216 323Z" />
        // <path d="M287.216 313.706L287.076 313.877V322.592L287.216 323L298.579 306.997L287.216 313.706Z" />
        // </g>

        // </svg>
    }

    function _generateConsensusClient(uint256 tokenId) internal view returns (string memory) {
        return consensusLayerClients[_mergeData[tokenId].consensusClientId];
    }

    function _generateExecutionClient(uint256 tokenId) internal view returns (string memory) {
        return consensusLayerClients[_mergeData[tokenId].executionClientId];
    }

    function _generateConsensusColour(uint256 tokenId) internal view returns (string memory) {
        return colours[_mergeData[tokenId].consensusColourId];
    }

    function _generateExecutionColour(uint256 tokenId) internal view returns (string memory) {
        return colours[_mergeData[tokenId].executionColourId];
    }

    function _generateTokenName(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat(_generateConsensusClient(tokenId), " + ", _generateExecutionClient(tokenId), " Bear");
    }
}

//  ____________
// < Merge Bear >
//  ------------
//         \   ^__^
//          \  (oo)\_______
//             (__)\       )\/\
//                 ||----w |
//                 ||     ||
