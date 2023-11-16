// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";

contract SwapToken is ERC20 {
    address private constant UNISWAP_V3_POOL =
        0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // placeholder address as the pool does not exist yet
    address private owner;

    constructor(uint256 initialSupply) ERC20("SwapToken", "SWP") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function swapToWETH(uint256 amount) external onlyOwner {
        // Ensure sufficient allowance
        require(
            allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );

        // Transfer tokens to this contract
        _transfer(msg.sender, address(this), amount);

        // Approve UniswapV3Pool to spend tokens
        approve(UNISWAP_V3_POOL, amount);

        // Swap tokens to WETH
        (int256 amount0, int256 amount1) = IUniswapV3Pool(UNISWAP_V3_POOL).swap(
            address(this),
            false,
            int256(amount),
            0,
            ""
        );

        // Handle callback if needed
        // ...

        // Ensure successful swap
        require(amount0 > 0 && amount1 > 0, "Swap failed");
    }

    function swapFromWETH(uint256 amount) external onlyOwner {
        IWETH9 weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        // Transfer WETH to this contract
        require(
            weth.transferFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );

        // Approve UniswapV3Pool to spend WETH
        weth.approve(UNISWAP_V3_POOL, amount);

        // Swap WETH to tokens
        (int256 amount0, int256 amount1) = IUniswapV3Pool(UNISWAP_V3_POOL).swap(
            address(this),
            true,
            int256(amount),
            0,
            ""
        );

        // Handle callback if needed
        // ...

        // Ensure successful swap
        require(amount0 > 0 && amount1 > 0, "Swap failed");
    }
}
