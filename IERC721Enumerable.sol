// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.16;
interface IERC721Enumerable /* is ERC721 */ {

    function totalSupply() external view returns (uint256);
    // function tokenByIndex(uint256 _index) external view returns (uint256);
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}