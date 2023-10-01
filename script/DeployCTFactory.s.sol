// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";
import {CreatorTokenFactory} from "src/CreatorTokenFactory.sol";
import {console} from "lib/forge-std/src/console.sol";
import {IShowtimeVerifier} from "src/lib/IShowtimeVerifier.sol";

contract DeployCTFactory is Script {
    CreatorTokenFactory factory;
    IShowtimeVerifier VERIFIER = IShowtimeVerifier(0x481273EB2B6A21e918f6952A6c53C08691FE768F);
    uint256 _deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

    function run() external {
        vm.startBroadcast(_deployerPrivateKey);
        factory = new CreatorTokenFactory(VERIFIER);
        vm.stopBroadcast();

        console.logAddress(address(factory));
    }
}