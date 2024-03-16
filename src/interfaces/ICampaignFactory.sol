//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface  ICampaignFactory {
    event CreatedCampaign(address ownerAddress, address dAppAddress);

    function createCampaign(address ownerAddress, address dAppAddress) external;

    function getCampaign(address ownerAddress, address dAppAddress) external returns (address campainAddress);
}