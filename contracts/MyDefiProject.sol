// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CTokensInterface.sol";
import "./ComptrollerInterface.sol";
import "./PriceOracleInterface.sol";

contract MyDefiProject {
    ComptrollerInterface public comptroller;
    PriceOracleInterface public priceOracle;

    constructor(address _comptroller, address _priceOracle) {
        comptroller = ComptrollerInterface(_comptroller);
        priceOracle = PriceOracleInterface(_priceOracle);
    }

    /**
     * @notice Supplies tokens to the Compound protocol to earn interest
     * @dev User must approve this contract to spend their tokens before calling this function
     * @param cTokenAddress The address of the cToken contract (e.g., cDAI, cUSDC)
     * @param underlyingAmount The amount of underlying tokens to supply (e.g., DAI, USDC)
     * 
     * Flow:
     * 1. Get reference to the cToken contract (e.g., cDAI)
     * 2. Find out what is the underlying token (e.g., DAI)
     * 3. Transfer underlying tokens from user to this contract
     * 4. Approve cToken contract to spend the underlying
     * 5. Mint cTokens by supplying underlying tokens to Compound
     */
    function supply(address cTokenAddress, uint underlyingAmount) external {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        address underlying = cToken.underlying();
        IERC20(underlying).transferFrom(msg.sender, address(this), underlyingAmount);
        IERC20(underlying).approve(cTokenAddress, underlyingAmount);
        require(cToken.mint(underlyingAmount) == 0, "Mint failed");
    }

    /**
     * @notice Withdraws tokens from Compound by redeeming cTokens
     * @dev The amount of underlying tokens received will be more than cTokenAmount due to accrued interest
     * @param cTokenAddress The address of the cToken contract (e.g., cDAI, cUSDC)
     * @param cTokenAmount The amount of cTokens to redeem
     * 
     * Flow:
     * 1. Get reference to the cToken contract
     * 2. Redeem cTokens for underlying tokens (e.g., convert cDAI back to DAI)
     * 3. Get the address of underlying token
     * 4. Check how many underlying tokens we received
     * 5. Transfer ALL underlying tokens to the sender (NOTE: This is a potential issue if multiple users)
     * 
     * SECURITY CONSIDERATION:
     * Current implementation transfers all underlying tokens in the contract to the redeemer.
     * This could be problematic if multiple users are using the contract simultaneously
     * as one user could potentially receive another user's tokens.
     */
    function redeem(address cTokenAddress, uint cTokenAmount) external {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        require(cToken.redeem(cTokenAmount) == 0, "Redeem failed");
        address underlying = cToken.underlying();
        uint underlyingBalance = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).transfer(msg.sender, underlyingBalance);
    }
}