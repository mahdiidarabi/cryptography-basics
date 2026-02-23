// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./verifier.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ZcashPour {

  address payable public owner;

  mapping (uint => bool) public isCommitted;

  event Withdrawal(uint amount, uint when);

  constructor() payable {
    owner = payable(msg.sender);
  }

  function withdraw() public {}
}
