pragma solidity ^0.5.0;

import "./ERC1155MixedFungible.sol";

/**
    @dev Mintable form of ERC1155
    Shows how easy it is to mint new items
*/
contract ERC1155MixedFungibleMintable is ERC1155MixedFungible {
    
    uint256 nonce;
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public maxIndex;

    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender);
        _;
    }

    // This function only creates the type.
    // Changed from external to internal to override it inside EmployeeRecognition
    function create(string memory _uri, bool _isNF)
        internal
        returns (uint256 _type)
    {
        // Store the type in the upper 128 bits
        _type = (++nonce << 128);

        // Set a flag if this is an NFI.
        if (_isNF) _type = _type | TYPE_NF_BIT;

        // This will allow restricted access to creators.
        creators[_type] = msg.sender;

        // emit a Transfer event with Create semantic to help with discovery.
        emit TransferSingle(msg.sender, address(0x0), address(0x0), _type, 0);

        if (bytes(_uri).length > 0) emit URI(_uri, _type);

        return _type;
    }

    // Custom event in which we notify our watcher
    event NotifyWatcher(address _operator, address indexed _from, address indexed _to, uint256 _id, string _offchainId);

    function mintNonFungible(uint256 _type, address[] calldata _to, string calldata _offchainId)
        external
    {
        // No need to check this is a nf type rather than an id since
        // creatorOnly() will only let a type pass through.
        require(isNonFungible(_type));

        // Index are 1-based.
        uint256 index = maxIndex[_type] + 1;
        maxIndex[_type] = _to.length.add(maxIndex[_type]);

        for (uint256 i = 0; i < _to.length; ++i) {
            address dst = _to[i];
            uint256 id = _type | (index + i);

            nfOwners[id] = dst;

            // You could use base-type id to store NF type balances if you wish.
            // balances[_type][dst] = quantity.add(balances[_type][dst]);
            

            emit TransferSingle(msg.sender, address(0x0), dst, id, 1);
            emit NotifyWatcher(msg.sender, address(0x0), dst, id, _offchainId);

            if (dst.isContract()) {
                _doSafeTransferAcceptanceCheck(
                    msg.sender,
                    msg.sender,
                    dst,
                    id,
                    1,
                    ""
                );
            }
        }
    }

    function mintFungible(
        uint256 _id,
        address[] calldata _to,
        uint256[] calldata _quantities
    ) external creatorOnly(_id) {
        require(isFungible(_id));

        for (uint256 i = 0; i < _to.length; ++i) {
            address to = _to[i];
            uint256 quantity = _quantities[i];

            // Grant the items to the caller
            balances[_id][to] = quantity.add(balances[_id][to]);

            // Emit the Transfer/Mint event.
            // the 0x0 source address implies a mint
            // It will also provide the circulating supply info.
            emit TransferSingle(msg.sender, address(0x0), to, _id, quantity);

            if (to.isContract()) {
                _doSafeTransferAcceptanceCheck(
                    msg.sender,
                    msg.sender,
                    to,
                    _id,
                    quantity,
                    ""
                );
            }
        }
    }
}
