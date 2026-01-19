import { createContext, useContext, useState, useEffect } from "react";
import apiClient from "../api/client";
import { useAuth } from "./AuthContext";

const CartContext = createContext(null);

export const CartProvider = ({ children }) => {
  const { token } = useAuth();
  const [orderId, setOrderId] = useState(
    localStorage.getItem("orderId")
  );

  // Restore cart from existing pending order when token is available but no orderId
  useEffect(() => {
    const storedOrderId = localStorage.getItem("orderId");

    if (token && !storedOrderId) {
      console.log("Restoring cart - no stored orderId, checking for existing orders...");
      // Try to find existing pending order
      apiClient.get("/orders")
        .then((res) => {
          console.log("Orders response:", res.data);
          const pendingOrders = res.data.filter(order => order.status === "pending");
          console.log("Pending orders:", pendingOrders);
          if (pendingOrders.length > 0) {
            // Use the most recent pending order
            const latestOrder = pendingOrders.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))[0];
            console.log("Restoring cart with order:", latestOrder.id);
            setCartOrder(latestOrder.id);
          } else {
            console.log("No pending orders found");
          }
        })
        .catch((error) => {
          console.error("Error restoring cart:", error);
        });
    } else {
      console.log("Cart restoration skipped - token:", !!token, "storedOrderId:", storedOrderId);
    }
  }, [token]); // Re-run when token changes

  const setCartOrder = (id) => {
    localStorage.setItem("orderId", id);
    setOrderId(id);
  };

  const clearCart = () => {
    localStorage.removeItem("orderId");
    setOrderId(null);
  };

  return (
<CartContext.Provider value={{ orderId, setCartOrder, clearCart }}>

      {children}
</CartContext.Provider>

  );

};

// eslint-disable-next-line react-refresh/only-export-components
export const useCart = () => useContext(CartContext);
 