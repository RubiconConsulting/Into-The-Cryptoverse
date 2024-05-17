// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

contract GameToken is ERC20,Ownable(msg.sender) {
    constructor() ERC20("CrytoverseToken", "GTK") {
        _mint(msg.sender, 1000000 * 1e18);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}