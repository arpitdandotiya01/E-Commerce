import { createContext, useContext, useState } from "react";

const CartContext = createContext(null);

export const CartProvider = ({ children }) => {

  const [orderId, setOrderId] = useState(

    localStorage.getItem("orderId")

  );

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
 