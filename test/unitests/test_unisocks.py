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
    assert UNISOCKS.supportsInterface(ERC165_INTERFACE_ID) == True
    assert UNISOCKS.supportsInterface(ERC721_INTERFACE_ID) == True
    assert UNISOCKS.socks() == SOCKS.address

def test_transfer(w3, SOCKS, UNISOCKS, assert_fail):
    a0, a1 = w3.eth.accounts[:2]
    # Fails if no SOCKS are burned
    assert_fail(lambda: UNISOCKS.mint(a1, transact={}))
    assert SOCKS.burn(2*DECIMALS, transact={})
    assert SOCKS.totalSupply() == 498*DECIMALS
    UNISOCKS.mint(a1, transact={})
