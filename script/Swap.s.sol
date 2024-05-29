// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IBroker} from "src/IBroker.sol";
import {MentoRouter, IMentoRouter} from "src/MentoRouter.sol";

contract Swap is Script {
    IBroker constant broker =
        IBroker(0x777A8255cA72412f0d706dc03C9D1987306B4CaD);
    MentoRouter constant mentoRouter =
        MentoRouter(0x5202D9e4ea9AB59FA4867B78C80d7C84a46a1a22);

    address constant bpm = 0x22d9db95E6Ae61c104A7B6F6C78D7993B94ec901;
    address constant user = 0x8E8E5F2EB9b8cd64942777E287982fF986a2c5A1;
    address constant celo = 0x471EcE3750Da237f93B8E339c536989b8978a438;
    address constant cUSD = 0x765DE816845861e75A25fCA122bb6898B8B1282a;
    address constant cKES = 0x456a3D042C0DbD3db53D5489e98dFb038553B0d0;
    address constant USDC = 0xcebA9300f2b948710d2653dD7B07f33A8B32118C;

    bytes32 constant cUSD_celo_eID =
        0x3135b662c38265d0655177091f1b647b4fef511103d06c016efdf18b46930d2c;
    bytes32 constant cUSD_cKES_eID =
        0x89de88b8eb790de26f4649f543cb6893d93635c728ac857f0926e842fb0d298b;
    bytes32 constant cUSD_USDC_eID =
        0xacc988382b66ee5456086643dcfd9a5ca43dd8f428f6ef22503d8b8013bcffd7;

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
        IMentoRouter.Step[] memory path = new IMentoRouter.Step[](2);

        path[0] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cUSD_USDC_eID,
            assetIn: USDC,
            assetOut: cUSD
        });

        path[1] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cUSD_cKES_eID,
            assetIn: cUSD,
            assetOut: cKES
        });

        uint256 usdc_amountIn = 1e3;

        vm.startBroadcast(
            0x604f9bff763823555b515b8717316bc84b0c250f43e7604fb9a967214b9982b3
        );
        IERC20(USDC).approve(address(mentoRouter), usdc_amountIn);
        mentoRouter.swapExactTokensForTokens(usdc_amountIn, 0, path);
        vm.stopBroadcast();

        console.log(IERC20(cKES).balanceOf(user));
    }
}
