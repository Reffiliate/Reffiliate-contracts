//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICampaign {
    event StartCampaign(address token, uint256 fund, uint256 transactionReward, uint256 referralReward);

    event EndCampaign(uint256 totalAmount);

    event AddReferral(address user, address referrer);

    event AddTransaction(address user, uint256 gasUsed);

    event AddFund(uint256 amount);

    function startCampaign(address token, uint256 fund, uint256 transactionReward, uint256 referralReward) external;

    function addFund(uint256 amount) external;

    function endCampaign() external;

    function addReferral(address user, address referrer) external;

    function addTransaction(address user, uint256 fee) external;

    function executeTransaction(address user, bytes memory data) external returns (bytes memory res);

    function claimReward(address user) external returns (uint256 amount);
}