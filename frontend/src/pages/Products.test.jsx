import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { vi } from 'vitest';
import Products from './Products';
import apiClient from '../api/client';
import { CartProvider } from '../context/CartContext';
import { AuthProvider } from '../context/AuthContext';

describe('Products Component', () => {
  const mockProducts = [
    { id: 1, name: 'Test Product 1', price: 100 },
    { id: 2, name: 'Test Product 2', price: 200 },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
    apiClient.get.mockImplementation((url) => {
      if (url === '/products') return Promise.resolve({ data: mockProducts });
      if (url === '/orders') return Promise.resolve({ data: [] }); // No pending orders
      return Promise.resolve({ data: {} });
    });
  });

  const renderProducts = () => {
    render(
      <BrowserRouter>
        <AuthProvider>
          <CartProvider>
            <Products />
          </CartProvider>
        </AuthProvider>
      </BrowserRouter>
    );
  };

  test('renders products list', async () => {
    renderProducts();

    await waitFor(() => {
      expect(screen.getByText(/Test Product 1/)).toBeInTheDocument();
      expect(screen.getByText(/Test Product 2/)).toBeInTheDocument();
    });
  });

  test('creates new order and adds item to cart if no order exists', async () => {
    apiClient.post.mockImplementation((url) => {
      if (url === '/orders') return Promise.resolve({ data: { id: 123 } });
      if (url.includes('/add_item')) return Promise.resolve({ data: {} });
    });

    renderProducts();
    await waitFor(() => screen.getByText(/Test Product 1/));

    const addButtons = screen.getAllByText('Add to Cart');
    fireEvent.click(addButtons[0]);

    await waitFor(() => {
      // Should create order first
      expect(apiClient.post).toHaveBeenCalledWith('/orders');
      // Then add item
      expect(apiClient.post).toHaveBeenCalledWith('/orders/123/add_item', {
        product_id: 1,
        quantity: 1,
      });
      expect(global.alert).toHaveBeenCalledWith('Added to cart successfully!');
    });
  });

  test('adds item to existing order', async () => {
    // Pre-set orderId in localStorage
    localStorage.setItem('orderId', '999');
    apiClient.post.mockResolvedValue({ data: {} });

    renderProducts();
    await waitFor(() => screen.getByText(/Test Product 1/));

    const addButtons = screen.getAllByText('Add to Cart');
    fireEvent.click(addButtons[0]);

    await waitFor(() => {
      expect(apiClient.post).not.toHaveBeenCalledWith('/orders'); // Should not create new order
      expect(apiClient.post).toHaveBeenCalledWith('/orders/999/add_item', expect.anything());
    });
  });
});