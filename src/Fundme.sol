// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private  /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD =  50000000000000000000 ;
    AggregatorV3Interface private s_pricefeedaddress;
    
    constructor(address pricefeed) {
        i_owner = msg.sender;
        s_pricefeedaddress =AggregatorV3Interface(
            pricefeed
        );
    }

    function fund() public payable {
        require(PriceConverter.getConversionRate(msg.value,s_pricefeedaddress) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function cheaperwithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (uint256 funderIndex=0; funderIndex <funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
//getters
    function getfunder(uint256 index) public view returns(address){
        return s_funders[index];
    }
    function getowner() public view returns(address){
        return i_owner;
    }
    function getamountfunded(address account) public view returns(uint256){
        return s_addressToAmountFunded[account];
    }
    function getpricefeedaddress() public view returns(AggregatorV3Interface){
        return s_pricefeedaddress;
    }
}

