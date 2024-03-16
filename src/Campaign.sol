//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "./interfaces/ICampaign.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Campaign is ICampaign {
    using SafeERC20 for IERC20;

    address public immutable owner;
    address public immutable dApp;
    address public token;
    uint256 public fund;
    uint256 public transactionReward;
    uint256 public referralReward;
    uint256 public totalReward;
    bool public isRunning;
    uint24 public constant RATIO = 10;
    mapping(address => address) private referrals;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private addedReward;
    uint256 private nonce;

    constructor(address _owner, address _dApp) {
        owner = _owner;
        dApp = _dApp;
        nonce = 0;
    }

    function startCampaign(
        address _token,
        uint256 _fund,
        uint256 _transactionReward,
        uint256 _referralReward
    ) public override onlyOwner onlyNotRunning {
        token = _token;
        fund = _fund;
        transactionReward = _transactionReward;
        referralReward = _referralReward;
        isRunning = true;
        totalReward = 0;
        IERC20(token).safeTransferFrom(owner, address(this), fund);
        emit StartCampaign(token, fund, transactionReward, referralReward);
    }

    function addFund(uint256 amount) public override onlyOwner onlyRunning {
        fund += amount;
        IERC20(token).safeTransferFrom(owner, address(this), amount);
        emit AddFund(amount);
    }

    function endCampaign() public override onlyOwner onlyRunning {
        isRunning = false;
        IERC20(token).safeTransfer(owner, fund - totalReward);
        emit EndCampaign(totalReward);
    }

    function addReferral(
        address user,
        address referrer
    ) public override onlyOwner onlyRunning {
        require(referrals[user] == address(0), "User already has a referrer");
        referrals[user] = referrer;
        addReward(user, referralReward);
        emit AddReferral(user, referrer);
    }

    function addTransaction(
        address user,
        uint256 gasUsed
    ) public override onlyRunning {
        addReward(user, gasUsed * transactionReward);
        emit AddTransaction(user, gasUsed);
    }

    function addReward(address user, uint256 amount) internal {
        ++nonce;
        while (true) {
            if (
                amount == 0 || user == address(0) || addedReward[user] == nonce
            ) {
                break;
            }
            if (fund - totalReward < amount) {
                amount = fund - totalReward;
            }
            addedReward[user] = nonce;
            totalReward += amount;
            rewards[user] += amount;
            user = referrals[user];
            amount = (amount * RATIO) / 100;
        }
        if (totalReward == fund) {
            endCampaign();
        }
    }

    function executeTransaction(
        address user,
        bytes memory data
    ) public override returns (bytes memory) {
        uint256 startGas = gasleft();
        (bool success, bytes memory res) = dApp.call(data);
        require(success);
        uint256 gasUsed = startGas - gasleft();
        addTransaction(user, gasUsed);
        return res;
    }

    // function executeTransaction(address user, bytes memory data) public override returns (bytes memory) {
    //     uint256 startGas = gasleft();
    //     (bool success, bytes memory res) = dApp.delegatecall(abi.encodeWithSignature("store(uint256)", 10));
    //     require(success, "Transaction failed");
    //     uint256 gasUsed = startGas - gasleft();
    //     addTransaction(user, gasUsed);
    //     return res;
    // }

    function getReward(address user) public view returns (uint256 amount) {
        return rewards[user];
    }

    function claimReward(
        address user
    ) public override onlyNotRunning returns (uint256 amount) {
        amount = rewards[user];
        require(amount > 0, "No reward to claim");
        rewards[user] = 0;
        IERC20(token).safeTransfer(user, amount);
    }

    function getInfomation()
        public
        view
        returns (
            address,
            uint256 totalFund,
            uint256 remainFund,
            uint256,
            uint256,
            bool
        )
    {
        return (
            token,
            fund,
            fund - totalReward,
            referralReward,
            transactionReward,
            isRunning
        );
    }

    modifier onlyNotRunning() {
        require(!isRunning, "Campaign is running");
        _;
    }

    modifier onlyRunning() {
        require(isRunning, "Campaign is not running");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
