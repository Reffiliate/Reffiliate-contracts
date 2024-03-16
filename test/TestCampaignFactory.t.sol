//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../src/CampaignFactory.sol";
import "forge-std/Test.sol";

contract TestCampaignFactory is Test {  
    using SafeERC20 for IERC20;

    address private constant USER_ADDRESS = 0xB4873900Ae62Ac4b752366eB1c04191693b37B17;
    address private constant DAPP_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant TOKEN_ADDRESS = 0x6d8727B664D3f877de683F836E75EB2de47FD197;
    CampaignFactory factory;

    function setUp() public {
        factory = new CampaignFactory();
        deal(TOKEN_ADDRESS, USER_ADDRESS, 100);
    }

    function testCreateCampaign() public {
        vm.startBroadcast(USER_ADDRESS);

        address owner = USER_ADDRESS;
        address dApp = DAPP_ADDRESS;

        factory.createCampaign(owner, dApp);
        address campaignAddress = factory.getCampaign(owner, dApp);
        IERC20(TOKEN_ADDRESS).approve(campaignAddress, 100);
        Campaign campaign = Campaign(campaignAddress);

        address token = TOKEN_ADDRESS;
        uint256 fund = 100;
        uint256 transactionReward = 1;
        uint256 referralReward = 5;

        campaign.startCampaign(token, fund, transactionReward, referralReward);

        assertEq(campaign.owner(), owner);
        assertEq(campaign.dApp(), dApp);
        assertEq(campaign.token(), token);
        assertEq(campaign.fund(), fund);
        assertEq(campaign.transactionReward(), transactionReward);
        assertEq(campaign.referralReward(), referralReward);
        assertEq(campaign.isRunning(), true);
        assertEq(campaign.totalReward(), 0);
        vm.stopBroadcast();
    }
}