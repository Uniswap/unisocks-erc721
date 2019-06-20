from test.constants import (
    DECIMALS,
    ERC165_INTERFACE_ID,
    ERC721_INTERFACE_ID,
)

def test_init(w3, SOCKS, UNISOCKS):
    a0, a1 = w3.eth.accounts[:2]
    assert UNISOCKS.name() == 'Unisocks Digital 0'
    assert UNISOCKS.symbol() == 'S0CKS'
    assert UNISOCKS.totalSupply() == 0
    assert UNISOCKS.minter() == a0
    assert UNISOCKS.balanceOf(a1) == 0
    assert UNISOCKS.supportsInterface(ERC165_INTERFACE_ID) == True
    assert UNISOCKS.supportsInterface(ERC721_INTERFACE_ID) == True
    assert UNISOCKS.socks() == SOCKS.address

def test_transfer(w3, SOCKS, UNISOCKS, assert_fail):
    a0, a1, a2 = w3.eth.accounts[:3]
    assert_fail(lambda: UNISOCKS.mint(a1, transact={}))
    assert SOCKS.burn(2*DECIMALS, transact={})
    UNISOCKS.mint(a1, transact={})
    assert UNISOCKS.totalSupply() == 1
    UNISOCKS.mint(a2, transact={})
    assert UNISOCKS.totalSupply() == 2
    assert UNISOCKS.balanceOf(a1) == 1
    assert UNISOCKS.balanceOf(a2) == 1
    assert UNISOCKS.ownerOf(0) == a1
    assert UNISOCKS.ownerOf(1) == a2
    # Fails if not enough SOCKS are burned
    assert_fail(lambda: UNISOCKS.mint(a1, transact={}))
