// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenA is ERC20 {
    constructor() ERC20("MyTokenA", "MTA") {
        _mint(msg.sender, 1000);
    }
}

contract MyTokenB is ERC20 {
    constructor() ERC20("MyTokenB", "MTB") {
        _mint(msg.sender, 1000);
    }
}
