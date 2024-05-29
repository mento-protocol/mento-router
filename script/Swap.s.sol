// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IBroker} from "src/IBroker.sol";
import {MentoRouter, IMentoRouter} from "src/MentoRouter.sol";
import "test/TestPaths.sol";

contract Swap is Script {
    IBroker constant broker =
        IBroker(0x777A8255cA72412f0d706dc03C9D1987306B4CaD);
    MentoRouter constant mentoRouter =
        MentoRouter(0xBE729350F8CdFC19DB6866e8579841188eE57f67);

    function setUp() public {
        vm.label(bpm, "BiPoolManager");
        vm.label(celo, "CELO");
        vm.label(cUSD, "cUSD");
        vm.label(cKES, "cKES");
        vm.label(USDC, "USDC");
        vm.label(user, "User");
        vm.label(address(broker), "Broker");
        vm.label(address(mentoRouter), "MentoRouter");
    }

    function run() public {
        IMentoRouter.Step[] memory path0 = TestPaths.USDC_cUSD_cKES();
        IMentoRouter.Step[] memory path1 = TestPaths
            .USDC_cUSD_axlUSDC_cEUR_EURC();

        uint256 usdc_amountIn = 1e3;

        vm.startBroadcast(
            0x604f9bff763823555b515b8717316bc84b0c250f43e7604fb9a967214b9982b3
        );
        IERC20(USDC).approve(address(mentoRouter), 2 * usdc_amountIn);
        mentoRouter.swapExactTokensForTokens(usdc_amountIn, 0, path0);
        mentoRouter.swapTokensForExactTokens(900, usdc_amountIn, path1);
        vm.stopBroadcast();

        console.log(IERC20(cKES).balanceOf(user));
        console.log(IERC20(EURC).balanceOf(user));
    }
}
