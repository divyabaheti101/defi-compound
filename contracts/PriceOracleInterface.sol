// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

interface PriceOracleInterface {
    function getUnderlyingPrice(address token) external view returns (uint256);
}