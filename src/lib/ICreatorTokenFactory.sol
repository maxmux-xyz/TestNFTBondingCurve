// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

struct CreatorTokenDeploymentConfig {
    string name;
    string symbol;
    string tokenURI;
    address creator;
    uint256 creatorFee;
    address admin;
    uint256 adminFee;
    address referrer;
    IERC20 payToken;
    uint128 basePrice;
    uint128 linearPriceSlope;
    uint128 inflectionPrice;
    uint32 inflectionPoint;
    // bytes32 attestationDigest;
}
