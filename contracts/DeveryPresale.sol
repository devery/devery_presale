pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'PREVE' 'Presale EVE Tokens' token contract
//
// Deployed to : {TBA}
// Symbol      : PREVE
// Name        : Presale EVE Tokens
// Total supply: Minted
// Decimals    : 18
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Devery Presale Whitelist Interface
// ----------------------------------------------------------------------------
contract DeveryPresaleWhitelist {
    mapping(address => uint) public whitelist;
}


// ----------------------------------------------------------------------------
// Parity PICOPS Whitelist Interface
// ----------------------------------------------------------------------------
contract PICOPSCertifier {
    function certified(address) public constant returns (bool);
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals, minting and
// transferable flag. See:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Token is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    bool public transferable;
    bool public mintable = true;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event MintingDisabled();
    event TransfersEnabled();

    function ERC20Token(string _symbol, string _name, uint8 _decimals) public {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
    }

    // --- ERC20 standard functions ---
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        require(transferable);
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        require(transferable);
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(transferable);
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // --- Additions over ERC20 ---
    function disableMinting() internal {
        require(mintable);
        mintable = false;
        MintingDisabled();
    }
    function enableTransfers() public onlyOwner {
        require(!transferable);
        transferable = true;
        TransfersEnabled();
    }
    function mint(address tokenOwner, uint tokens) internal {
        require(mintable);
        balances[tokenOwner] = safeAdd(balances[tokenOwner], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        Transfer(address(0), tokenOwner, tokens);
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}


// ----------------------------------------------------------------------------
// Devery Presale Token Contract
// ----------------------------------------------------------------------------
contract DeveryPresale is ERC20Token {
    address public wallet;
    // 9:00pm, 14 December GMT-5 => 02:00 15 December UTC => 13:00 15 December AEST => 1513303200
    // new Date(1513303200 * 1000).toUTCString() =>  "Fri, 15 Dec 2017 02:00:00 UTC"
    uint public constant START_DATE = 1513303200;
    bool public closed;
    uint public ethMinContribution = 20 ether;
    uint public usdCap = 2000000;
    // ETH/USD 8 Dec 2017 11:00 EST => 8 Dec 2017 16:00 UTC => 9 Dec 2017 03:00 AEST => 453.55 from CMC
    uint public usdPerKEther = 453550;
    uint public contributedEth;
    uint public contributedUsd;
    DeveryPresaleWhitelist public whitelist;
    PICOPSCertifier public picopsCertifier;

    event EthMinContributionUpdated(uint oldEthMinContribution, uint newEthMinContribution);
    event UsdCapUpdated(uint oldUsdCap, uint newUsdCap);
    event UsdPerKEtherUpdated(uint oldUsdPerKEther, uint newUsdPerKEther);
    event WhitelistUpdated(address indexed oldWhitelist, address indexed newWhitelist);
    event PICOPSCertifierUpdated(address indexed oldPICOPSCertifier, address indexed newPICOPSCertifier);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint usdAmount, uint contributedEth, uint contributedUsd);

    function DeveryPresale(address _wallet) public ERC20Token("PREVE", "Presale EVE Tokens", 18) {
        require(_wallet != address(0));
        wallet = _wallet;
    }
    function setEthMinContribution(uint _ethMinContribution) public onlyOwner {
        // require(now <= START_DATE);
        EthMinContributionUpdated(ethMinContribution, _ethMinContribution);
        ethMinContribution = _ethMinContribution;
    } 
    function setUsdCap(uint _usdCap) public onlyOwner {
        // require(now <= START_DATE);
        UsdCapUpdated(usdCap, _usdCap);
        usdCap = _usdCap;
    } 
    function setUsdPerKEther(uint _usdPerKEther) public onlyOwner {
        // require(now <= START_DATE);
        UsdPerKEtherUpdated(usdPerKEther, _usdPerKEther);
        usdPerKEther = _usdPerKEther;
    }
    function setWhitelist(address _whitelist) public onlyOwner {
        // require(now <= START_DATE);
        WhitelistUpdated(address(whitelist), _whitelist);
        whitelist = DeveryPresaleWhitelist(_whitelist);
    }
    function setPICOPSCertifier(address _picopsCertifier) public onlyOwner {
        // require(now <= START_DATE);
        PICOPSCertifierUpdated(address(picopsCertifier), _picopsCertifier);
        picopsCertifier = PICOPSCertifier(_picopsCertifier);
    }
    function addressCanContribute(address _addr) public view returns (bool) {
        return whitelist.whitelist(_addr) > 0 || picopsCertifier.certified(_addr);
    }
    function ethCap() public view returns (uint) {
        return usdCap * 10**uint(3 + 18) / usdPerKEther;
    }
    function closeSale() public onlyOwner {
        require(!closed);
        closed = true;
        disableMinting();
    }
    function () public payable {
        require(now >= START_DATE);
        require(!closed);
        require(whitelist.whitelist(msg.sender) > 0 || picopsCertifier.certified(msg.sender));
        require(msg.value >= ethMinContribution);
        uint ethAmount = msg.value;
        uint ethRefund = 0;
        if (safeAdd(contributedEth, ethAmount) > ethCap()) {
            ethAmount = safeSub(ethCap(), contributedEth);
            ethRefund = safeSub(msg.value, ethAmount);
        }
        uint usdAmount = ethAmount * usdPerKEther / 10**uint(3 + 18);
        contributedEth = safeAdd(contributedEth, ethAmount);
        contributedUsd = safeAdd(contributedUsd, usdAmount);
        mint(msg.sender, ethAmount);
        if (contributedEth >= ethCap()) {
            closed = true;
            disableMinting();
        }
        wallet.transfer(ethAmount);
        Contributed(msg.sender, ethAmount, ethRefund, usdAmount, contributedEth, contributedUsd);
        if (ethRefund > 0) {
            msg.sender.transfer(ethRefund);
        }
    }
}