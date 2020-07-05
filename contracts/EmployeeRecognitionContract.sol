pragma solidity ^0.5.0;

import "./ERC1155MixedFungibleMintable.sol";
import "./IERC1155Metadata.sol";
import "./String.sol";

contract EmployeeRecognitionContract is
    ERC1155MixedFungibleMintable,
    ERC1155Metadata_URI
{
    string private _baseUri;
    address public contractOwner;

    event NotifyWatcher(string address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value)

    modifier _ownerOnly() {
        require(msg.sender == contractOwner);
        _;
    }

    constructor(string memory _uri) public {
        _baseUri = _uri;
        contractOwner = msg.sender;
    }

    function setBaseUri(string memory _uri) public _ownerOnly {
        _baseUri = _uri;
    }

    function getBaseUri() public view returns (string memory) {
        return _baseUri;
    }

    function uri(uint256 _id) external view returns (string memory) {
        return string(abi.encodePacked(_baseUri, "/", String.fromUint(_id)));
    }

    function create() external returns (uint256 _type) {
        // Setting default values
        return super.create("", true);
    }
}
