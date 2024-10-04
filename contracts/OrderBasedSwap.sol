// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OrderBasedSwap {

        address public owner;
        address public TobiXItoken;
        address public TOBWeb3token;
        uint256 public orderCount;        


   
   constructor (address _TobiXItoken, address _TOBWeb3token) {
        owner  = msg.sender;
        TobiXItoken = _TobiXItoken;
        TOBWeb3token = _TOBWeb3token;
    }
   
   
    struct Order {
        address seller;
        address tokenAddress;         // Token being sold
        uint256 tokenAmount;          // Amount of the token being sold
        address paymentTokenAddress;  // Token used for payment
        uint256 price;                // Price in the payment token
        bool isActive;                // Whether the order is active
    }

    mapping (uint256 => Order) public orders;
    // Auto-incremented order ID
   
    // Event to emit OrderCreated
    event OrderCreated(uint256 orderId, address seller, address tokenAddress, uint256 tokenAmount, address paymentTokenAddress, uint256 price);
    // Event to emit OrderFilled
    event OrderFilled(uint256 orderId, address buyer);
    // Event to emit OrderCancelled
    event OrderCancelled(uint256 orderId);


    // Create a new order to sell tokens
    function createOrder(
        address _tokenAddress,
        uint256 _tokenAmount,
        address _paymentTokenAddress,
        uint256 _price
    ) external {
        require(_tokenAmount > 0, "Amount must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        // Transfer the token being sold to the contract
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount);

        // Create a new order and store it
        orders[orderCount] = Order({
            seller: msg.sender,
            tokenAddress: _tokenAddress,
            tokenAmount: _tokenAmount,
            paymentTokenAddress: _paymentTokenAddress,
            price: _price,
            isActive: true
        });

        emit OrderCreated(orderCount, msg.sender, _tokenAddress, _tokenAmount, _paymentTokenAddress, _price);

        orderCount++;  // Increment the order ID for next order
    }

   
   
    // Function for buyers to purchase tokens from an order
    function purchaseOrder(uint256 _orderId) external {
        Order storage order = orders[_orderId];
        require(order.isActive, "Order is not active");
        require(order.tokenAmount > 0, "No tokens left to purchase");

        // Transfer payment token from the buyer to the seller
        IERC20(order.paymentTokenAddress).transferFrom(msg.sender, order.seller, order.price);

        // Transfer the sold token from the contract to the buyer
        IERC20(order.tokenAddress).transfer(msg.sender, order.tokenAmount);

        // Mark the order as inactive
        order.isActive = false;

        emit OrderFilled(_orderId, msg.sender);
    }

    // Cancel an order and refund the tokens to the owner
    function cancelOrder(uint256 _orderId) external {
        Order storage order = orders[_orderId];
        require(msg.sender == order.seller, "Only the owner can cancel the order");
        require(!order.isActive, "Order is not active");

        // Transfer the token back to the owner
        IERC20(order.tokenAddress).transfer(order.seller, order.tokenAmount);

        // Mark the order as inactive
        order.isActive = false;

        emit OrderCancelled(_orderId);
    }

    // Helper function to view order details
    function getOrder(uint256 _orderId) external view returns (Order memory) {
        return orders[_orderId];
    }
}