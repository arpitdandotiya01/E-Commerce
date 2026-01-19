import { useState, useEffect } from "react";
import { useNavigate, Link } from "react-router-dom";
import apiClient from "../api/client";
import { useAuth } from "../context/AuthContext";

function Login() {
 const [email, setEmail] = useState("");
 const [password, setPassword] = useState("");
 const { login, token } = useAuth();
 const navigate = useNavigate();

 useEffect(() => {
   if (token) {
     navigate("/");
   }
 }, [token, navigate]);

 const handleSubmit = async (e) => {
   e.preventDefault();
  try {
    // Devise-style nested param
    const res = await apiClient.post("/login", {
      user: { email, password },
    });
    // backend returns token in response body as `token`
    const tokenValue = res.data?.token;
    if (!tokenValue) throw new Error('No token returned from server');
    login(tokenValue);
     navigate("/");
   } catch (error) {
     console.error("Login failed:", error);
     alert(error.response?.data?.error || "Invalid credentials");
   }
 };

 return (
   <form onSubmit={handleSubmit}>
     <h2>Login</h2>
     <input
       placeholder="Email"
       value={email}
       onChange={(e) => setEmail(e.target.value)}
     />
     <input
       type="password"
       placeholder="Password"
       value={password}
       onChange={(e) => setPassword(e.target.value)}
     />
     <button type="submit">Login</button>
     <p>
       Don't have an account? <Link to="/signup">Sign Up</Link>
     </p>
   </form>
 );
}

export default Login;