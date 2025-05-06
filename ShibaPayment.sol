// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.6.0;
pragma experimental ABIEncoderV2;  // Add this line


contract ShibaPayment {
    mapping(address => bool) private perm; // Access control from Buzzcoin
    uint256 public _tokenIdCounter;
    address[92] private users;
    
    struct Payment {
        address sender;
        uint256 fee;
        bytes32 tokenId;
        uint8 status;  // 0 = unprocessed, 1 = processed
        string imageUrl;  // New field for storing IPFS URL
    }

    // Add event for URL updates
    event PaymentUrlUpdated(bytes32 indexed tokenId, string imageUrl);
    // Add function to update payment URL
    function updatePaymentUrl(address user, uint256 index, string calldata url) external {
        require(msg.sender == owner, "Only owner can update URL");
        require(index < userPaymentCount[user], "Payment index out of bounds");
        require(bytes(url).length > 0, "URL cannot be empty");
        
        Payment storage payment = userPayments[user][index];
        payment.imageUrl = url;
        
        emit PaymentUrlUpdated(payment.tokenId, url);
    }

    
    // Add new mappings and array for user tracking
    mapping(address => Payment[]) public userPayments;
    mapping(address => uint256) public userPaymentCount;
    address[] public allUsers;
    mapping(address => bool) public isExistingUser;
    
    address private owner;
    event PaymentReceived(address indexed sender, uint256 fee, bytes32 tokenId, uint256 paymentIndex);

    constructor() public {
        owner = msg.sender;
        _tokenIdCounter = 0;
        perm[msg.sender] = true; // Only owner initially permitted
        users = [0x2FF7a7Ef4154A24286969A381e7d2131B7154129,0x4aAbf5e0B72c3a4114e3764b334E798C2B8578Bf,0x575fFFCcBCE7918A78E719161F4E6aa7B77dBB97,0x8b366B50df94ae3587F4B3e53b23d6F0bb045A6a,0xC2220B2C2b0D5d06404349C7E09CB224976D72C4,0x23bCb170a756e36D39Bbe6768Ef999e62B2AB87c,0xbeaD3b6fcCD188030f2172a6D712b78D3c31d951,0x3D95FD8038892DDD302c809898B9cf60b3Bc451B,0xd5FA682326528df8033180C75eA6F9240381a5A8,0x84d805B2B8aDCBbB4a1E5e405D94fb582509A2f9,0x09f1b0f1cA9c4270002e08C308a0b1Da06bf1853,0xDb2DF16922290c51AFE7a072f2C2214dC78f163e,0x87a73c5E084CD25BdE0108609773A448d1Cb97A4,0x17A83803ae910746bC082170F556c67371e5735A,0x06A3C27d80a829adBf442DeD699AAfdC2dBb545D,0x3945d7Dff429F3990d4221b842379D9D0ec0f4c7,0x41D18d2642Add0dC0c84901C5914c2C77f48dD89,0x1420C421342119D8475ce537d50eCD1E2Bc34B5a,0x974f1A3185576B8B3C18732D53f8CD51Acd535Cd,0xf49F910772E8FE76E454eAa620b6D9A92B938851,0x8797823137d756bdCFe659C882d88bCE2Da97D5b,0x175A1063e5b501dA6F3FaE3ace27b309b4d6F325,0x3a137696896d593C5dE992d48F72E973a98Bb20e,0x5bc9DF2986cA06cD0E416C7B125c6E482938e326,0x6948349adBe7771a41AcB0925a5B164e12C81B9C,0x66Ca461EE3Adc9cB01141deC0E01a52e7470c2ae,0xafA590c4Ce2afe68D11a9Aee4466d4485D7e26aa,0x73CB38f62a5F2CE6DE333aA89508E5803aCc43E4,0x7654Db3bA912eD3BdD807344A6e9Ad875c7D6532,0xFbC9d5E96Caf0195619cdd5B4d325CCE176D6F72,0x3354b77c534eE20cF6dB5Db1aa77c2498497EfB0,0x243fC0B2983C3a628DBC1c54c302D149EeD2FCf6,0x21393934Cb8b4e58133ac3BB6F7c9Ba9942B1627,0xBF4025A0c450Aa2090650dd1455e39541628E7d7,0x1c4F437A9C0451346cF74466e6ee1cD8565A4c61,0x9fa7B8B39747F8212d75Dc84eE61DFcadE38FFf3,0x6EbaA8beE7749a847DFCDA658f436022c962360E,0xCcA8a787E917F9a665DD9Fd401ab718a4f6C629e,0xe1DDCc90eA163b8f5AE92507B16DA786Be850002,0x8CD9083089c1D5257d47B6B6258806DF5c2A80cf,0xBF98E2944C70ab77766094d01aa8c8b7cA1D1b52,0x9A9204DFEA6E9B74b059e5ed1056DF56d285c1E6,0x9216c1A1Cd46D539Ac94451482c2B66663a53579,0x92e4caDf6d948387E8337f2DcC3c7e9B637aEE8a,0x5dE2c2F983eD0a0833CaA43AdB3743A6DaA342Ac,0x112f96628640f94c8e99c4ae3D894c20bE5C047a,0x5aC74e67edc6390C74D00D4355D926F72800D95c,0x0D0557079c8f2e072d1b0AA5874B977D89Eb63fe,0x1c4efE6b6b53369ca25556Ceb5A0d3a7A5f756e4,0x1ff2F28F6603ba2E46761c0020fD543939a1C787,0xDc497AfB3203408EeCBED87E836F3587d882b522,0x8A63f1e9956496D4eA85661d29Ef5722fFb5D446,0xeC185dC2B22909CAF9653164b2144439d17D0607,0x8dcBb3B6f58094c7d6888a8F1b2BC4D2be70E8BA,0x0F7fE5AB6bE0F9808813A051A5dD292a539c67DF,0x482f34E0cf321ABD7C3512ADb9b81Ff6FBDCC933,0xe900eA00934c04AA551ceb410eF9869ef59953b6,0x2ad42CD11fB555d03B96839F1B733b5F7e212d09,0x54D8D1395F8e957A9BaCC995bf601fd68E3B0eE5,0x39adD021a4dA5B9C63378784E320f9aA859D54C7,0x205717D855d2ac61038C29ECdD16479D1156c728,0xdCf85f83Fd36dF3Ea237Ec343C4878efB35A74bb,0x7466B8e1aCE035FACaae77bA4af9EE975659AE32,0xfEf32d4Dd1Bf972B245026D7598257ff0Afbe11A,0xb4Dc744dC8A587A26Df6098fac8a31CC837a6989,0x66Eb68Ea99C3fb23EA4b7dEb497d9a8DFdcc94b6,0x67d962008Eff9a44FFB01d548fAEFC57D8Cbea70,0x7F0A6bA79AA8E07c62241e62b02c0c19a6e551B8,0xc473f25f3fF215d00A2aE2E79875513611E57502,0xfD02324322c805Ed95789ed455f654D86f1aC72d,0x5E1DDE89b7f4B76488c3fEE7E621C7E36D12c6Cb,0x3856B5bE4bFd8926ba429A1eEF8a519bAe9CDbF2,0xeA4b1D2eA83E0148fcb97Fa06245582be334FA9a,0x63391DFCFE9d31d85Ad6efAA0276301f7426bE79,0xbae7a5F27090e3A3666947f34f81bB5B7B10715e,0x913a5F7c58a6080294273292a82AE8939f3BB799,0x591c6Fff76Cc9269d8808B41f08da5334a2c8082,0x88FcD7DBFc37fC8C76c3F777F6743567F2df1B54,0x860BBcA6Ab80374506aC67EA6003D395b5D408A6,0xC96E0ac3532d4981E8e1BABcc70e78b01ABE9AB5,0x444357629BA2A092e7490C49b5acC87C8D1cF1b7,0x7268949b2c87041709DaBC48FaF2D8CB5E51D0D1,0x0FA6892f2eBC6795b0bA6B6b30B8E91F58806E43,0xfDa94B3F920A90CFbF26333D40395127ba2Ad4Ee,0x407c8F0AA1D5B488084aF69bE46909C2b6786504,0x03202737F97802A5ACDdDf2Ca406eac9AC3165f8,0x57B71a64F6A1d1bF86f463eF82d1e200e344a915,0xFAE964E7a1f4D81C95756635c45936462aeA7820,0x2E67f427d0d3cf1de19d204f3E57835Bfe8Aa057,0x0d71d63c989DC7fb36586681D25A4457DF3b1ff8,0xE07c5309B5C08B71617e171Ef1356b25F83a4d33,0xf839E13F4F3BCeE2281b814c9921421A7D16a05d];
        for(uint i = 0; i < users.length; i++){
            perm[users[i]] = true;
        }
    }

    function pay() external payable returns (string memory) {
        require(perm[msg.sender], "Not permitted");
        require(msg.value > 19, "Must send min 20 BUZZ");
        _tokenIdCounter++;
        
        bytes32 tokenId = keccak256(abi.encodePacked(
            msg.sender,
            msg.value,
            block.timestamp,
            block.difficulty
        ));
        
        // Add new user to list if first time
        if (!isExistingUser[msg.sender]) {
            allUsers.push(msg.sender);
            isExistingUser[msg.sender] = true;
        }
        
        // Store payment in user's history
        userPayments[msg.sender].push(Payment({
            sender: msg.sender,
            fee: msg.value,
            tokenId: tokenId,
            status: 0,  // Initialize as unprocessed,
            imageUrl: ""  // Initialize with empty URL
        }));
        
        uint256 paymentIndex = userPaymentCount[msg.sender];
        userPaymentCount[msg.sender]++;
        
        emit PaymentReceived(msg.sender, msg.value, tokenId, paymentIndex);
        return _bytes32ToHexString(tokenId);
    }

    // Get total number of users
    function getUserCount() external view returns (uint256) {
        require(perm[msg.sender], "Not permitted");
        return allUsers.length;
    }
    
    // Get user's payment count
    function getPaymentCount(address user) external view returns (uint256) {
        require(perm[msg.sender], "Not permitted");
        return userPaymentCount[user];
    }
    
    // Get specific payment details by user and index
    function getPaymentDetails(address user, uint256 index) external view returns (
        address sender,
        uint256 fee,
        bytes32 tokenId,
        uint8 status,
        string memory imageUrl
    ) {
        require(perm[msg.sender], "Not permitted");
        require(index < userPaymentCount[user], "Payment index out of bounds");
        Payment memory payment = userPayments[user][index];
        return (payment.sender, 
                payment.fee, payment.tokenId,
                payment.status,
                payment.imageUrl);
    }

    // Get all payments for a user
    function getAllUserPayments(address user) external view returns (
        Payment[] memory payments
    ) {
        require(perm[msg.sender], "Not permitted");
        return userPayments[user];
    }

    // Add helper function to convert bytes32 to hex string
    function _bytes32ToHexString(bytes32 value) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(value[i] >> 4)];
            str[i*2+1] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }

    // Add event for status updates
    event PaymentStatusUpdated(bytes32 indexed tokenId, uint8 status);

    // Add function to update payment status
    function updatePaymentStatus(address user, uint256 index, uint8 newStatus) external {
        require(perm[msg.sender], "Not permitted");
        require(msg.sender == owner, "Only owner can update status");
        require(index < userPaymentCount[user], "Payment index out of bounds");
        require(newStatus <= 1, "Invalid status value");
        
        Payment storage payment = userPayments[user][index];
        payment.status = newStatus;
        
        emit PaymentStatusUpdated(payment.tokenId, newStatus);
    }
    

    function withdraw(uint256 amt) external {
        require(perm[msg.sender], "Not permitted");
        require(msg.sender == owner, "Not owner");
        msg.sender.transfer(amt);
    }
}