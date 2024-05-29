// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MentoRouter, IMentoRouter} from "src/MentoRouter.sol";

address constant bpm = 0x22d9db95E6Ae61c104A7B6F6C78D7993B94ec901;
address constant user = 0x8E8E5F2EB9b8cd64942777E287982fF986a2c5A1;
address constant celo = 0x471EcE3750Da237f93B8E339c536989b8978a438;
address constant cUSD = 0x765DE816845861e75A25fCA122bb6898B8B1282a;
address constant cKES = 0x456a3D042C0DbD3db53D5489e98dFb038553B0d0;
address constant USDC = 0xcebA9300f2b948710d2653dD7B07f33A8B32118C;
address constant EURC = 0x061cc5a2C863E0C1Cb404006D559dB18A34C762d;
address constant cEUR = 0xD8763CBa276a3738E6DE85b4b3bF5FDed6D6cA73;
address constant axlUSDC = 0xEB466342C4d449BC9f53A865D5Cb90586f405215;

bytes32 constant cUSD_celo_eID = 0x3135b662c38265d0655177091f1b647b4fef511103d06c016efdf18b46930d2c;
bytes32 constant cUSD_cKES_eID = 0x89de88b8eb790de26f4649f543cb6893d93635c728ac857f0926e842fb0d298b;
bytes32 constant cUSD_USDC_eID = 0xacc988382b66ee5456086643dcfd9a5ca43dd8f428f6ef22503d8b8013bcffd7;
bytes32 constant cUSD_axlUSDC_ID = 0x0d739efbfc30f303e8d1976c213b4040850d1af40f174f4169b846f6fd3d2f20;
bytes32 constant cEUR_axlUSDC_ID = 0xf418803158d881fda22694067bf6479476cec22ecfeeca2f6a65a6259bdbb9c0;
bytes32 constant cEUR_EURC_ID = 0xfca6d94b46122eb9a4b86cf9d3e1e856fea8a826d0fc26c5baf17c43fbaf0f48;

library TestPaths {
    function USDC_cUSD_cKES()
        internal
        pure
        returns (IMentoRouter.Step[] memory path)
    {
        path = new IMentoRouter.Step[](2);
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
    }

    function USDC_cUSD_axlUSDC_cEUR_EURC()
        internal
        pure
        returns (IMentoRouter.Step[] memory path)
    {
        path = new IMentoRouter.Step[](4);
        path[0] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cUSD_USDC_eID,
            assetIn: USDC,
            assetOut: cUSD
        });

        path[1] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cUSD_axlUSDC_ID,
            assetIn: cUSD,
            assetOut: axlUSDC
        });

        path[2] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cEUR_axlUSDC_ID,
            assetIn: axlUSDC,
            assetOut: cEUR
        });

        path[3] = IMentoRouter.Step({
            exchangeProvider: bpm,
            exchangeId: cEUR_EURC_ID,
            assetIn: cEUR,
            assetOut: EURC
        });
    }
}
