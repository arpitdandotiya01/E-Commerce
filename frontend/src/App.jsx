import apiClient from "./api/client";
import { useEffect } from "react";

function App() {
  useEffect(() => {
    apiClient
      .get("/products")
      .then((response) => {
        console.log("Products:", response.data);
      })
      .catch((error) => {
        console.error("Error fetching products:", error);
      });
  }, []);

  return <div className="App">E-Commerce App</div>;
}

export default App;