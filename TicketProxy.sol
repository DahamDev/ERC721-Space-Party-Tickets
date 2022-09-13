// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity 0.8.16;

contract TicketProxy {
// Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    constructor (address newDelegateAddress,address owner) {
         assembly { 
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newDelegateAddress)
            }
        (bool success, bytes memory x ) = newDelegateAddress.delegatecall(abi.encodeWithSignature("constructor1(address)",owner)); 
        require(success, "Construction failed");

        }

    function getDelegate() external view returns(address) {
        assembly{
            let _target := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            mstore(0x0, _target) 
            return(0x0,0x20)
        }
    }


    fallback () external payable {
        assembly {
            let _target := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _target, ptr, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
        }
    }

}