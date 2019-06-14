# Modified from: https://github.com/ethereum/vyper/blob/master/examples/tokens/ERC721.vy

contract ERC721Receiver:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: bytes[1024]
        ) -> bytes32: constant

Transfer: event({_from: indexed(address), _to: indexed(address), _tokenId: indexed(uint256)})
Approval: event({_owner: indexed(address), _approved: indexed(address), _tokenId: indexed(uint256)})
ApprovalForAll: event({_owner: indexed(address), _operator: indexed(address), _approved: bool})

name: public(string[32])
symbol: public(string[32])
totalSupply: public(uint256)

# @dev Mapping from NFT ID to the address that owns it.
ownerOf: public(map(uint256, address))

# @dev Mapping from NFT ID to approved address.
getApproved: public(map(uint256, address))

# @dev Mapping from owner address to count of his tokens.
balanceOf: public(map(address, uint256))

# @dev Mapping from owner address to mapping of operator addresses.
isApprovedForAll: public(map(address, map(address, bool)))

# @dev Address of minter, who can mint a token
minter: public(address)

# @dev Mapping of interface id to bool about whether or not it's supported
supportsInterface: public(map(bytes32, bool))

ERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7
ERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd


@public
def __init__():
    self.supportsInterface[ERC165_INTERFACE_ID] = True
    self.supportsInterface[ERC721_INTERFACE_ID] = True
    self.name = 'Digital Unisocks 0'
    self.symbol = 'S0CKS'
    self.minter = msg.sender


# @public
# @constant
# def baseTokenURI() -> string[64]:
#     return 'https://opensea-creatures-api.herokuapp.com/api/creature/'
#
# @public
# @constant
# def tokenURI(_tokenId: uint256) -> string[64]:
#     _tokenIdBytes: bytes[4] = convert(_tokenId, bytes[4])
#     return concat('https://opensea-creatures-api.herokuapp.com/api/creature/', _tokenId)

@private
@constant
def _isApprovedOrOwner(_spender: address, _tokenId: uint256):
    owner: address = self.ownerOf[_tokenId]
    spenderIsOwner: bool = owner == _spender
    spenderIsApproved: bool = _spender == self.getApproved[_tokenId]
    spenderIsApprovedForAll: bool = (self.isApprovedForAll[owner])[_spender]
    assert (spenderIsOwner or spenderIsApproved) or spenderIsApprovedForAll


@private
def _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):
    assert _to != ZERO_ADDRESS and self.ownerOf[_tokenId] == _from
    # Check requirements
    self._isApprovedOrOwner(_sender, _tokenId)
    # Clear approval.
    if self.getApproved[_tokenId] != ZERO_ADDRESS:
        self.getApproved[_tokenId] = ZERO_ADDRESS
    # Transfer NFT. Throws if `_tokenId` is not a valid NFT
    self.ownerOf[_tokenId] = ZERO_ADDRESS
    self.balanceOf[_from] -= 1
    self.ownerOf[_tokenId] = _to
    self.balanceOf[_to] += 1
    log.Transfer(_from, _to, _tokenId)


@public
def transferFrom(_from: address, _to: address, _tokenId: uint256):
    self._transferFrom(_from, _to, _tokenId, msg.sender)


@public
def safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: bytes[1024]=""):
    self._transferFrom(_from, _to, _tokenId, msg.sender)
    if _to.is_contract: # check if `_to` is a contract address
        returnValue: bytes32 = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)
        # Throws if transfer destination is a contract which does not implement 'onERC721Received'
        assert returnValue == method_id("onERC721Received(address,address,uint256,bytes)", bytes32)


@public
def approve(_approved: address, _tokenId: uint256):
    owner: address = self.ownerOf[_tokenId]
    assert owner != ZERO_ADDRESS and _approved != owner
    # Check requirements
    senderIsOwner: bool = self.ownerOf[_tokenId] == msg.sender
    senderIsApprovedForAll: bool = (self.isApprovedForAll[owner])[msg.sender]
    assert (senderIsOwner or senderIsApprovedForAll)
    # Set the approval
    self.getApproved[_tokenId] = _approved
    log.Approval(owner, _approved, _tokenId)


@public
def setApprovalForAll(_operator: address, _approved: bool):
    assert _operator != msg.sender
    self.isApprovedForAll[msg.sender][_operator] = _approved
    log.ApprovalForAll(msg.sender, _operator, _approved)


@public
def mint(_to: address) -> bool:
    _tokenId: uint256 = self.totalSupply
    assert _tokenId < 500 and self.ownerOf[_tokenId] == ZERO_ADDRESS
    assert msg.sender == self.minter and _to != ZERO_ADDRESS
    self.ownerOf[_tokenId] = _to
    self.balanceOf[_to] += 1
    self.totalSupply += 1
    log.Transfer(ZERO_ADDRESS, _to, _tokenId)
    return True

@public
def changeMinter(_minter: address):
    assert msg.sender == self.minter
    self.minter = _minter
