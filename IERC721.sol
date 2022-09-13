// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.16;
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";

interface IERC721 is IERC721Metadata,IERC721Enumerable{
    /** emits when token is transfer     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * return the number of tokens in owners account
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**return the owner of token id*/
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from,address to, uint256 tokenId,bytes calldata data ) external;


    function safeTransferFrom(address from,address to,uint256 tokenId) external;

    function safeTransfer(address to, uint256 tokenId,bytes calldata data ) external;
   
    function transfer(address to,uint256 tokenId) external;

    function transferFrom(address from,address to,uint256 tokenId) external;

    //owner of the token can approve another account to transfer
    function approve(address to, uint256 tokenId) external;


    // Sets or unsets the approval of a given operator An operator is allowed to transfer all tokens of the sender on their behalf.
    function setApprovalForAll(address operator, bool _approved) external;

    //check which address is allowed for the token
    function getApproved(uint256 tokenId) external view returns (address operator);

    //check whether the owner has approved the operator to transfer tokens.
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeMint(address to,uint256 tokenId,bytes memory data) external returns(uint8);

    function burn(address to, uint256 tokenId) external ;
    function mint(address to) external returns(uint8);

    // function addMasterMinter(address masterMinter) external;
}