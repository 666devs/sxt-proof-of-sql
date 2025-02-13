// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

import "../base/Constants.sol";
import "../base/Errors.sol";

library VerificationBuilder {
    /// @notice Allocates and reserves a block of memory for a verification builder.
    /// @return __builderPtr The pointer to the allocated builder region.
    function __allocate() internal pure returns (uint256 __builderPtr) {
        assembly {
            function builder_allocate() -> builder_ptr {
                builder_ptr := mload(FREE_PTR)
                mstore(FREE_PTR, add(builder_ptr, VERIFICATION_BUILDER_SIZE))
            }
            __builderPtr := builder_allocate()
        }
    }

    /// @notice Sets the challenges in the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @param __challengePtr The pointer to the challenges.
    /// @param __challengeLength The number of challenges.
    /// This is assumed to be "small", i.e. anything less than 2^64 will work.
    function __setChallenges(uint256 __builderPtr, uint256 __challengePtr, uint256 __challengeLength) internal pure {
        assembly {
            function builder_set_challenges(builder_ptr, challenge_ptr, challenge_length) {
                mstore(add(builder_ptr, CHALLENGE_HEAD_OFFSET), challenge_ptr)
                mstore(add(builder_ptr, CHALLENGE_TAIL_OFFSET), add(challenge_ptr, mul(WORD_SIZE, challenge_length)))
            }
            builder_set_challenges(__builderPtr, __challengePtr, __challengeLength)
        }
    }

    /// @notice Consumes a challenge from the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @return __challenge The consumed challenge.
    /// @dev This function will revert if there are no challenges left to consume.
    function __consumeChallenge(uint256 __builderPtr) internal pure returns (uint256 __challenge) {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            function builder_consume_challenge(builder_ptr) -> challenge {
                let head_ptr := mload(add(builder_ptr, CHALLENGE_HEAD_OFFSET))
                challenge := mload(head_ptr)
                head_ptr := add(head_ptr, WORD_SIZE)
                if gt(head_ptr, mload(add(builder_ptr, CHALLENGE_TAIL_OFFSET))) { err(ERR_TOO_FEW_CHALLENGES) }
                mstore(add(builder_ptr, CHALLENGE_HEAD_OFFSET), head_ptr)
            }
            __challenge := builder_consume_challenge(__builderPtr)
        }
    }

    /// @notice Sets the first round mles in the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @param __firstRoundMLEPtr The pointer to the first round mles.
    /// @param __firstRoundMLELength The number of first round mles.
    function __setFirstRoundMLEs(uint256 __builderPtr, uint256 __firstRoundMLEPtr, uint256 __firstRoundMLELength)
        internal
        pure
    {
        assembly {
            function builder_set_first_round_mles(builder_ptr, first_round_mle_ptr, first_round_mle_length) {
                mstore(add(builder_ptr, FIRST_ROUND_MLE_HEAD_OFFSET), first_round_mle_ptr)
                mstore(
                    add(builder_ptr, FIRST_ROUND_MLE_TAIL_OFFSET),
                    add(first_round_mle_ptr, mul(WORD_SIZE, first_round_mle_length))
                )
            }
            builder_set_first_round_mles(__builderPtr, __firstRoundMLEPtr, __firstRoundMLELength)
        }
    }

    /// @notice Consumes a first round mle from the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @return __evaluation The consumed first round mle.
    /// @dev Reverts if there are no first round mles left.
    function __consumeFirstRoundMLE(uint256 __builderPtr) internal pure returns (uint256 __evaluation) {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            function builder_consume_first_round_mle(builder_ptr) -> evaluation {
                let head_ptr := mload(add(builder_ptr, FIRST_ROUND_MLE_HEAD_OFFSET))
                evaluation := mload(head_ptr)
                head_ptr := add(head_ptr, WORD_SIZE)
                if gt(head_ptr, mload(add(builder_ptr, FIRST_ROUND_MLE_TAIL_OFFSET))) {
                    err(ERR_TOO_FEW_FIRST_ROUND_MLES)
                }
                mstore(add(builder_ptr, FIRST_ROUND_MLE_HEAD_OFFSET), head_ptr)
            }
            __evaluation := builder_consume_first_round_mle(__builderPtr)
        }
    }

    /// @notice Sets the final round mles in the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @param __finalRoundMLEPtr The pointer to the final round mles.
    /// @param __finalRoundMLELength The number of final round mles.
    function __setFinalRoundMLEs(uint256 __builderPtr, uint256 __finalRoundMLEPtr, uint256 __finalRoundMLELength)
        internal
        pure
    {
        assembly {
            function builder_set_final_round_mles(builder_ptr, final_round_mle_ptr, final_round_mle_length) {
                mstore(add(builder_ptr, FINAL_ROUND_MLE_HEAD_OFFSET), final_round_mle_ptr)
                mstore(
                    add(builder_ptr, FINAL_ROUND_MLE_TAIL_OFFSET),
                    add(final_round_mle_ptr, mul(WORD_SIZE, final_round_mle_length))
                )
            }
            builder_set_final_round_mles(__builderPtr, __finalRoundMLEPtr, __finalRoundMLELength)
        }
    }

    /// @notice Consumes a final round mle from the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @return __evaluation The consumed final round mle.
    /// @dev Reverts if there are no final round mles left.
    function __consumeFinalRoundMLE(uint256 __builderPtr) internal pure returns (uint256 __evaluation) {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            function builder_consume_final_round_mle(builder_ptr) -> evaluation {
                let head_ptr := mload(add(builder_ptr, FINAL_ROUND_MLE_HEAD_OFFSET))
                evaluation := mload(head_ptr)
                head_ptr := add(head_ptr, WORD_SIZE)
                if gt(head_ptr, mload(add(builder_ptr, FINAL_ROUND_MLE_TAIL_OFFSET))) {
                    err(ERR_TOO_FEW_FINAL_ROUND_MLES)
                }
                mstore(add(builder_ptr, FINAL_ROUND_MLE_HEAD_OFFSET), head_ptr)
            }
            __evaluation := builder_consume_final_round_mle(__builderPtr)
        }
    }

    /// @notice Sets the chi evaluations in the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @param __chiEvaluationPtr The pointer to the chi evaluations.
    /// @param __chiEvaluationLength The number of chi evaluations.
    function __setChiEvaluations(uint256 __builderPtr, uint256 __chiEvaluationPtr, uint256 __chiEvaluationLength)
        internal
        pure
    {
        assembly {
            function builder_set_chi_evaluations(builder_ptr, chi_evaluation_ptr, chi_evaluation_length) {
                mstore(add(builder_ptr, CHI_EVALUATION_HEAD_OFFSET), chi_evaluation_ptr)
                mstore(
                    add(builder_ptr, CHI_EVALUATION_TAIL_OFFSET),
                    add(chi_evaluation_ptr, mul(WORD_SIZE, chi_evaluation_length))
                )
            }
            builder_set_chi_evaluations(__builderPtr, __chiEvaluationPtr, __chiEvaluationLength)
        }
    }

    /// @notice Consumes a chi evaluation from the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @return __evaluation The consumed chi evaluation.
    /// @dev Reverts if there are no chi evaluations left.
    function __consumeChiEvaluation(uint256 __builderPtr) internal pure returns (uint256 __evaluation) {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            function builder_consume_chi_evaluation(builder_ptr) -> evaluation {
                let head_ptr := mload(add(builder_ptr, CHI_EVALUATION_HEAD_OFFSET))
                evaluation := mload(head_ptr)
                head_ptr := add(head_ptr, WORD_SIZE)
                if gt(head_ptr, mload(add(builder_ptr, CHI_EVALUATION_TAIL_OFFSET))) {
                    err(ERR_TOO_FEW_CHI_EVALUATIONS)
                }
                mstore(add(builder_ptr, CHI_EVALUATION_HEAD_OFFSET), head_ptr)
            }
            __evaluation := builder_consume_chi_evaluation(__builderPtr)
        }
    }

    /// @notice Sets the rho evaluations in the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @param __rhoEvaluationPtr The pointer to the rho evaluations.
    /// @param __rhoEvaluationLength The number of rho evaluations.
    function __setRhoEvaluations(uint256 __builderPtr, uint256 __rhoEvaluationPtr, uint256 __rhoEvaluationLength)
        internal
        pure
    {
        assembly {
            function builder_set_rho_evaluations(builder_ptr, rho_evaluation_ptr, rho_evaluation_length) {
                mstore(add(builder_ptr, RHO_EVALUATION_HEAD_OFFSET), rho_evaluation_ptr)
                mstore(
                    add(builder_ptr, RHO_EVALUATION_TAIL_OFFSET),
                    add(rho_evaluation_ptr, mul(WORD_SIZE, rho_evaluation_length))
                )
            }
            builder_set_rho_evaluations(__builderPtr, __rhoEvaluationPtr, __rhoEvaluationLength)
        }
    }

    /// @notice Consumes a rho evaluation from the verification builder.
    /// @param __builderPtr The pointer to the verification builder.
    /// @return __evaluation The consumed rho evaluation.
    /// @dev Reverts if there are no rho evaluations left.
    function __consumeRhoEvaluation(uint256 __builderPtr) internal pure returns (uint256 __evaluation) {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            function builder_consume_rho_evaluation(builder_ptr) -> evaluation {
                let head_ptr := mload(add(builder_ptr, RHO_EVALUATION_HEAD_OFFSET))
                evaluation := mload(head_ptr)
                head_ptr := add(head_ptr, WORD_SIZE)
                if gt(head_ptr, mload(add(builder_ptr, RHO_EVALUATION_TAIL_OFFSET))) {
                    err(ERR_TOO_FEW_RHO_EVALUATIONS)
                }
                mstore(add(builder_ptr, RHO_EVALUATION_HEAD_OFFSET), head_ptr)
            }
            __evaluation := builder_consume_rho_evaluation(__builderPtr)
        }
    }
}
