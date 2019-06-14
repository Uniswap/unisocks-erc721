from test.constants import (
    DECIMALS,
)

def test_init(w3, UNISOCKS):
    a0, a1 = w3.eth.accounts[:2]
    # assert UNISOCKS.name() == 'Unisocks Edition 0'
    # assert UNISOCKS.symbol() == 'SOCKS'
    # assert UNISOCKS.decimals() == 18
    # assert UNISOCKS.totalSupply() == 500*DECIMALS
    # assert UNISOCKS.balanceOf(a0) == 500*DECIMALS
    # assert UNISOCKS.balanceOf(a1) == 0
    assert UNISOCKS.minter() == a0

# def test_transfer(w3, UNISOCKS):
#     a0, a1 = w3.eth.accounts[:2]
#     UNISOCKS.transfer(a1, 1*10**18, transact={})
#     assert UNISOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
#     assert UNISOCKS.balanceOf(a1) == 1*DECIMALS
#
# def test_transferFrom(w3, UNISOCKS):
#     a0, a1, a2 = w3.eth.accounts[:3]
#     assert UNISOCKS.allowance(a0, a1) == 0
#     UNISOCKS.approve(a1, 1*DECIMALS, transact={})
#     assert UNISOCKS.allowance(a0, a1) == 1*DECIMALS
#     UNISOCKS.transferFrom(a0, a2, 1*DECIMALS, transact={'from': a1})
#     assert UNISOCKS.allowance(a0, a1) == 0
#     assert UNISOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
#     assert UNISOCKS.balanceOf(a1) == 0
#     assert UNISOCKS.balanceOf(a2) == 1*DECIMALS
#
# def test_burn(w3, UNISOCKS):
#     a0, a1, a2 = w3.eth.accounts[:3]
#     UNISOCKS.burn(1*10**18, transact={})
#     assert UNISOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
#     assert UNISOCKS.totalSupply() == 500*DECIMALS - 1*DECIMALS
#
# def test_burnFrom(w3, UNISOCKS):
#     a0, a1, a2 = w3.eth.accounts[:3]
#     UNISOCKS.approve(a1, 1*DECIMALS, transact={})
#     UNISOCKS.burnFrom(a0, 1*10**18, transact={'from': a1})
#     assert UNISOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
#     assert UNISOCKS.totalSupply() == 500*DECIMALS - 1*DECIMALS
