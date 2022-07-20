//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    uint256 public ordersCount;

    // Tokens mapping
    mapping(address => mapping(address => uint256)) public tokens;

    // Orders mapping
    mapping(uint256 => _Order) public orders;

    // Events

    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event Order(
      uint256 id,
      address user,
      address tokenGet,
      uint256 amountGet,
      address tokenGive,
      uint256 amountGive,
      uint256 timestamp
    );

    // Orders database

    struct _Order {
      // Attributes of an order
      uint256 id; // Unique identifier for order
      address user; // Who made the order
      address tokenGet;
      uint256 amountGet;
      address tokenGive;
      uint256 amountGive;
      uint256 timestamp;
    }

    constructor(address _feeAccount, uint256 _feePercent) {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }


    // ------------------------
    // DEPOSIT & WITHDRAW TOKEN

    function depositToken(address _token, uint256 _amount) public {
        // Transfer tokens to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));

        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount;

        // Emit an event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function withdrawToken(address _token, uint256 _amount)
    public
    {
      require(tokens[_token][msg.sender] >= _amount);
      Token(_token).transfer(msg.sender, _amount);
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);

    }

    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
    {
        return tokens[_token][_user];
    }

    // Make and Cancel orders.

    function makeOrder(
      address _tokenGet,
      uint256 _amountGet,
      address _tokenGive,
      uint256 _amountGive
      ) public
      {
        // Cancel if the token isn't in the exchange
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

        // Make the order
        ordersCount = ordersCount + 1;
        orders[ordersCount] = _Order(
          ordersCount, // id
          msg.sender, // user
          _tokenGet,
          _amountGet,
          _tokenGive,
          _amountGive,
          block.timestamp
        );
        emit Order(ordersCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, block.timestamp);
      }

}
