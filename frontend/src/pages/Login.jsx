import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
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
     const res = await apiClient.post("/login", {
       user: { email, password },
     });
     login(res.data.token);
     navigate("/");
   } catch {
     alert("Invalid credentials");
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
   </form>
 );
}

export default Login;