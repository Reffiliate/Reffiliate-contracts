//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CampaignFactory.sol";
import "../src/Campaign.sol";
import "../src/SimpleStorage.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TestCampaign is Test { 
    address private constant OWNER_ADDRESS = 0xB4873900Ae62Ac4b752366eB1c04191693b37B17;
    address private USER_ADDRESS = 0x9f05e3f61a93af744112fBAa880b1aF8e1935fb8;
    address private constant DAPP_ADDRESS = 0xaD9DB1c0098A1FC95E686E93aC5D818838468263;
    address private constant TOKEN_ADDRESS = 0x6d8727B664D3f877de683F836E75EB2de47FD197;

    CampaignFactory factory;
    Campaign campaign;
    SimpleStorage dApp = SimpleStorage(DAPP_ADDRESS);

    function setUp() public {
        deal(TOKEN_ADDRESS, OWNER_ADDRESS, 100 * 1e18);

        factory = new CampaignFactory();
        vm.startBroadcast(OWNER_ADDRESS);

        factory.createCampaign(OWNER_ADDRESS, DAPP_ADDRESS);
        address campaignAddress = factory.getCampaign(OWNER_ADDRESS, DAPP_ADDRESS);
        IERC20(TOKEN_ADDRESS).approve(campaignAddress, 100 * 1e18);
        campaign = Campaign(campaignAddress);

        address token = TOKEN_ADDRESS;
        uint256 fund = 100 * 1e18;
        uint256 transactionReward = 1;
        uint256 referralReward = 5;

        campaign.startCampaign(token, fund, transactionReward, referralReward);

        assertEq(campaign.owner(), OWNER_ADDRESS);
        assertEq(campaign.dApp(), DAPP_ADDRESS);
        assertEq(campaign.token(), token);
        assertEq(campaign.fund(), fund);
        assertEq(campaign.transactionReward(), transactionReward);
        assertEq(campaign.referralReward(), referralReward);
        assertEq(campaign.isRunning(), true);
        assertEq(campaign.totalReward(), 0);
        vm.stopBroadcast();
    }

    function testIsRunning() public view {
        assertEq(campaign.isRunning(), true);
    }

    function testEndCampaign() public {
        vm.startBroadcast(OWNER_ADDRESS);
        campaign.endCampaign();
        assertEq(campaign.isRunning(), false);
        vm.stopBroadcast();
    }

    function testExcuteTransaction() public {
        vm.startBroadcast(USER_ADDRESS);
        uint256 value = 7;
        console.log(DAPP_ADDRESS);
        console.log(address(dApp));
        campaign.executeTransaction(USER_ADDRESS, abi.encodeWithSignature("store(uint256)", value));
        uint256 rewardAmount = campaign.getReward(USER_ADDRESS);
        console.log("reward amount: ", rewardAmount);
        console.log(dApp.retrieve());

        uint256 x = 3;
        campaign.executeTransaction(USER_ADDRESS, abi.encodeWithSignature("inc(uint256)", x));
        rewardAmount = campaign.getReward(USER_ADDRESS);
        console.log("reward amount: ", rewardAmount);

        assertGt(rewardAmount, 0);
        vm.stopBroadcast();
    }

    function testClaimReward() public {
        vm.startBroadcast(USER_ADDRESS);
        uint256 value = 7;
        campaign.executeTransaction(USER_ADDRESS, abi.encodeWithSignature("store(uint256)", value));
        uint256 rewardAmount = campaign.getReward(USER_ADDRESS);
        console.log("reward amount: ", rewardAmount);

        uint256 x = 3;
        campaign.executeTransaction(USER_ADDRESS, abi.encodeWithSignature("inc(uint256)", x));
        rewardAmount = campaign.getReward(USER_ADDRESS);
        console.log("reward amount: ", rewardAmount);

        assertGt(rewardAmount, 0);
        vm.stopBroadcast();

        vm.startBroadcast(OWNER_ADDRESS);
        campaign.endCampaign();
        vm.stopBroadcast();

        vm.startBroadcast(USER_ADDRESS);
        uint256 amount = campaign.claimReward(USER_ADDRESS);
        console.log("balance:", IERC20(TOKEN_ADDRESS).balanceOf(USER_ADDRESS), amount);
        vm.stopBroadcast();
    }
}