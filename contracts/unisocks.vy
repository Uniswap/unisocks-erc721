# Modified from: https://github.com/ethereum/vyper/blob/master/examples/tokens/ERC721.vy

contract ERC721Receiver:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: bytes[1024]
        ) -> bytes32: constant

contract URI:
    def tokenURI(
        _tokenId: uint256) -> string[64]: constant

contract Socks:
    def totalSupply() -> uint256: constant

Transfer: event({_from: indexed(address), _to: indexed(address), _tokenId: indexed(uint256)})
Approval: event({_owner: indexed(address), _approved: indexed(address), _tokenId: indexed(uint256)})
ApprovalForAll: event({_owner: indexed(address), _operator: indexed(address), _approved: bool})

name: public(string[32])
symbol: public(string[32])
totalSupply: public(uint256)
minter: public(address)
socks: public(Socks)
newURI: public(address)

ownedTokensIndex: map(uint256, uint256)                             # map(tokenId, index)
tokenOfOwnerByIndex: public(map(address, map(uint256, uint256)))    # map(owner, map(index, tokenId))
ownerOf: public(map(uint256, address))                              # map(tokenId, owner)
getApproved: public(map(uint256, address))                          # map(tokenId, approvedSpender)
balanceOf: public(map(address, uint256))                            # map(owner, balance)
isApprovedForAll: public(map(address, map(address, bool)))          # map(owner, map(operator, bool))
supportsInterface: public(map(bytes32, bool))                       # map(interfaceId, bool)

ERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7
ERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd


@public
def __init__(_socks: address):
    self.name = 'Unisocks Digital 0'
    self.symbol = 'S0CKS'
    self.minter = msg.sender
    self.socks = Socks(_socks)
    self.supportsInterface[ERC165_INTERFACE_ID] = True
    self.supportsInterface[ERC721_INTERFACE_ID] = True


@public
@constant
def tokenURI(_tokenId: uint256) -> string[64]:
    _URI: string[64] = 'https://opensea-creatures-api.herokuapp.com/api/creature/'
    if(self.newURI != ZERO_ADDRESS):
        _URI = URI(self.newURI).tokenURI(_tokenId)
    return _URI


# Token index is same as ID and can't change
@public
@constant
def tokenByIndex(_index: uint256) -> uint256:
    return _index


@private
def _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):
    _owner: address = self.ownerOf[_tokenId]
    # Check requirements
    assert _to != ZERO_ADDRESS and _owner == _from
    _senderIsOwner: bool = _owner == _sender
    _senderIsApproved: bool = _sender == self.getApproved[_tokenId]
    _senderIsApprovedForAll: bool = self.isApprovedForAll[_owner][_sender]
    assert (_senderIsOwner or _senderIsApproved) or _senderIsApprovedForAll
    # Clear approval.
    if self.getApproved[_tokenId] != ZERO_ADDRESS:
        self.getApproved[_tokenId] = ZERO_ADDRESS
    # Update ownedTokensIndex and tokenOfOwnerByIndex
    _index: uint256 = self.ownedTokensIndex[_tokenId]           # get index of _tokenId
    _newTokenAtIndex: uint256 = 0
    _highestIndexFrom: uint256 = self.balanceOf[_from] - 1      # get highest index of _from
    _newHighestIndexTo: uint256 = self.balanceOf[_to]           # get next index of _to
    # replace _index with _highestIndexFrom
    if (_index < _highestIndexFrom):
        _newTokenAtIndex = self.tokenOfOwnerByIndex[_from][_highestIndexFrom]
        self.tokenOfOwnerByIndex[_from][_highestIndexFrom] = 0
        self.ownedTokensIndex[_newTokenAtIndex] = _index
    self.ownedTokensIndex[_tokenId] = _newHighestIndexTo
    self.tokenOfOwnerByIndex[_from][_index] = _newTokenAtIndex     # clear index or update value
    self.tokenOfOwnerByIndex[_to][_newHighestIndexTo] = _tokenId
    # Update ownerOf and balanceOf
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
        assert returnValue == method_id('onERC721Received(address,address,uint256,bytes)', bytes32)


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
    assert msg.sender == self.minter and _to != ZERO_ADDRESS
    _tokenId: uint256 = self.totalSupply
    # can only mint if a sock has been burned
    _socksSupply: uint256 = self.socks.totalSupply()
    _socksBurned: uint256 = 500 - _socksSupply
    assert _tokenId < _socksBurned
    self.ownedTokensIndex[_tokenId] = _tokenId
    self.ownerOf[_tokenId] = _to
    self.balanceOf[_to] += 1
    self.totalSupply += 1
    log.Transfer(ZERO_ADDRESS, _to, _tokenId)
    return True


@public
def changeMinter(_minter: address):
    assert msg.sender == self.minter
    self.minter = _minter

@public
def changeURI(_newURI: address):
    assert msg.sender == self.minter
    self.newURI = _newURI
