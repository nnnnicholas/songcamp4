// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "erc721a/contracts/ERC721A.sol";
import {Base64} from "base64-sol/base64.sol"; // Facilitates encoding SVG as base64
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract CD is ERC721A {
    using Strings for uint256;

    uint256 public immutable price;
    string private baseUri;
    mapping(uint256 => uint256) public cdToSongs;
    mapping(uint256 => bool) public claimed;

    constructor(uint _price) ERC721A("CAMP4 CDs", "CD") {
        price = _price;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function mint(uint256 quantity) external payable {
        require(msg.value >= quantity * price, "Insufficient funds");
        _mint(msg.sender, quantity);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    function checkValue(uint256 value) public pure returns (bool) {
        // Four 24s packed into a uint256 is equivalent to shifting 24 left by 5 bits, three times
        // and then adding 24 to it
        uint256 max = ((24 << 5) << 5) << (5 + 24);

        // If value is greater than max, it contains more than four 24s
        require(value <= max, "Value exceeds four 24s");

        for (uint i = 0; i < 4; i++) {
            uint256 song = (value >> (i * 5)) & 31;
            if (song > 24 || song < 1) {
                return false;
            }
        }

        return true;
    }

    function decompose(uint256 value) public pure returns (uint8[4] memory) {
        uint8[4] memory values;

        values[0] = uint8((value >> 15) & 31);
        values[1] = uint8((value >> 10) & 31);
        values[2] = uint8((value >> 5) & 31);
        values[3] = uint8((value) & 31);

        return values;
    }

    function packValues(uint8 v1, uint8 v2, uint8 v3, uint8 v4) public pure returns (uint256) {
        require(v1 <= 24 && v2 <= 24 && v3 <= 24 && v4 <= 24, "All values must be 24 or less");
        require(v1 > 0 && v2 > 0 && v3 > 0 && v4 > 0, "All values must be greater than 0");

        uint256 packed = uint256(v4);
        packed |= uint256(v3) << 5;
        packed |= uint256(v2) << 10;
        packed |= uint256(v1) << 15;

        return packed;
    }

    function burnSongsEasy(uint256 tokenId, uint8 track1, uint8 track2, uint8 track3, uint8 track4) external {
        uint packedVals = packValues(track1, track2, track3, track4);
        burnSongs(tokenId, packedVals);
    }

    function burnSongs(uint256 tokenId, uint256 songsToBurn) public {
        // check that caller owns the nft
        require(ownerOf(tokenId) == msg.sender, "Caller does not own the token");
        // check that the token exists
        require(_exists(tokenId), "Token does not exist");
        // check that the are not yet burned
        require(claimed[tokenId] == false, "Already claimed");
        // decompose songsToBurn into 4 songs and check that there are 4 songs selected
        require(checkValue(songsToBurn), "Invalid songs");
        // check that each track is only present once
        uint8[4] memory songs = decompose(songsToBurn);
        require(songs[0] != songs[1] && songs[1] != songs[2] && songs[2] != songs[3], "Duplicate songs");
        // check that the songs are valid
        cdToSongs[tokenId] = songsToBurn;
        claimed[tokenId] = true;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string[] memory parts = new string[](4);
        parts[0] = string("data:application/json;base64,");
        parts[1] = string(
            abi.encodePacked(
                '{"name":"CD #',
                tokenId.toString(),
                '",',
                '"description":"Description Text",',
                '"image":"data:image/svg+xml;base64,'
            )
        );
        if (claimed[tokenId] == false) {
            parts[2] = Base64.encode(
                abi.encodePacked(
                    '<svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">',
                    '<rect width="1000" height="1000" fill="beige"/>',
                    // '<circle r="50" cx="450" cy="450" fill="blue" />',
                    '<text x="40" y="135" font-size="28px">',
                    "token #",
                    tokenId.toString(),
                    "</text>",
                    '<text x="40" y="180" font-size="28px">',
                    "CD-R",
                    "</text>",
                    "</svg>"
                )
            );
        } else {
            uint8[4] memory songs = decompose(cdToSongs[tokenId]);
            parts[2] = Base64.encode(
                abi.encodePacked(
                    '<svg width="1000" height="1000" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">',
                    '<rect width="1000" height="1000" fill="pink"/>',
                    '<text x="40" y="135" font-size="28px">',
                    "token #",
                    tokenId.toString(),
                    "</text>",
                    '<text x="40" y="180" font-size="28px">',
                    "burned tracks: ",
                    uint(songs[0]).toString(),
                    ", ",
                    uint(songs[1]).toString(),
                    ", ",
                    uint(songs[2]).toString(),
                    ", ",
                    uint(songs[3]).toString(),
                    "</text>",
                    "</svg>"
                )
            );
        }
        parts[3] = string('"}');

        string memory uri = string.concat(parts[0], Base64.encode(abi.encodePacked(parts[1], parts[2], parts[3])));

        return uri;
    }
}
