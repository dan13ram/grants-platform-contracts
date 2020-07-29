// SPDX-License-Identifier: MIT
pragma solidity >=0.6.8 <0.7.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../libraries/Percentages.sol";
import "../interfaces/ITrustedToken.sol";
import "../interfaces/IDonorRefund.sol";




/**
 * @title Donor Refund State.
 * @dev Tracks state related to donor refunds.
 * @author @NoahMarconi
 */
contract DonorRefund is IDonorRefund {


    /*----------  Globals  ----------*/

    uint256 private totalRefunded;                       // Cumulative funding refunded to donors.
    mapping(address => uint256) private donorRefunded;   // Cumulative amount refunded.


   /*----------  Public Getters  ----------*/

    function getTotalRefunded()
        external
        override
        view
        returns(uint256)
    {
        return totalRefunded;
    }

    function getDonorRefunded(address donor)
        external
        override
        view
        returns(uint256)
    {
        return donorRefunded[donor];
    }


    /*----------  Internal Setters  ----------*/

    function setTotalRefunded(uint256 value)
        internal
    {
        totalRefunded = value;
    }


    function setDonorRefunded(address donor, uint256 value)
        internal
    {
        donorRefunded[donor] = value;
    }

}