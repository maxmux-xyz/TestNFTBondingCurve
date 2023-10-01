// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "../lib/forge-std/src//Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {ERC20Mock} from "../script/ERC20Mock.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {CreatorTokenFactory} from "../src/CreatorTokenFactory.sol";
import {CreatorToken} from "../src/CreatorToken.sol";
import {IShowtimeVerifier} from "../src/lib/IShowtimeVerifier.sol";
import {ShowtimeVerifier} from "../src/ShowtimeVerifier.sol";
import {CreatorTokenDeploymentConfig} from "src/lib/ICreatorTokenFactory.sol";


contract TestCreatorTokenFactory is Test {
    CreatorTokenFactory factory;
    ERC20Mock usdcMock;
    ShowtimeVerifier verifier;
    CreatorToken token;
    address verifierDeployer = vm.addr(1);
    address ctDeployer = vm.addr(2);
    address usdcDeployer = vm.addr(3);
    address random = vm.addr(4);
    address random1 = vm.addr(5);
    address random2 = vm.addr(6);

    function setUp() public {
        // Deploy a verifier
        vm.startPrank(verifierDeployer);
        vm.deal(verifierDeployer, 100 ether);
        verifier = new ShowtimeVerifier(verifierDeployer);
        vm.stopPrank();

        // Deploy a CreatorToken Factory
        vm.startPrank(ctDeployer);
        vm.deal(ctDeployer, 100 ether);
        factory = new CreatorTokenFactory(verifier);
        vm.stopPrank();

        // Deploy a USDC Mock
        vm.startPrank(usdcDeployer);
        vm.deal(usdcDeployer, 100 ether);
        usdcMock = new ERC20Mock("USDC", "USDC", usdcDeployer, 20000e18);
        // usdcMock.transfer(random, 2000e18);
        // usdcMock.transfer(random1, 2000e18);
        usdcMock.transfer(random2, 2000e18);
        vm.stopPrank();

        // Deploy a CreatorToken
        vm.startPrank(ctDeployer);
        CreatorTokenDeploymentConfig memory _config = CreatorTokenDeploymentConfig(
            "Test Token",
            "TEST",
            "https://test.com",
            random,
            700,
            ctDeployer,
            300,
            random1,
            IERC20(usdcMock),
            1_000_000,
            0,
            44_000_000,
            50
        );
        token = factory.deployCreatorToken(_config);
        vm.stopPrank();
    }

    function testInit() external {
        assertEq(usdcMock.balanceOf(usdcDeployer), 18000e18);
        assertEq(usdcMock.balanceOf(random2), 2000e18);
        assertEq(verifierDeployer.balance, 100 ether);
        assertEq(ctDeployer.balance, 100 ether);
        assertEq(usdcDeployer.balance, 100 ether);
    }

    function testTokenUri() external {
        assertEq(token.tokenURI(0), "https://test.com");
    }

    function testDeployerAndRefererHaveToken() external {
        uint256 balance = token.balanceOf(random);
        assertEq(balance, 1);
        balance = token.balanceOf(random1);
        assertEq(balance, 1);
    }

    function testGetPriceAndBuy() external {
        (uint256 b, uint256 cf, uint256 af) = token.nextBuyPrice();
        uint256 t = b + cf + af;

        vm.startPrank(random2);
        // Allow the contract to spend random2 USDC
        usdcMock.approve(address(token), t);
        token.buy(t);
        vm.stopPrank();

        assertEq(token.balanceOf(random2), 1);
    }

    function testGetPriceAndBuy100() external {
        for (uint256 i=0; i<200; i++) {
            (uint256 base, uint256 creatorFee, uint256 adminFee) = token.nextBuyPrice();
            uint256 total_price = base + creatorFee + adminFee;

            console.log("%s,%s", token.totalSupply()+1, total_price);

            vm.startPrank(random2);
            // Allow the contract to spend random2 USDC
            usdcMock.approve(address(token), total_price);
            token.buy(total_price);
            vm.stopPrank();
        }

        console.log("Final balance for %s: %s", address(random2), token.balanceOf(random2));
        console.log("Total balance: %s", token.totalSupply());
        console.log("Fees accumulated Admin: %s", usdcMock.balanceOf(ctDeployer));
        console.log("Fees accumulated Creator: %s", usdcMock.balanceOf(random));

    }


}
