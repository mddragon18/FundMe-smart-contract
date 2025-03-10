// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "priceconverter.sol";
using PriceConverter for uint256;
// 0xa2c932C7d985E90907C643941d1d7E2f5a934722
contract FundMe {

    uint256 public minUSD=5e18;
    address[] public funders;
    mapping (address funder => uint256 amountFunded) addressToAmountFunded;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Must be owner");
        _;
    }

    function fund() public payable  {
        require(msg.value.getConversionRate() >= minUSD,"Didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]+= msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex=0;funderIndex < funders.length; funderIndex++) {
            address funder=funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"Call failed");

    }

    
}
