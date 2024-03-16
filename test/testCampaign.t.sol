//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CampaignFactory.sol";
import "../src/Campaign.sol";
import "forge-std/Test.sol";

contract TestCampaign is Test {
    address private constant USER_ADDRESS = 0xB4873900Ae62Ac4b752366eB1c04191693b37B17;
    address private constant DAPP_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant TOKEN_ADDRESS = 0x6d8727B664D3f877de683F836E75EB2de47FD197;

    CampaignFactory factory;
    Campaign campaign;

    // function setUp() public {
    //     factory = new CampaignFactory();
    //     vm.startBroadcast(USER_ADDRESS);
    //     factory.createCampaign(USER_ADDRESS, DAPP_ADDRESS, TOKEN_ADDRESS, 100, 1, 5);
    //     address campaignAddress = factory.getCampaign(USER_ADDRESS, DAPP_ADDRESS);
    //     campaign = Campaign(campaignAddress);
    //     vm.stopBroadcast();
    // }

    // function testIsRunning() public view {
    //     assertEq(campaign.isRunning(), true);
    // }
}