import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useCart } from "../context/CartContext";

function LogoutButton() {
  const { logout } = useAuth();
  const { clearCart } = useCart();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    clearCart();
    navigate("/login");
  };

  return <button onClick={handleLogout}>Logout</button>;
}

export default LogoutButton;