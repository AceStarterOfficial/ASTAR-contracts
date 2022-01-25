// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

abstract contract BPContract {
    function protect(
        address sender,
        address receiver,
        uint256 amount
    ) external virtual;
}

contract ASTARToken is AccessControl, ERC20, ERC20Snapshot, ERC20Pausable {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    bool public isInPreventBotMode;

    BPContract public BP;

    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    IUniswapV2Router02 constant public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public pairASTARBUSD;

    constructor() ERC20("Ace Starter", "ASTAR") {
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
        pairASTARBUSD = uniswapV2Factory.createPair(address(this), BUSD);

        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
        _setupRole(OWNER_ROLE, msg.sender);


        // Seed Round | Wait for Vesting Contract Address
        //        _mint(address(0), 80000000 * (10 ** decimals()));

        // Private Sale | Wait for Vesting Contract Address
        //        _mint(address(0), 140000000 * (10 ** decimals()));

        // Public Sale | Wait for Vesting Contract Address
        //        _mint(address(0), 20000000 * (10 ** decimals()));

        // Farming & Staking Rewards | Wait for Vesting Contract Address
        //        _mint(address(0), 170000000 * (10 ** decimals()));

        // Team & Advisors | Wait for Vesting Contract Address
        //        _mint(address(0), 200000000 * (10 ** decimals()));

        // Marketing | Wait for Vesting Contract Address
        //        _mint(address(0), 100000000 * (10 ** decimals()));

        // Partnerships | Wait for Vesting Contract Address
        //        _mint(address(0), 50000000 * (10 ** decimals()));

        // Liquidity Fund | Wait for Vesting Contract Address
        //        _mint(address(0), 150000000 * (10 ** decimals()));

        // Ecosystem Funds | Wait for Vesting Contract Address
        //        _mint(address(0), 90000000 * (10 ** decimals()));
    }

    /**
     * Utilities functions
     */
    function snapshot() public onlyRole(OWNER_ROLE) returns (uint) {
        return _snapshot();
    }

    function pause() public onlyRole(OWNER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(OWNER_ROLE) {
        _unpause();
    }

    function togglePreventBotMode() public onlyRole(OWNER_ROLE) {
        isInPreventBotMode = !isInPreventBotMode;
    }

    function setBPContract(address _bp) public onlyRole(OWNER_ROLE) {
        require(address(BP) == address(0), "ASTAR:: unauthorazion");
        BP = BPContract(_bp);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override(ERC20, ERC20Pausable, ERC20Snapshot) {
        if (isInPreventBotMode) {
            BP.protect(from, to, amount);
        }

        super._beforeTokenTransfer(from, to, amount);
    }
}
