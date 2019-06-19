

from test.constants import (
    DECIMALS,
)

def test_init(w3, SOCKS):
    a0, a1 = w3.eth.accounts[:2]
    assert SOCKS.name() == 'Unisocks Edition 0'
    assert SOCKS.symbol() == 'SOCKS'
    assert SOCKS.decimals() == 18
    assert SOCKS.totalSupply() == 500*DECIMALS
    assert SOCKS.balanceOf(a0) == 500*DECIMALS
    assert SOCKS.balanceOf(a1) == 0

def test_transfer(w3, SOCKS):
    a0, a1 = w3.eth.accounts[:2]
    SOCKS.transfer(a1, 1*10**18, transact={})
    assert SOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
    assert SOCKS.balanceOf(a1) == 1*DECIMALS

def test_transferFrom(w3, SOCKS):
    a0, a1, a2 = w3.eth.accounts[:3]
    assert SOCKS.allowance(a0, a1) == 0
    SOCKS.approve(a1, 1*DECIMALS, transact={})
    assert SOCKS.allowance(a0, a1) == 1*DECIMALS
    SOCKS.transferFrom(a0, a2, 1*DECIMALS, transact={'from': a1})
    assert SOCKS.allowance(a0, a1) == 0
    assert SOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
    assert SOCKS.balanceOf(a1) == 0
    assert SOCKS.balanceOf(a2) == 1*DECIMALS

def test_burn(w3, SOCKS):
    a0, a1, a2 = w3.eth.accounts[:3]
    SOCKS.burn(1*10**18, transact={})
    assert SOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
    assert SOCKS.totalSupply() == 500*DECIMALS - 1*DECIMALS

def test_burnFrom(w3, SOCKS):
    a0, a1, a2 = w3.eth.accounts[:3]
    SOCKS.approve(a1, 1*DECIMALS, transact={})
    SOCKS.burnFrom(a0, 1*10**18, transact={'from': a1})
    assert SOCKS.balanceOf(a0) == 500*DECIMALS - 1*DECIMALS
    assert SOCKS.totalSupply() == 500*DECIMALS - 1*DECIMALS
