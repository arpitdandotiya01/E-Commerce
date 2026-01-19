import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { vi } from 'vitest';
import Cart from './Cart';
import apiClient from '../api/client';
import { CartProvider } from '../context/CartContext';
import { AuthProvider } from '../context/AuthContext';

describe('Cart Component', () => {
  const mockOrder = {
    id: 101,
    status: 'pending',
    total_amount: 500,
    order_items: [
      { id: 1, product: { name: 'Item A' }, price: 100, quantity: 2 },
      { id: 2, product: { name: 'Item B' }, price: 300, quantity: 1 },
    ],
  };

  beforeEach(() => {
    vi.clearAllMocks();
    // Setup default mocks
    localStorage.setItem('orderId', '101');
    apiClient.get.mockImplementation((url) => {
      if (url === '/orders/101') return Promise.resolve({ data: mockOrder });
      if (url === '/orders') return Promise.resolve({ data: [] });
      return Promise.resolve({ data: {} });
    });
  });

  const renderCart = () => {
    render(
      <BrowserRouter>
        <AuthProvider>
          <CartProvider>
            <Cart />
          </CartProvider>
        </AuthProvider>
      </BrowserRouter>
    );
  };

  test('renders cart items and total', async () => {
    renderCart();

    await waitFor(() => {
      expect(screen.getByText(/Item A/)).toBeInTheDocument();
      expect(screen.getByText(/Item B/)).toBeInTheDocument();
      expect(screen.getByText(/Total: ₹500/)).toBeInTheDocument();
    });
  });

  test('handles remove item', async () => {
    apiClient.delete.mockResolvedValue({});
    // Mock get to return updated order after delete
    apiClient.get.mockResolvedValueOnce({ data: mockOrder }) // Initial load
           .mockResolvedValueOnce({ data: { ...mockOrder, order_items: [] } }); // After delete

    renderCart();
    await waitFor(() => screen.getByText(/Item A/));

    const removeButtons = screen.getAllByText('Remove');
    fireEvent.click(removeButtons[0]);

    await waitFor(() => {
      expect(apiClient.delete).toHaveBeenCalledWith('/orders/101/remove_item', { params: { item_id: 1 } });
    });
  });

  test('handles update quantity', async () => {
    apiClient.patch.mockResolvedValue({});
    
    renderCart();
    await waitFor(() => screen.getByText(/Item A/));

    const plusButtons = screen.getAllByText('+');
    fireEvent.click(plusButtons[0]); // Increase Item A (id: 1)

    await waitFor(() => {
      expect(apiClient.patch).toHaveBeenCalledWith('/orders/101/update_item', { item_id: 1, quantity: 3 });
    });
  });

  test('handles checkout success', async () => {
    apiClient.post.mockResolvedValue({ 
      data: { order_id: 101, total_amount: 500 } 
    });

    renderCart();
    await waitFor(() => screen.getByText('Checkout'));

    fireEvent.click(screen.getByText('Checkout'));

    await waitFor(() => {
      expect(apiClient.post).toHaveBeenCalledWith('/orders/101/checkout');
      expect(screen.getByText(/Order #101 placed successfully/)).toBeInTheDocument();
      expect(screen.getByText('Your cart is empty')).toBeInTheDocument();
    });
  });

  test('handles checkout failure', async () => {
    apiClient.post.mockRejectedValue({ 
      response: { data: { error: 'Payment failed' } } 
    });

    renderCart();
    await waitFor(() => screen.getByText('Checkout'));

    fireEvent.click(screen.getByText('Checkout'));

    await waitFor(() => {
      expect(screen.getByText('Payment failed')).toBeInTheDocument();
    });
  });

  test('renders empty cart state', async () => {
    localStorage.removeItem('orderId');
    renderCart();

    await waitFor(() => {
      expect(screen.getByText('Your cart is empty')).toBeInTheDocument();
    });
  });
});