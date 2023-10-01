// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";
import {CreatorToken} from "src/CreatorToken.sol";
import {CTBondingCurve} from "src/CTBondingCurve.sol";
import {IBondingCurve} from "src/interfaces/IBondingCurve.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20Mock} from "script/ERC20Mock.sol";

contract DeployCTFactory is Script {
    CreatorToken creatorToken;
    uint256 _deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address adminAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address referrerAddress = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address deployerAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() external {
        IERC20 iPayToken;
        ERC20Mock usdcMock = new ERC20Mock("USDC", "USDC", 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 1000e18);
        iPayToken = IERC20(address(usdcMock));
        address bondingCurveAddress = deployBondingCurve();
        deployCreatorToken(bondingCurveAddress, address(usdcMock));
    }

    function deployBondingCurve() public returns (address) {
        uint128 _basePrice = 1000000;
        uint128 _linearPriceSlope = 1;
        uint128 _inflectionPrice = 400000000;
        uint32 _inflectionPoint = 500;

        vm.startBroadcast(_deployerPrivateKey);
        CTBondingCurve bondingCurve = new CTBondingCurve(
            _basePrice, _linearPriceSlope, _inflectionPrice, _inflectionPoint
        );
        vm.stopBroadcast();

        return address(bondingCurve);
    }

    function deployCreatorToken(address _bondingCurveAddress, address _payTokenAddress) public {
        string memory _name = "test";
        string memory _symbol = "TST";
        string memory _tokenURI = "test.com";
        address _creator = deployerAddress;
        uint256 _creatorFee = 700;
        address _admin = adminAddress;
        uint256 _adminFee = 300;
        address _referrer = referrerAddress;
        IERC20 _payToken;
        IBondingCurve _bondingCurve;

        _payToken = IERC20(_payTokenAddress);
        _bondingCurve = IBondingCurve(_bondingCurveAddress);

        vm.startBroadcast(_deployerPrivateKey);
        creatorToken = new CreatorToken(
            _name, _symbol, _tokenURI, _creator, _creatorFee,
            _admin, _adminFee, _referrer, _payToken, _bondingCurve
        );
        vm.stopBroadcast();
    }
}