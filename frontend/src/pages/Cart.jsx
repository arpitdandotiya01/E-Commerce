import { useEffect, useState } from "react";
import apiClient from "../api/client";
import { useCart } from "../context/CartContext";
import LogoutButton from "../components/LogoutButton";

function Cart() {
 const { orderId, clearCart } = useCart();
 const [order, setOrder] = useState(null);
 const [checkoutLoading, setCheckoutLoading] = useState(false);
 const [checkoutMessage, setCheckoutMessage] = useState("");

 console.log('Current orderId:', orderId);
 console.log('Order state:', order);
 useEffect(() => {
   if (!orderId) return;
   apiClient
     .get(`/orders/${orderId}`)
     .then((res) => {
       console.log('Order data:', res.data);
       setOrder(res.data);
     })
     .catch((error) => {
       console.error('Error fetching order:', error);
       // If order not found on backend, clear it from local storage
       if (error.response && error.response.status === 404) {
         clearCart();
       }
       setOrder(null); // Stop showing loading state
     });
 }, [orderId]);

 const handleCheckout = async () => {
   if (!orderId) return;

   setCheckoutLoading(true);
   setCheckoutMessage("");

   try {
     const response = await apiClient.post(`/orders/${orderId}/checkout`);
     console.log('Checkout response:', response.data);

     setCheckoutMessage(`Order #${response.data.order_id} placed successfully! Total: ₹${response.data.total_amount}`);

     // Clear the cart after successful checkout
     clearCart();

     // Reset local state
     setOrder(null);

   } catch (error) {
     console.error('Checkout error:', error);
     setCheckoutMessage(error.response?.data?.error || "Checkout failed. Please try again.");
   } finally {
     setCheckoutLoading(false);
   }
 };

 const handleRemoveItem = async (itemId) => {
   try {
    // Call the backend member route with params object
    await apiClient.delete(`/orders/${orderId}/remove_item`, { params: { item_id: itemId } });
     const res = await apiClient.get(`/orders/${orderId}`);
     setOrder(res.data);
   } catch (error) {
     console.error("Error removing item:", error);
     alert(error.response?.data?.error || "Failed to remove item.");
   }
 };

 const handleUpdateQuantity = async (itemId, newQuantity) => {
   try {
    // Backend expects item_id and quantity in the payload for update_item
    await apiClient.patch(`/orders/${orderId}/update_item`, {
      item_id: itemId,
      quantity: newQuantity,
    });
     const res = await apiClient.get(`/orders/${orderId}`);
     setOrder(res.data);
   } catch (error) {
     console.error("Error updating quantity:", error);
     alert("Failed to update quantity.");
   }
 };

 if (!orderId) {
   return (
<>
<LogoutButton />
<h2>Your cart is empty</h2>
{checkoutMessage && (
  <p style={{ color: checkoutMessage.includes('successfully') ? 'green' : 'red' }}>
    {checkoutMessage}
  </p>
)}
</>
   );
 }
 if (!order) {
   return <p>Loading cart...</p>;
 }

 // Handle case where order is already completed
 if (order.status !== 'pending') {
    return (
      <>
        <LogoutButton />
        <h2>Order #{order.id} is {order.status}</h2>
        <p>This order has been completed and can no longer be modified.</p>
        <button onClick={() => { clearCart(); setOrder(null); }}>Start New Order</button>
      </>
    );
 }

 return (
<>
<LogoutButton />
<h2>Your Cart</h2>
{order.order_items && order.order_items.length > 0 ? (
<ul>
       {order.order_items.map((item) => (
<li key={item.id}>
           {item.product ? item.product.name : 'Unknown Product'} — ₹{item.price}
 <br />
           Qty: {item.quantity}
 <button onClick={() => handleUpdateQuantity(item.id, item.quantity - 1)} disabled={item.quantity <= 1}>-</button>
 <button onClick={() => handleUpdateQuantity(item.id, item.quantity + 1)}>+</button>
 <button
 onClick={() => handleRemoveItem(item.id)}
 style={{ marginLeft: "10px" }}
 >
             Remove
 </button>
</li>
       ))}
</ul>
) : (
<p>No items in cart</p>
)}
<h3>Total: ₹{order.total_amount}</h3>
{order.order_items && order.order_items.length > 0 && (
  <button onClick={handleCheckout} disabled={checkoutLoading}>
    {checkoutLoading ? 'Processing...' : 'Checkout'}
  </button>
)}
{checkoutMessage && (
  <p style={{ color: checkoutMessage.includes('successfully') ? 'green' : 'red' }}>
    {checkoutMessage}
  </p>
)}
</>
 );
}
export default Cart;