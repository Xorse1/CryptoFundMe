// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    constructor() public{
        owner = msg.sender;
    }

   function fund() public payable {
       uint256 minimumUSD = 50 * 10 ** 18; // or 50 * 1000000000000000000
       require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH");
       addressToAmountFunded[msg.sender] += msg.value;
       funders.push(msg.sender);
       //what is ETH -> USD conversion rate
   }


   function getVersion() public view returns (uint256){
       AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       return priceFeed.version();
   }

   function getPrice() public view returns (uint256){
       AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       (,int256 answer,,,) = priceFeed.latestRoundData();
       return uint256(answer * 10000000000);
       //answer gives 8 decimal places but to meet the gwei - wei standard * answer by 10,000,000,000
   }

    //convert 100000000 wei to usd
   function getConversionRate(uint256 ethAmount) public view returns(uint256){
       uint256 ethPrice = getPrice();
       uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
       return ethAmountInUsd;

   }

   modifier onlyOwner {
       require(msg.sender == owner, "The owner alone has rights to withdraw");
       _;
   }

   function withdraw() payable onlyOwner  public {
       msg.sender.transfer(address(this).balance);

       for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
           address funder = funders[funderIndex];
           addressToAmountFunded[funder] = 0;
       }
       funders = new address[](0);
   }


}
