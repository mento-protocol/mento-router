// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MentoRouter} from "src/MentoRouter.sol";

contract Deploy is Script {
    MentoRouter mentoRouter;

    function run() public {
        vm.startBroadcast(
            0x604f9bff763823555b515b8717316bc84b0c250f43e7604fb9a967214b9982b3
        );
        mentoRouter = new MentoRouter(
            0x777A8255cA72412f0d706dc03C9D1987306B4CaD
        );
        vm.stopBroadcast();
        console.log("MentoRouter deployed at:", address(mentoRouter));
    }
}
