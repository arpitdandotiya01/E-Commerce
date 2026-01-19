import { useEffect, useState } from "react";
import apiClient from "../api/client";
import LogoutButton from "../components/LogoutButton";
import { useCart } from "../context/CartContext";
import { useAuth } from "../context/AuthContext";
import { Link } from "react-router-dom";

function Products() {
 const [products, setProducts] = useState([]);
 const { orderId, setCartOrder } = useCart();
 const { isAdmin } = useAuth();

 const fetchProducts = () => {
   apiClient.get("/products").then((res) => {
     setProducts(res.data);
   });
 };

 useEffect(() => {
   fetchProducts();
 }, []);

 const handleAddToCart = async (productId) => {
   try {
     let currentOrderId = orderId;
     // 1️⃣ Create order if not exists
     if (!currentOrderId) {
       const res = await apiClient.post("/orders");
       currentOrderId = res.data.id;
       setCartOrder(currentOrderId);
     }
     // 2️⃣ Add item to order
     await apiClient.post(`/orders/${currentOrderId}/add_item`, {
       product_id: productId,
       quantity: 1,
     });
     alert("Added to cart successfully!");
   } catch (error) {
     console.error("Error adding to cart:", error);
     if (error.response && error.response.data && error.response.data.error) {
       alert(`Error: ${error.response.data.error}`);
     } else {
       alert("Failed to add item to cart. Please try again.");
     }
   }
 };

 const handleAddProduct = async () => {
    const name = prompt("Enter product name:");
    const price = prompt("Enter product price:");
    const stock = prompt("Enter initial stock quantity:");
    if (name && price && stock) {
      try {
        await apiClient.post("/products", { product: { name, price, stock_quantity: stock, active: true } });
        fetchProducts();
      } catch (e) {
        alert("Failed to create product. Ensure you are an admin.");
      }
    }
 };

 const handleEditProduct = async (product) => {
    const newPrice = prompt("Enter new price:", product.price);
    const newStock = prompt("Enter new stock quantity:", product.stock_quantity);
    if (newPrice !== null && newStock !== null) {
      try {
        await apiClient.put(`/products/${product.id}`, { product: { price: newPrice, stock_quantity: newStock } });
        fetchProducts();
      } catch (e) {
        alert("Failed to update product. Ensure you are an admin.");
      }
    }
 };

 const handleDeleteProduct = async (id) => {
    if (confirm("Are you sure you want to delete this product?")) {
      try {
        await apiClient.delete(`/products/${id}`);
        fetchProducts();
      } catch (e) {
        alert("Failed to delete product. Ensure you are an admin.");
      }
    }
 };

 return (
<>
<Link to ="/cart">Go to Cart</Link>
<LogoutButton />
<h2>Products</h2>
{isAdmin && (
  <div style={{ margin: '20px 0', padding: '10px', border: '2px solid blue' }}>
    <h3>Admin Controls</h3>
    <button onClick={handleAddProduct}>+ Add New Product</button>
  </div>
)}
<ul>
       {products.map((p) => (
<li key={p.id}>
 <Link to={`/products/${p.id}`}>
             {p.name} — ₹{p.price} — Stock: {p.stock_quantity}
 </Link>
<button onClick={() => handleAddToCart(p.id)}>
             Add to Cart
</button>
{isAdmin && (
  <>
    <button onClick={() => handleEditProduct(p)} style={{ marginLeft: '10px' }}>Edit</button>
    <button onClick={() => handleDeleteProduct(p.id)} style={{ marginLeft: '5px', color: 'red' }}>Delete</button>
  </>
)}
</li>
       ))}
</ul>
</>
 );
}
export default Products;