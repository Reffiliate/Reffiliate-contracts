//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICampaignFactory.sol";
import "./Campaign.sol";

contract CampaignFactory is ICampaignFactory {
    mapping(address => mapping(address => address)) private campaigns;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function createCampaign(address ownerAddress, address dAppAddress) public override {
        require(campaigns[ownerAddress][dAppAddress] == address(0), "CampaignFactory: Campaign already exists");
        Campaign campaign = new Campaign(ownerAddress, dAppAddress);
        campaigns[ownerAddress][dAppAddress] = address(campaign);
        emit CreatedCampaign(ownerAddress, dAppAddress);
    }

    function getCampaign(address ownerAddress, address dAppAddress) public view override returns (address) {
        return campaigns[ownerAddress][dAppAddress];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "CampaignFactory: Only owner can call this function");
        _;
    }
}