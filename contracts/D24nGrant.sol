// SPDX-License-Identifier: MIT

pragma solidity >=0.6.8 <0.7.0;


import "./shared/libraries/Percentages.sol";
import "./shared/interfaces/ITrustedToken.sol";
import "./shared/modules/GranteeConstructor.sol";
import "./shared/storage/Funding.sol";
import "./shared/storage/BaseGrant.sol";
import "./shared/storage/Manager.sol";



/**
 * @title Grant for d24n.
 * @dev Managed                     (y)
 *      Funding Deadline            (n)
 *      Contract expiry             (y)
 *      With Token                  (y)
 *      Percentage based allocation (y)
 * @author @NoahMarconi
 */
contract D24nGrant is GranteeConstructor, Funding, BaseGrant, Manager  {


    /*----------  Constructor  ----------*/

    /**
     * @dev Grant creation function. May be called by grantors, grantees, or any other relevant party.
     * @param _grantees Sorted recipients of unlocked funds.
     * @param _amounts Respective allocations for each Grantee (must follow sort order of _grantees).
     * @param _currency (Optional) If null, amount is in wei, otherwise address of ERC20-compliant contract.
     * @param _uri URI for additional (off-chain) grant details such as description, milestones, etc.
     * @param _extraData (Optional) Support for extensions to the Standard.
     */
    constructor(
        address[] memory _grantees,
        uint256[] memory _amounts,
        address _currency,
        bytes memory _uri,
        bytes memory _extraData
    )
        public
        GranteeConstructor(_grantees, _amounts, true)
    {

        address _manager;            //  _manager Multisig or EOA address of grant manager.
        uint256 _contractExpiration; //  _contractExpiration Date after which payouts must be complete or anyone can trigger refunds.
        bool _percentageBased;       //  _percentageBased Grantee targets are percentage based or fixed.
        (
            _manager,
            _contractExpiration,
            _percentageBased
        ) = abi.decode(_extraData, (address, uint256, bool));

        require(
            _currency != address(0) && ITrustedToken(_currency).decimals() == 18,
            "constructor::Invalid Argument. Token must have 18 decimal places."
        );

        require(
            // solhint-disable-next-line not-rely-on-time
            _contractExpiration != 0 && _contractExpiration > now,
            "constructor::Invalid Argument. _contractExpiration not > now."
        );


        // Initialize BaseGrant globals.
        setUri(_uri);
        setCurrency(_currency);
        setContractExpiration(_contractExpiration);

        // Initialize Grantee globals.
        setPercentageBased(_percentageBased);

        // Initialize Manager globals.
        setManager(_manager);

    }


}
