// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)


//ERC721 token to handle ticketing system
//admin can cencel tickets
//tickets can be redeemed in to several categories
//user can void the ticket.
//based on ticket status multiple nft images will display to the user.

pragma solidity 0.8.16;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Proxiable.sol";
import "./Owned.sol";

contract ERC721 is IERC721 ,AccessControl, Owned, Proxiable{

    enum TransactionType {Burn,Transfer,Mint} TransactionType transactionType ;
    enum TicketStatus {Available,Cancel,Redeemed,Void} TicketStatus ticketStatus;

    mapping(address=>uint256) private _balances;

    mapping (uint256=>address) private  _owners;

    mapping (address=>mapping(address=>bool)) _operatorApprovals;

    mapping(uint256 => address) private _tokenApprovals;

    mapping (uint=>TicketStatus) private ticketState;

    mapping (uint=>uint) private redeemState;


    string private _name;
    string private  _symbol;
    string private baseUri;
    string private contractUrl;

    uint256 _totalSupply;
    uint8 latestId=1;
    uint16 ticketCount;

    bool initializationFlag;
    bool setOwnerFlag=true;


    bytes32 public constant MINTER = keccak256("MINTER");
    bytes32 public constant MASTER_MINTER = keccak256("MINTER_ADMIN");

    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant CONTRACT_ADMIN = keccak256("CONTRACT_ADMIN");

    function constructor1(address contractOwner) public {
             initializationFlag=true;
             setOwner(contractOwner);
    }

    function initializer (
        string memory contract_name,string memory contract_symbol,
        uint16 _ticketCount, uint256 initialMint,address admin,string memory _baseUri)  onlyOwner public{
        require(initializationFlag,"Can be initialize donly onece");
        _setupRole(ADMIN,admin);
        _setRoleAdmin(CONTRACT_ADMIN, ADMIN);
        _grantRole(CONTRACT_ADMIN, admin);

        _name=contract_name;
        _symbol=contract_symbol;
        ticketCount=_ticketCount;

        baseUri=_baseUri;

        contractUrl="https://young-sierra-91714.herokuapp.com/contract.json";

        //initial mint of tickets
        for(uint x=1;x<initialMint;x++){
            _mint(msg.sender);
        }
        initializationFlag=false;
      }
 
    function baseTokenURI() public view returns (string memory) {
    return baseUri;
    }

    function setBaseTokenURI(string memory uri) public {
        baseUri=uri;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

     //metadata functions
    function name() external view returns (string memory){
        return _name;
    }
    function symbol() external view returns (string memory){
        return _symbol;
    }
    function tokenURI(uint256 tokenId) external view returns (string memory){
        return _getTicketURI(tokenId);
    }

    function contractURI() public view returns (string memory) {
        return contractUrl;
     }

    function setContractUrl(string memory url) public onlyRole(CONTRACT_ADMIN) {
        contractUrl=url;
    }

    function getTicketStatus(uint index) public view returns(TicketStatus){
       return ticketState[index];
    }
    
    //only the admin can cancel the ticket
    function cancelTicket(uint16 ticketIndex) public onlyRole(CONTRACT_ADMIN) {
        ticketState[ticketIndex]=TicketStatus.Cancel;
    }


    //only the ticket owner can void the ticket - only the admin
    function voidTicket(uint  ticketIndex) public{
        //need to check for cancel tickets
        require(ticketState[ticketIndex]!=TicketStatus.Cancel ,"Ticket cannot be redeemed");
        require(_owners[ticketIndex]==msg.sender,"Only the owner can void the ticket");
        ticketState[ticketIndex]=TicketStatus.Void;
    }

    //only the admin or an approved party can redeemed the ticket - only the owner
    function redeemTicket(uint256 ticketIndex) public onlyRole(CONTRACT_ADMIN){
        //check for already redemed tickets
        require(!(ticketState[ticketIndex]==TicketStatus.Cancel || ticketState[ticketIndex]==TicketStatus.Void) ,"Ticket cannot be redeemed");
        ticketState[ticketIndex]=TicketStatus.Redeemed;
        redeemState[ticketIndex]=ticketIndex%10;         
    }



    // function addAdmin(address contractAdmin) external{
    //     _grantRole(CONTRACT_ADMIN, contractAdmin);
    // }

    function addMasterMinter(address masterMinter) external onlyRole(CONTRACT_ADMIN){ // 
        _setupRole(MASTER_MINTER,masterMinter);
        _setRoleAdmin(MINTER, MASTER_MINTER);
    }

    function addMinter(address minter) external{
        require(minter!=address(0),"Zero address cannot be a minter");
         grantRole(MINTER,minter);
        
    }

    function balanceOf(address _owner) external view returns (uint256 balance){
        require(owner!=address(0),"owner cannot be zero address");
        return  _balances[_owner];
    }
    
    function ownerOf(uint256 tokenId) external view returns (address){
        return _owners[tokenId];
  
    }



    function approve(address to, uint256 tokenId) public virtual override {
        address _owner = _owners[tokenId];
            require(to != _owner, "ERC721: approval to current owner");
        require(
            msg.sender == _owner,
            "ERC721: approve caller is not token owner nor approved for all"
        );
        _approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }


    function transferFrom(address from,address to,uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(from,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
         _transfer(from, to, tokenId,TransactionType.Transfer);
    }

    function transfer(address to,uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
        _transfer(msg.sender, to, tokenId,TransactionType.Transfer);
    }

    function safeTransfer(address to, uint256 tokenId,bytes calldata data ) external{
        require(_isApprovedOrOwner(msg.sender,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
        _safeTransfer(msg.sender, to, tokenId, data);
    }

    function safeTransfer(address to, uint256 tokenId ) external{
        require(_isApprovedOrOwner(msg.sender,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
         _safeTransfer(msg.sender, to, tokenId,"");
    }

    function safeTransferFrom(address from,address to, uint256 tokenId,bytes calldata data ) external{
        require(_isApprovedOrOwner(from,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(address from,address to, uint256 tokenId) external{
        require(_isApprovedOrOwner(from,tokenId),"Sender is not approved to transfer the token");
        require(to != address(0), "ERC721: transfer to the zero address"); 
        _safeTransfer(from, to, tokenId, "");
    }


    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_owners[tokenId]!=address(0),"token does not exists");
        return _tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address _owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[_owner][operator];
    }

    //minting functions 
    function safeMint(address to,uint256 tokenId,bytes memory data)   external returns(uint8)  { //
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
        return mint(to);
    }

    function mint(address to) public override  onlyRole(MINTER) returns(uint8)   { //
        require(to != address(0), "ERC721: mint to the zero address");
        require(_totalSupply<ticketCount,"Maximum ticket count is already issued");
        return _mint(to);
        
        
    }

    function _mint(address to) private returns(uint8){
        _transfer(msg.sender, to, latestId,TransactionType.Mint);
        _totalSupply+=1;
        latestId+=1;
        return latestId;

    }

    function burn(address to, uint256 tokenId) public override{
        require(msg.sender==_owners[tokenId],"Unauthorized token burn operation");
        require(_exists(tokenId), "ERC721: token does not exist");
        _transfer(msg.sender, to, tokenId,TransactionType.Burn);
        _totalSupply-=1;
    }

    //only the owner should be able to
    function updateCode(address newCode) public {
        updateCodeAddress(newCode);
    }

    //internal functions

    function _getTicketURI(uint ticketIndex ) internal view returns(string memory){
        TicketStatus status = ticketState[ticketIndex];
        if(status==TicketStatus.Cancel){
            return string.concat(baseUri, "cancel.json");
        }
        else if(status==TicketStatus.Redeemed){
            return string.concat(baseUri,"redeem",Strings.toString(redeemState[ticketIndex]),".json");
        }
        else if(status==TicketStatus.Void){
            return string.concat(baseUri, "void.json");
        }
        else{
            return string.concat(baseUri, "ticket.json");
        }
    }

    function _exists(uint256 tokenId) internal view returns(bool){
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address from, uint256 tokenId) internal view  returns(bool){
        address _owner = _owners[tokenId];
        return (from == _owner || isApprovedForAll(owner, from) || getApproved(tokenId) == from);
    }

    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory data) internal  {
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
        _transfer(from, to, tokenId,TransactionType.Transfer);
    }


    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(_owners[tokenId], to, tokenId);
    }

    function _transfer(address from,address to,uint256 tokenId,TransactionType _transactionType) internal virtual {
        
        require(!checkTransferApproval(tokenId),"Ticket status is not allowed to transfer");

        if(_transactionType!=TransactionType.Mint){
            delete _tokenApprovals[tokenId];
            _balances[from] -= 1;
        }
        if(_transactionType!=TransactionType.Burn){
            _balances[to] += 1;
            _owners[tokenId] = to;
        }
 
        emit Transfer(from, to, tokenId);
    }

    //cannot transfer redeemed, canceled,voided tickets
    function checkTransferApproval(uint ticketIndex) internal view  returns(bool){
        return(ticketState[ticketIndex]==TicketStatus.Cancel||ticketState[ticketIndex]==TicketStatus.Redeemed||ticketState[ticketIndex]==TicketStatus.Void );
    }

    function _setApprovalForAll(address _owner,address operator,bool approved) internal virtual {
        require(_owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }




    function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory data) internal returns (bool) {
        if (_isContract(to)) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            }
            catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } 
                else {
                    /// @solidity memory-safe-assembly
                    assembly {revert(add(32, reason), mload(reason))}
                }
            }
        } else {
            return true;
        }
    }

    function _isContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
         }
        return (size > 0);
    }
    
}