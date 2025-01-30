// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

/// @title Math Utilities Library
/// @notice Provides functions to perform various math operations
library MathUtil {
    /// @notice Computes `max(1,ceil(log_2(value)))`
    /// @dev The smallest integer greater than or equal to the base 2 logarithm of a number.
    /// If the number is less than 2, the result is 1.
    /// @param value0 The input value for which to compute the logarithm
    /// @return exponent0 The computed logarithm value
    function log2Up(uint256 value0) internal pure returns (uint256 exponent0) {
        assembly {
            function log2_up(value) -> exponent {
                if value { value := sub(value, 1) }
                exponent := 1
                for {} shr(exponent, value) {} { exponent := add(exponent, 1) }
            }
            exponent0 := log2_up(value0)
        }
    }
}
