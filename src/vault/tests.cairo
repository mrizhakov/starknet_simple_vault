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

    // Initial balance should be 0
    let initial_balance = vault_dispatcher.user_balance_of(test_address());
    assert_eq!(initial_balance, 0);

    // Approve and deposit tokens
    token_dispatcher.approve(contract_address, 10000000000000000);
    vault_dispatcher.deposit(10000000000000000);

    // After deposit, user should have shares equal to amount (since it's first deposit)
    let balance_after_deposit = vault_dispatcher.user_balance_of(test_address());
    assert_eq!(balance_after_deposit, 10000000000000000);

    // Check contract token balance
    let contract_token_balance = token_dispatcher.balance_of(contract_address);
    assert_eq!(contract_token_balance, 10000000000000000);
}
