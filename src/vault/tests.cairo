use simple_vault::vault::interface::{VaultABIDispatcher, VaultABIDispatcherTrait};
use starknet::{ContractAddress};
use snforge_std::{declare, DeclareResultTrait, ContractClassTrait, test_address};
use openzeppelin::presets::interfaces::{
    ERC20UpgradeableABIDispatcher, ERC20UpgradeableABIDispatcherTrait,
};
use openzeppelin::utils::serde::SerializedAppend;
use simple_vault::utils::utils;
use simple_vault::utils::constants;


fn setup_vault(erc20_contract_address: ContractAddress) -> (VaultABIDispatcher, ContractAddress) {
    // declare vault contract
    let contract_class = declare("SimpleVault").unwrap().contract_class();

    // deploy vault contract
    let mut calldata = array![];
    calldata.append_serde(erc20_contract_address);

    let (contract_address, _) = contract_class.deploy(@calldata).unwrap();

    (VaultABIDispatcher { contract_address }, contract_address)
}

fn setup() -> (
    VaultABIDispatcher, ContractAddress, ERC20UpgradeableABIDispatcher, ContractAddress,
) {
    // deploy an ERC20
    let (erc20_strk, erc20_address) = utils::setup_erc20(test_address());

    // deploy vault contract
    let (vault, contract_address) = setup_vault(erc20_strk.contract_address);

    (vault, contract_address, erc20_strk, erc20_address)
}

#[test]
fn test_request_inscription_stored_and_retrieved() {
    let (vault_dispatcher, contract_address, token_dispatcher, _scar) = setup();

    token_dispatcher.approve(contract_address, 100);

    let expected = 1_000_000_000_000_000_000; // initial balance
    let actual = vault_dispatcher.user_balance_of(test_address());
    assert_eq!(expected, actual);

    let expected_contract_balance = 1000; // initial balance contract
    let actual_contract_balance = token_dispatcher.balance_of(contract_address);
    assert_eq!(expected_contract_balance, actual_contract_balance);

    vault_dispatcher.deposit(100);

    let expected_user_balance = constants::SUPPLY - 10; // the user balance after the request call
    let actual_user_balance = token_dispatcher.balance_of(test_address());
    assert_eq!(expected_user_balance, actual_user_balance);
}
