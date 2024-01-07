// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSale {
    address public owner;
    ERC20 public token;

    uint256 public presaleCap;
    uint256 public publicSaleCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;
    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    bool public presaleEnded;
    bool public publicSaleStarted;
    bool public publicSaleEnded;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(
        address _tokenAddress,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution
    ) {
        owner = msg.sender;
        token = ERC20(_tokenAddress);
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;

        // Start the presale when the contract is deployed
        presaleEnded = false;
        publicSaleStarted = false;
        publicSaleEnded = false;
    }

    function contributePresale(uint256 amount) external {
        require(!presaleEnded && !publicSaleStarted, "Presale or public sale is not available");
        require(amount >= presaleMinContribution && amount <= presaleMaxContribution, "Invalid contribution amount");
        require(address(this).balance + amount <= presaleCap, "Presale cap reached");

        presaleContributions[msg.sender] += amount;
        token.transfer(msg.sender, amount);
        emit TokensPurchased(msg.sender, amount);
    }

    function endPresale() external onlyOwner {
        require(!presaleEnded && !publicSaleStarted, "Presale has already ended or public sale started");
        presaleEnded = true;
        publicSaleStarted = true;
    }

    function contributePublicSale(uint256 amount) external {
        require(presaleEnded && publicSaleStarted && !publicSaleEnded, "Public sale is not available");
        require(amount >= publicSaleMinContribution && amount <= publicSaleMaxContribution, "Invalid contribution amount");
        require(address(this).balance + amount <= publicSaleCap, "Public sale cap reached");

        publicSaleContributions[msg.sender] += amount;
        token.transfer(msg.sender, amount);
        emit TokensPurchased(msg.sender, amount);
    }

    function endPublicSale() external onlyOwner {
        require(publicSaleStarted && !publicSaleEnded, "Public sale has already ended");
        publicSaleEnded = true;
    }

    function claimRefundPresale() external {
        require(presaleEnded && !publicSaleStarted, "Refunds not available");
        require(presaleContributions[msg.sender] > 0, "No contribution found");

        uint256 amount = presaleContributions[msg.sender];
        presaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function claimRefundPublicSale() external {
        require(publicSaleEnded, "Refunds not available");
        require(publicSaleContributions[msg.sender] > 0, "No contribution found");

        uint256 amount = publicSaleContributions[msg.sender];
        publicSaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function distributeTokens(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        token.transfer(recipient, amount);
    }
}
