use starknet::{ContractAddress, contract_address_const};

pub const SUPPLY: u256 = 1_000_000_000_000_000_000;

pub fn NAME() -> ByteArray {
    "Starknet"
}

pub fn SYMBOL() -> ByteArray {
    "STRK"
}

pub fn OWNER() -> ContractAddress {
    contract_address_const::<'owner'>()
}