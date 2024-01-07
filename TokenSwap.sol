// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSwap {
    ERC20 public tokenA;
    ERC20 public tokenB;
    uint256 public exchangeRate; // Exchange rate: amount of Token B for 1 Token A

    event TokensSwapped(
        address indexed user,
        uint256 amountTokenA,
        uint256 amountTokenB
    );

    constructor(
        address _tokenAAddress,
        address _tokenBAddress,
        uint256 _exchangeRate
    ) {
        tokenA = ERC20(_tokenAAddress);
        tokenB = ERC20(_tokenBAddress);
        exchangeRate = _exchangeRate;
    }

    function swapAToB(uint256 amount) external {
        uint256 tokenBAmount = amount * exchangeRate;
        require(
            tokenB.balanceOf(address(this)) >= tokenBAmount,
            "Insufficient Token B balance in the contract"
        );

        tokenA.transferFrom(msg.sender, address(this), amount);
        tokenB.transfer(msg.sender, tokenBAmount);

        emit TokensSwapped(msg.sender, amount, tokenBAmount);
    }

    function swapBToA(uint256 amount) external {
        uint256 tokenAAmount = amount * exchangeRate;
        require(
            tokenA.balanceOf(address(this)) >= tokenAAmount,
            "Insufficient Token A balance in the contract"
        );

        tokenB.transferFrom(msg.sender, address(this), amount);
        tokenA.transfer(msg.sender, tokenAAmount);

        emit TokensSwapped(msg.sender, tokenAAmount, amount);
    }

    // Admin function to update the exchange rate
    function updateExchangeRate(uint256 newRate) external {
        require(msg.sender == owner(), "Only owner can update the exchange rate");
        exchangeRate = newRate;
    }

    // Utility function to retrieve contract owner
    function owner() internal view returns (address) {
        return address(tokenA); // Arbitrarily selecting token A's address as owner
    }
}
