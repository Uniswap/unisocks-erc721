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
