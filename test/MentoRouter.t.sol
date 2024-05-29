// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {MentoRouter, IMentoRouter} from "src/MentoRouter.sol";
import {IBroker} from "src/IBroker.sol";
import "./TestPaths.sol";

contract MentoRouterTest is Test {
    MentoRouter mentoRouter;

    IBroker constant broker =
        IBroker(0x777A8255cA72412f0d706dc03C9D1987306B4CaD);

    address constant mentoReserveMultisig =
        0x87647780180B8f55980C7D3fFeFe08a9B29e9aE1;

    function setUp() public {
        vm.label(bpm, "BiPoolManager");
        vm.label(celo, "CELO");
        vm.label(cUSD, "cUSD");
        vm.label(cKES, "cKES");
        vm.label(USDC, "USDC");
        vm.label(EURC, "EURC");
        vm.label(axlUSDC, "axlUSDC");
        vm.label(cEUR, "cEUR");

        vm.label(user, "User");
        vm.label(address(broker), "Broker");

        uint256 mainnet = vm.createFork(vm.envString("CELO_RPC_URL"));
        vm.selectFork(mainnet);
        mentoRouter = new MentoRouter(address(broker), mentoReserveMultisig);
    }

    function test_swapExactTokensForTokens_withTwoTokens() public {
        IMentoRouter.Step[] memory path = TestPaths.USDC_cUSD_cKES();

        uint256 usdc_amountIn = 1e3;

        vm.prank(user);
        IERC20(USDC).approve(address(mentoRouter), usdc_amountIn);

        uint256 cKES_balanceBefore = IERC20(cKES).balanceOf(user);

        vm.prank(user);
        mentoRouter.swapExactTokensForTokens(usdc_amountIn, 0, path);

        uint256 cKES_balanceAfter = IERC20(cKES).balanceOf(user);
        require(
            cKES_balanceAfter > cKES_balanceBefore,
            "cKES balance did not increase"
        );
    }

    function test_swapExactTokensForTokens_withFourTokens() public {
        IMentoRouter.Step[] memory path = TestPaths
            .USDC_cUSD_axlUSDC_cEUR_EURC();

        uint256 usdc_amountIn = 1e3;

        vm.prank(user);
        IERC20(USDC).approve(address(mentoRouter), usdc_amountIn);

        uint256 EURC_balanceBefore = IERC20(EURC).balanceOf(user);

        vm.prank(user);
        mentoRouter.swapExactTokensForTokens(usdc_amountIn, 0, path);

        uint256 EURC_balanceAfter = IERC20(EURC).balanceOf(user);
        require(
            EURC_balanceAfter > EURC_balanceBefore,
            "EURC balance did not increase"
        );
    }

    function test_swapTokensForExactTokens_withTwoTokens() public {
        IMentoRouter.Step[] memory path = TestPaths.USDC_cUSD_cKES();

        uint256 usdc_maxAmountIn = 1e3;
        uint256 cKES_amountOut = 1e15;

        vm.prank(user);
        IERC20(USDC).approve(address(mentoRouter), usdc_maxAmountIn);

        uint256 cKES_balanceBefore = IERC20(cKES).balanceOf(user);

        vm.prank(user);
        mentoRouter.swapTokensForExactTokens(
            cKES_amountOut,
            usdc_maxAmountIn,
            path
        );

        uint256 cKES_balanceAfter = IERC20(cKES).balanceOf(user);
        require(
            cKES_balanceAfter > cKES_balanceBefore,
            "cKES balance did not increase"
        );
    }

    function test_swapTokensForExactTokens_withFourTokens() public {
        IMentoRouter.Step[] memory path = TestPaths
            .USDC_cUSD_axlUSDC_cEUR_EURC();

        uint256 usdc_maxAmountIn = 1e3;
        uint256 EURC_amountOut = 900;

        vm.prank(user);
        IERC20(USDC).approve(address(mentoRouter), usdc_maxAmountIn);

        uint256 EURC_balanceBefore = IERC20(EURC).balanceOf(user);

        vm.prank(user);
        mentoRouter.swapTokensForExactTokens(
            EURC_amountOut,
            usdc_maxAmountIn,
            path
        );

        uint256 EURC_balanceAfter = IERC20(EURC).balanceOf(user);
        require(
            EURC_balanceAfter > EURC_balanceBefore,
            "EURC balance did not increase"
        );
    }

    function test_drain() public {
        vm.prank(user);
        IERC20(USDC).transfer(address(mentoRouter), 1e3);

        uint256 USDC_balanceBefore = IERC20(USDC).balanceOf(
            mentoReserveMultisig
        );
        mentoRouter.drain(USDC);
        uint256 USDC_balanceAfter = IERC20(USDC).balanceOf(
            mentoReserveMultisig
        );

        require(
            USDC_balanceAfter == USDC_balanceBefore + 1e3,
            "USDC not transferred to reserve multisig"
        );
        require(
            IERC20(USDC).balanceOf(address(mentoRouter)) == 0,
            "USDC not drained from contract"
        );
    }
}
