import os
import pytest
from pytest import raises

from web3 import Web3
from web3.contract import ConciseContract
import eth_tester
from eth_tester import EthereumTester, PyEVMBackend
from eth_tester.exceptions import TransactionFailed
from vyper import compiler

'''
# run tests with:             python -m pytest -v
'''

setattr(eth_tester.backends.pyevm.main, 'GENESIS_GAS_LIMIT', 10**9)
setattr(eth_tester.backends.pyevm.main, 'GENESIS_DIFFICULTY', 1)

@pytest.fixture
def tester():
    return EthereumTester(backend=PyEVMBackend())

@pytest.fixture
def w3(tester):
    w3 = Web3(Web3.EthereumTesterProvider(tester))
    w3.eth.setGasPriceStrategy(lambda web3, params: 0)
    w3.eth.defaultAccount = w3.eth.accounts[0]
    return w3

# @pytest.fixture
def create_contract(w3, path, *args, **kwargs):
    wd = os.path.dirname(os.path.realpath(__file__))
    with open(os.path.join(wd, os.pardir, path)) as f:
        source = f.read()
    out = compiler.compile_code(source, ['abi', 'bytecode'], interface_codes=None)
    return w3.eth.contract(abi=out['abi'], bytecode=out['bytecode'])

@pytest.fixture
def SOCKS(w3):
    deploy = create_contract(w3, 'contracts/test_contracts/socks.vy')
    tx_hash = deploy.constructor().transact()
    tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
    return ConciseContract(w3.eth.contract(
        address=tx_receipt.contractAddress,
        abi=deploy.abi
    ))

@pytest.fixture
def UNISOCKS(w3, SOCKS):
    deploy = create_contract(w3, 'contracts/unisocks.vy')
    tx_hash = deploy.constructor(SOCKS.address).transact()
    tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
    return ConciseContract(w3.eth.contract(
        address=tx_receipt.contractAddress,
        abi=deploy.abi
    ))

@pytest.fixture
def assert_fail():
    def assert_fail(func):
        with raises(Exception):
            func()
    return assert_fail
