// SPDX-License-Identifier: MIT
pragma solidity >=0.6.8 <0.7.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../libraries/Percentages.sol";
import "../interfaces/ITrustedToken.sol";
import "../storage/DonorRefund.sol";
import "./ManagedPayout.sol";



/**
 * @title Refundable Grant.
 * @dev Handles refund to donors.
 * @author @NoahMarconi @ameensol @JFickel @ArnaudBrousseau
 */
contract Refundable is ReentrancyGuard, DonorRefund, ManagedPayout {
    using SafeMath for uint256;


    /*----------  Public Methods  ----------*/

    /**
     * @dev Get available grant balance.
     * @return Balance remaining in contract.
     */
    function availableBalance()
        public
        view
        returns(uint256)
    {
        return this.getTotalFunding()
            .sub(this.getTotalPaid())
            .sub(this.getTotalRefunded());
    }

    /**
     * @dev Withdraws portion of the contract's available balance.
     *      Amount donor receives is proportionate to their funding contribution.
     * @param donor Donor address to refund.
     * @return true if withdraw successful.
     */
    function withdrawRefund(address payable donor)
        public
        nonReentrant // OpenZeppelin mutex due to sending funds.
        returns(bool)
    {

        uint256 eligibleRefund = Percentages.maxAllocation(
            this.getDonorFunded(donor),
            this.getTotalFunding(),
            this.getTotalRefunded()
        );

        require(
            eligibleRefund >= this.getDonorRefunded(donor),
            "withdrawRefund::Error. Donor has already withdrawn eligible refund."
        );

        // Minus previous withdrawals.
        eligibleRefund = eligibleRefund.sub(this.getDonorRefunded(donor));

        // Update state.
        this.setDonorRefunded(
            donor,
            this.getDonorRefunded(donor).add(eligibleRefund)
        );

        // Send funds.
        if (this.getCurrency() == address(0)) {
            require(
                // @audit question for auditor: use send or .call{ value: eligibleRefund }("")   ?
                donor.send(eligibleRefund), // solhint-disable-line check-send-result
                "withdrawRefund::Transfer Error. Unable to send refundValue to Donor."
            );
        } else {
            require(
                ITrustedToken(this.getCurrency())
                    .transfer(donor, eligibleRefund),
                "withdrawRefund::Transfer Error. ERC20 token transfer failed."
            );
        }

        emit LogRefund(donor, eligibleRefund);

        return true;
    }


}