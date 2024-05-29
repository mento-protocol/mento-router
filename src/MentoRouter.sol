// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {IBroker} from "./IBroker.sol";
import {TransferHelper} from "./TransferHelper.sol";
import {IMentoRouter} from "./IMentoRouter.sol";

/// @title MentoRouter
/// @dev Implementation of the IMentoRouter interface for token swaps through a broker.
contract MentoRouter is IMentoRouter {
    /// @notice The broker contract used for executing swaps
    IBroker immutable broker;

    /// @notice Constructor to set the broker address
    /// @param _broker The address of the broker contract
    constructor(address _broker) {
        broker = IBroker(_broker);
    }

    /// @notice Swap an exact amount of input tokens for as many output tokens as possible
    /// @param amountIn The amount of input tokens to swap
    /// @param amountOutMin The minimum amount of output tokens that must be received
    /// @param path An array of Step structs defining the swap path
    /// @return amounts The amounts of tokens for each step in the path
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Step[] calldata path
    ) external returns (uint256[] memory amounts) {
        amounts = getAmountsOut(amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "MentoRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0].assetIn,
            msg.sender,
            address(this),
            amounts[0]
        );
        swap(amounts, path);
    }

    /// @notice Swap as few input tokens as possible for an exact amount of output tokens
    /// @param amountOut The exact amount of output tokens needed
    /// @param amountInMax The maximum amount of input tokens that can be spent
    /// @param path An array of Step structs defining the swap path
    /// @return amounts The amounts of tokens for each step in the path
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        Step[] calldata path
    ) external returns (uint[] memory amounts) {
        amounts = getAmountsIn(amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "MentoRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0].assetIn,
            msg.sender,
            address(this),
            amounts[0]
        );
        swap(amounts, path);
    }

    /// @notice Internal function to execute the swap steps
    /// @param amounts The amounts of tokens for each step in the path
    /// @param path An array of Step structs defining the swap path
    function swap(
        uint256[] memory amounts,
        Step[] memory path
    ) internal virtual {
        for (uint i; i <= path.length - 1; i++) {
            TransferHelper.safeApprove(
                path[i].assetIn,
                address(broker),
                amounts[i]
            );

            broker.swapIn(
                path[i].exchangeProvider,
                path[i].exchangeId,
                path[i].assetIn,
                path[i].assetOut,
                amounts[i],
                amounts[i + 1]
            );
        }

        TransferHelper.safeTransfer(
            path[path.length - 1].assetOut,
            msg.sender,
            amounts[amounts.length - 1]
        );
    }

    /// @notice Internal view function to calculate the output amounts for a given input amount and path
    /// @param amountIn The amount of input tokens to swap
    /// @param path An array of Step structs defining the swap path
    /// @return amounts The calculated amounts of tokens for each step in the path
    function getAmountsOut(
        uint256 amountIn,
        Step[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "MentoRouter: INVALID_PATH");
        amounts = new uint256[](path.length + 1);
        amounts[0] = amountIn;
        for (uint i; i <= path.length - 1; i++) {
            amounts[i + 1] = broker.getAmountOut(
                path[i].exchangeProvider,
                path[i].exchangeId,
                path[i].assetIn,
                path[i].assetOut,
                amounts[i]
            );
        }
        return amounts;
    }

    /// @notice Internal view function to calculate the input amounts for a given output amount and path
    /// @param amountOut The exact amount of output tokens needed
    /// @param path An array of Step structs defining the swap path
    /// @return amounts The calculated amounts of tokens for each step in the path
    function getAmountsIn(
        uint256 amountOut,
        Step[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "MentoRouter: INVALID_PATH");
        amounts = new uint256[](path.length + 1);
        amounts[amounts.length - 1] = amountOut;
        console.log(amountOut);
        for (uint i = path.length; i > 0; i--) {
            amounts[i - 1] = (broker.getAmountIn(
                path[i - 1].exchangeProvider,
                path[i - 1].exchangeId,
                path[i - 1].assetIn,
                path[i - 1].assetOut,
                amounts[i]
            ) + 1); // mAgIk nUmbEr to fix USDC low decimal rounding.
            console.log(amounts[i - 1]);
        }
        return amounts;
    }
}
