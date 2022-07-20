//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// Deposit Tokens
// Withdraw Tokens
// Check Balances
// Make Orders
// Cancel Orders
// Fill Orders
// Charge Fees
// Track Fee Account

contract Exchange {
  address public feeAccount;
  uint256 public feePercent;

  constructor(address _feeAccount, uint256 _feePercent) {
    feeAccount = _feeAccount;
    feePercent = _feePercent;

  }
}
