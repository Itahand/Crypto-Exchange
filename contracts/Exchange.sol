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

    // Orders mappings
    mapping(uint256 => _Order) public orders;
    mapping(uint256 => bool) public orderCancelled;
    mapping(uint256 => bool) public orderFilled;

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
    event Cancel(
      uint256 id,
      address user,
      address tokenGet,
      uint256 amountGet,
      address tokenGive,
      uint256 amountGive,
      uint256 timestamp
    );
    event Swap(
      uint256 id,
      address user,
      address tokenGet,
      uint256 amountGet,
      address tokenGive,
      uint256 amountGive,
      address creator,
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
        ordersCount++;
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

    function cancelOrder(uint256 _id)
    public
    {
      // Fetching the order
      _Order storage _order = orders[_id];
      // Ensure the caller of the function is the owner of the order
      require(address(_order.user) == msg.sender);
      // Order must exists
      require(_order.id == _id);
      // Cancel the order
      orderCancelled[_id] = true;


      emit  Cancel(
        _order.id,
        msg.sender,
        _order.tokenGet,
        _order.amountGet,
        _order.tokenGive,
        _order.amountGive,
        block.timestamp
      );
    }

    // Executing Orders

    function fillOrder(uint256 _id)
    public
    {
      // Must be valid orderId
      require(_id > 0 && _id <= ordersCount, 'Order does not exist');
      // Order can't be filled
      require(!orderFilled[_id]);
      // Order can't be cancelled
      require(!orderCancelled[_id]);
      // Fetch order
      _Order storage _order = orders[_id];

      // Swap tokens
      _swap(
        _order.id,
        _order.user,
        _order.tokenGet,
        _order.amountGet,
        _order.tokenGive,
        _order.amountGive
      );

      // Mark order as filled
      orderFilled[_order.id] = true;
    }

    function _swap(
      uint256 _orderId,
      address _user,
      address _tokenGet,
      uint256 _amountGet,
      address _tokenGive,
      uint256 _amountGive
    )
    internal
    {
      // Fee is paid by the user who filled the order (msg.sender)
      // Fee is deducted from _amountGet
      uint256 _feeAmount = (_amountGet * feePercent) / 100;

      // Swap functionality
      // msg.sender filled the order; _user created it

      // Take token2 from user2 and give it to user1
      tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender] - (_amountGet + _feeAmount);
      tokens[_tokenGet][_user] = tokens[_tokenGet][_user] + _amountGet;

      // Charge fees
      tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount] + _feeAmount;

      // Take token1 from user1 and give it to user2
      tokens[_tokenGive][_user] = tokens[_tokenGive][_user] - _amountGive;
      tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender] + _amountGive;

      emit Swap(
        _orderId,
        msg.sender,
        _tokenGet,
        _amountGet,
        _tokenGive,
        _amountGive,
        _user,
        block.timestamp
      );
    }
}
