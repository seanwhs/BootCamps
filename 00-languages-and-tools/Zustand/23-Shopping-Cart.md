# Part 6 — Production Patterns

## Section 23: Shopping Cart

E-commerce applications rely heavily on a well-designed shopping cart system. From adding items and updating quantities to handling inventory and offline synchronization, the shopping cart is a perfect example of Zustand's capabilities. In this section, you'll build a production-ready shopping cart with offline support, optimistic updates, and real-time inventory management.

---

## The Target: Production-Ready Shopping Cart

By the end of this section, you'll be able to:
- Manage cart state with add, remove, update quantity, and clear operations
- Validate inventory and prevent overselling
- Calculate totals, subtotals, taxes, and shipping costs
- Implement offline support with queued actions
- Apply optimistic updates for a responsive UI
- Persist cart across sessions
- Integrate with a checkout flow

---

## The Concept: Shopping Cart as a State Machine

Think of the shopping cart like a **physical shopping basket** with rules:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SHOPPING CART SYSTEM                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Cart State                                             │  │
│  │  • items: [{ productId, quantity, price, ... }]        │  │
│  │  • subtotal, tax, shipping, total                       │  │
│  │  • coupon code, discount amount                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Actions                                                │  │
│  │  • Add item (check inventory)                           │  │
│  │  • Remove item                                          │  │
│  │  • Update quantity                                      │  │
│  │  • Apply coupon                                         │  │
│  │  • Clear cart                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Business Rules                                         │  │
│  │  • Cannot add more than stock                           │  │
│  │  • Minimum order amount                                 │  │
│  │  • Free shipping threshold                              │  │
│  │  • Coupon validation                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Implementation: Shopping Cart Store

### Step 1: Define Types

```typescript
// src/types/cart.types.ts
export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  image?: string;
  category: string;
  stock: number; // Available inventory
  maxPerOrder?: number; // Maximum allowed per order
  weight?: number; // For shipping calculations
  dimensions?: { width: number; height: number; depth: number };
}

export interface CartItem {
  productId: string;
  product: Product; // Snapshot at time of addition
  quantity: number;
  addedAt: Date;
}

export interface Cart {
  id: string;
  items: CartItem[];
  subtotal: number;
  tax: number;
  shippingCost: number;
  discount: number;
  total: number;
  couponCode?: string;
  couponDiscount?: number;
  currency: string;
  updatedAt: Date;
}

export interface Coupon {
  code: string;
  type: 'percentage' | 'fixed';
  value: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  expiresAt?: Date;
  validProducts?: string[]; // Product IDs this coupon applies to
  validCategories?: string[]; // Categories this coupon applies to
}

export interface ShippingOption {
  id: string;
  name: string;
  cost: number;
  estimatedDays: number;
  method: 'standard' | 'express' | 'overnight';
}
```

### Step 2: Create the Shopping Cart Store

```typescript
// src/store/cartStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import { Cart, CartItem, Product, Coupon, ShippingOption } from '../types/cart.types';

interface CartStore {
  // State
  cart: Cart | null;
  selectedShippingOption: ShippingOption | null;
  coupon: Coupon | null;
  isLoading: boolean;
  error: string | null;
  isSyncing: boolean;
  offlineQueue: { type: string; payload: any }[];

  // Cart operations
  addItem: (product: Product, quantity?: number) => Promise<void>;
  removeItem: (productId: string) => Promise<void>;
  updateQuantity: (productId: string, quantity: number) => Promise<void>;
  clearCart: () => Promise<void>;
  
  // Inventory checks
  validateInventory: (productId: string, quantity: number) => Promise<boolean>;
  getAvailableStock: (productId: string) => number;
  
  // Calculations
  calculateTotals: () => void;
  calculateSubtotal: () => number;
  calculateTax: () => number;
  calculateShipping: () => number;
  calculateDiscount: () => number;
  calculateTotal: () => number;

  // Coupon operations
  applyCoupon: (code: string) => Promise<void>;
  removeCoupon: () => void;
  validateCoupon: (code: string) => Promise<Coupon | null>;

  // Shipping operations
  setShippingOption: (option: ShippingOption) => void;
  getShippingOptions: () => Promise<ShippingOption[]>;

  // Persistence and sync
  syncCart: () => Promise<void>;
  queueAction: (type: string, payload: any) => void;
  processQueue: () => Promise<void>;

  // Utility
  getItemCount: () => number;
  getItemQuantity: (productId: string) => number;
  isInCart: (productId: string) => boolean;
  clearError: () => void;
}

// Initial state
const initialState = {
  cart: null,
  selectedShippingOption: null,
  coupon: null,
  isLoading: false,
  error: null,
  isSyncing: false,
  offlineQueue: [],
};

// Tax rate (could come from configuration)
const TAX_RATE = 0.1; // 10%
const FREE_SHIPPING_THRESHOLD = 100; // Free shipping over $100
const SHIPPING_COST = 5.99;

export const useCartStore = create<CartStore>()(
  persist(
    immer((set, get) => ({
      ...initialState,

      // --- Add Item ---
      addItem: async (product: Product, quantity: number = 1) => {
        set({ isLoading: true, error: null });
        
        try {
          // Validate inventory
          const available = await get().validateInventory(product.id, quantity);
          if (!available) {
            throw new Error(`Not enough stock for ${product.name}`);
          }

          // Check if item already exists
          const existingItem = get().cart?.items.find(
            item => item.productId === product.id
          );

          if (existingItem) {
            // Update quantity
            await get().updateQuantity(product.id, existingItem.quantity + quantity);
          } else {
            // Add new item
            set((state) => {
              if (!state.cart) {
                // Create new cart
                state.cart = {
                  id: `cart-${Date.now()}`,
                  items: [],
                  subtotal: 0,
                  tax: 0,
                  shippingCost: 0,
                  discount: 0,
                  total: 0,
                  currency: product.currency || 'USD',
                  updatedAt: new Date(),
                };
              }

              const newItem: CartItem = {
                productId: product.id,
                product: { ...product },
                quantity,
                addedAt: new Date(),
              };

              state.cart.items.push(newItem);
              state.cart.updatedAt = new Date();

              // Recalculate totals
              get().calculateTotals();
            });
          }

          set({ isLoading: false });
          
          // Queue sync if offline
          if (!navigator.onLine) {
            get().queueAction('addItem', { productId: product.id, quantity });
          }
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to add item',
          });
          throw error;
        }
      },

      // --- Remove Item ---
      removeItem: async (productId: string) => {
        set({ isLoading: true, error: null });

        try {
          set((state) => {
            if (!state.cart) return;
            state.cart.items = state.cart.items.filter(
              item => item.productId !== productId
            );
            state.cart.updatedAt = new Date();
            get().calculateTotals();
          });

          set({ isLoading: false });

          if (!navigator.onLine) {
            get().queueAction('removeItem', { productId });
          }
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to remove item',
          });
          throw error;
        }
      },

      // --- Update Quantity ---
      updateQuantity: async (productId: string, quantity: number) => {
        if (quantity < 0) return;
        if (quantity === 0) {
          await get().removeItem(productId);
          return;
        }

        set({ isLoading: true, error: null });

        try {
          // Validate inventory
          const available = await get().validateInventory(productId, quantity);
          if (!available) {
            throw new Error('Not enough stock for this quantity');
          }

          set((state) => {
            if (!state.cart) return;
            
            const item = state.cart.items.find(
              item => item.productId === productId
            );
            if (item) {
              item.quantity = quantity;
              state.cart.updatedAt = new Date();
              get().calculateTotals();
            }
          });

          set({ isLoading: false });

          if (!navigator.onLine) {
            get().queueAction('updateQuantity', { productId, quantity });
          }
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to update quantity',
          });
          throw error;
        }
      },

      // --- Clear Cart ---
      clearCart: async () => {
        set({ isLoading: true, error: null });

        try {
          set((state) => {
            if (state.cart) {
              state.cart.items = [];
              state.cart.updatedAt = new Date();
              state.cart.subtotal = 0;
              state.cart.tax = 0;
              state.cart.shippingCost = 0;
              state.cart.discount = 0;
              state.cart.total = 0;
            }
          });

          set({ isLoading: false });

          if (!navigator.onLine) {
            get().queueAction('clearCart', {});
          }
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to clear cart',
          });
          throw error;
        }
      },

      // --- Inventory Validation ---
      validateInventory: async (productId: string, quantity: number): Promise<boolean> => {
        // In production, this would call an API
        // For now, use the product's stock from the store
        const state = get();
        const item = state.cart?.items.find(i => i.productId === productId);
        const productStock = item?.product.stock || 0;
        
        // Check if we have enough stock
        if (quantity > productStock) {
          return false;
        }

        // Check max per order
        const maxPerOrder = item?.product.maxPerOrder;
        if (maxPerOrder && quantity > maxPerOrder) {
          return false;
        }

        return true;
      },

      // --- Get Available Stock ---
      getAvailableStock: (productId: string): number => {
        const state = get();
        const item = state.cart?.items.find(i => i.productId === productId);
        
        // If item not in cart, return product stock
        if (!item) return 0;
        
        // Return remaining stock based on product stock minus current quantity
        return Math.max(0, (item.product.stock || 0) - item.quantity);
      },

      // --- Calculate Subtotal ---
      calculateSubtotal: (): number => {
        const state = get();
        if (!state.cart) return 0;
        
        return state.cart.items.reduce(
          (sum, item) => sum + (item.product.price * item.quantity),
          0
        );
      },

      // --- Calculate Tax ---
      calculateTax: (): number => {
        const subtotal = get().calculateSubtotal();
        // In production, tax calculation could be more complex
        return subtotal * TAX_RATE;
      },

      // --- Calculate Shipping ---
      calculateShipping: (): number => {
        const state = get();
        const subtotal = get().calculateSubtotal();
        
        // Free shipping if over threshold
        if (subtotal >= FREE_SHIPPING_THRESHOLD) {
          return 0;
        }
        
        // Use selected shipping option or default
        if (state.selectedShippingOption) {
          return state.selectedShippingOption.cost;
        }
        
        return SHIPPING_COST;
      },

      // --- Calculate Discount ---
      calculateDiscount: (): number => {
        const state = get();
        if (!state.coupon) return 0;
        
        const subtotal = state.cart?.subtotal || 0;
        const coupon = state.coupon;
        
        // Check minimum order amount
        if (coupon.minOrderAmount && subtotal < coupon.minOrderAmount) {
          return 0;
        }
        
        let discount = 0;
        if (coupon.type === 'percentage') {
          discount = subtotal * (coupon.value / 100);
          // Check max discount
          if (coupon.maxDiscount && discount > coupon.maxDiscount) {
            discount = coupon.maxDiscount;
          }
        } else {
          // Fixed amount
          discount = Math.min(coupon.value, subtotal);
        }
        
        return discount;
      },

      // --- Calculate Total ---
      calculateTotal: (): number => {
        const subtotal = get().calculateSubtotal();
        const tax = get().calculateTax();
        const shipping = get().calculateShipping();
        const discount = get().calculateDiscount();
        
        return subtotal + tax + shipping - discount;
      },

      // --- Calculate Totals (update cart) ---
      calculateTotals: () => {
        set((state) => {
          if (!state.cart) return;
          
          state.cart.subtotal = get().calculateSubtotal();
          state.cart.tax = get().calculateTax();
          state.cart.shippingCost = get().calculateShipping();
          state.cart.discount = get().calculateDiscount();
          state.cart.total = get().calculateTotal();
          state.cart.updatedAt = new Date();
        });
      },

      // --- Apply Coupon ---
      applyCoupon: async (code: string) => {
        set({ isLoading: true, error: null });

        try {
          const coupon = await get().validateCoupon(code);
          
          if (!coupon) {
            throw new Error('Invalid coupon code');
          }

          set({ coupon });
          get().calculateTotals();
          set({ isLoading: false });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Invalid coupon',
          });
          throw error;
        }
      },

      // --- Remove Coupon ---
      removeCoupon: () => {
        set({ coupon: null });
        get().calculateTotals();
      },

      // --- Validate Coupon ---
      validateCoupon: async (code: string): Promise<Coupon | null> => {
        // In production, this would call an API
        // Mock coupon validation
        const coupons: Coupon[] = [
          {
            code: 'SAVE10',
            type: 'percentage',
            value: 10,
            minOrderAmount: 50,
            maxDiscount: 20,
          },
          {
            code: 'SAVE20',
            type: 'fixed',
            value: 20,
            minOrderAmount: 100,
          },
          {
            code: 'FREESHIP',
            type: 'percentage',
            value: 0, // Special handling for free shipping
          },
        ];

        const found = coupons.find(c => c.code === code.toUpperCase());
        return found || null;
      },

      // --- Shipping ---
      setShippingOption: (option: ShippingOption) => {
        set({ selectedShippingOption: option });
        get().calculateTotals();
      },

      getShippingOptions: async (): Promise<ShippingOption[]> => {
        // In production, this would call an API
        return [
          {
            id: 'standard',
            name: 'Standard Shipping',
            cost: 5.99,
            estimatedDays: 5,
            method: 'standard',
          },
          {
            id: 'express',
            name: 'Express Shipping',
            cost: 12.99,
            estimatedDays: 2,
            method: 'express',
          },
          {
            id: 'overnight',
            name: 'Overnight Shipping',
            cost: 24.99,
            estimatedDays: 1,
            method: 'overnight',
          },
        ];
      },

      // --- Offline Queue ---
      queueAction: (type: string, payload: any) => {
        set((state) => {
          state.offlineQueue.push({ type, payload });
        });
      },

      processQueue: async () => {
        const state = get();
        if (state.isSyncing || state.offlineQueue.length === 0 || navigator.onLine) {
          return;
        }

        set({ isSyncing: true });

        while (state.offlineQueue.length > 0) {
          const action = state.offlineQueue[0];
          try {
            switch (action.type) {
              case 'addItem':
                // Re-add the item
                const product = state.cart?.items.find(
                  i => i.productId === action.payload.productId
                )?.product;
                if (product) {
                  await state.addItem(product, action.payload.quantity);
                }
                break;
              case 'removeItem':
                await state.removeItem(action.payload.productId);
                break;
              case 'updateQuantity':
                await state.updateQuantity(
                  action.payload.productId,
                  action.payload.quantity
                );
                break;
              case 'clearCart':
                await state.clearCart();
                break;
            }
            
            // Remove from queue on success
            set((state) => {
              state.offlineQueue.shift();
            });
          } catch (error) {
            console.error('Queue processing error:', error);
            // If retry fails, skip to next item
            set((state) => {
              state.offlineQueue.shift();
            });
          }
        }

        set({ isSyncing: false });
      },

      // --- Sync Cart ---
      syncCart: async () => {
        const state = get();
        if (!state.cart) return;

        set({ isLoading: true, error: null });

        try {
          // In production, this would save to a server
          await fetch('/api/cart', {
            method: 'POST',
            body: JSON.stringify(state.cart),
            headers: { 'Content-Type': 'application/json' },
          });
          set({ isLoading: false });
        } catch (error) {
          // If offline, queue the sync
          if (!navigator.onLine) {
            state.queueAction('syncCart', state.cart);
          }
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Sync failed',
          });
        }
      },

      // --- Utilities ---
      getItemCount: (): number => {
        const state = get();
        if (!state.cart) return 0;
        return state.cart.items.reduce((sum, item) => sum + item.quantity, 0);
      },

      getItemQuantity: (productId: string): number => {
        const state = get();
        if (!state.cart) return 0;
        const item = state.cart.items.find(i => i.productId === productId);
        return item?.quantity || 0;
      },

      isInCart: (productId: string): boolean => {
        const state = get();
        if (!state.cart) return false;
        return state.cart.items.some(i => i.productId === productId);
      },

      clearError: () => {
        set({ error: null });
      },
    })),
    {
      name: 'cart-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        cart: state.cart,
        coupon: state.coupon,
        selectedShippingOption: state.selectedShippingOption,
        offlineQueue: state.offlineQueue,
        // Don't persist: isLoading, error, isSyncing
      }),
    }
  )
);
```

### Step 3: Shopping Cart React Component

```tsx
// src/components/ShoppingCart.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { useCartStore } from '../store/cartStore';
import { Product } from '../types/cart.types';

// Separate component for cart items to prevent full re-renders
const CartItem = ({ productId, onUpdate, onRemove }: { 
  productId: string;
  onUpdate: (productId: string, quantity: number) => void;
  onRemove: (productId: string) => void;
}) => {
  const item = useCartStore((state) => 
    state.cart?.items.find(i => i.productId === productId)
  );
  
  if (!item) return null;
  
  const { product, quantity } = item;
  
  return (
    <div className="flex items-center gap-4 p-4 border-b">
      <img 
        src={product.image || '/placeholder.png'} 
        alt={product.name}
        className="w-20 h-20 object-cover rounded"
      />
      <div className="flex-1">
        <h3 className="font-semibold">{product.name}</h3>
        <p className="text-sm text-gray-600">${product.price.toFixed(2)}</p>
      </div>
      <div className="flex items-center gap-2">
        <button
          onClick={() => onUpdate(productId, quantity - 1)}
          className="w-8 h-8 rounded border hover:bg-gray-100"
        >
          -
        </button>
        <span className="w-8 text-center">{quantity}</span>
        <button
          onClick={() => onUpdate(productId, quantity + 1)}
          className="w-8 h-8 rounded border hover:bg-gray-100"
        >
          +
        </button>
      </div>
      <button
        onClick={() => onRemove(productId)}
        className="text-red-500 hover:text-red-700"
      >
        ×
      </button>
    </div>
  );
};

// Main Cart Component
export function ShoppingCart() {
  const {
    cart,
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
    applyCoupon,
    removeCoupon,
    setShippingOption,
    getShippingOptions,
    syncCart,
    calculateTotals,
    isLoading,
    error,
    clearError,
  } = useCartStore();

  const [showShipping, setShowShipping] = useState(false);
  const [couponCode, setCouponCode] = useState('');
  const [shippingOptions, setShippingOptions] = useState<ShippingOption[]>([]);
  const [isCheckingOut, setIsCheckingOut] = useState(false);

  useEffect(() => {
    // Load shipping options
    const loadShipping = async () => {
      const options = await getShippingOptions();
      setShippingOptions(options);
    };
    loadShipping();
  }, []);

  // Handle adding a product (from product page)
  const handleAddToCart = (product: Product, quantity: number = 1) => {
    addItem(product, quantity);
  };

  const handleUpdateQuantity = (productId: string, quantity: number) => {
    updateQuantity(productId, quantity);
  };

  const handleRemoveItem = (productId: string) => {
    removeItem(productId);
  };

  const handleApplyCoupon = async () => {
    try {
      await applyCoupon(couponCode);
      setCouponCode('');
    } catch (error) {
      // Error is already in the store
    }
  };

  const handleCheckout = async () => {
    setIsCheckingOut(true);
    try {
      await syncCart();
      // Navigate to checkout page
      window.location.href = '/checkout';
    } catch (error) {
      console.error('Checkout error:', error);
    } finally {
      setIsCheckingOut(false);
    }
  };

  if (isLoading && !cart) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!cart || cart.items.length === 0) {
    return (
      <div className="text-center py-12">
        <h2 className="text-2xl font-semibold mb-4">Your cart is empty</h2>
        <p className="text-gray-600 mb-6">Start shopping to add items to your cart.</p>
        <button 
          onClick={() => window.location.href = '/products'}
          className="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Browse Products
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6">Shopping Cart</h1>
      
      {error && (
        <div className="mb-4 p-4 bg-red-100 text-red-700 rounded flex justify-between">
          <span>{error}</span>
          <button onClick={clearError} className="text-red-500">×</button>
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        {/* Cart Items */}
        <div className="divide-y">
          {cart.items.map((item) => (
            <CartItem
              key={item.productId}
              productId={item.productId}
              onUpdate={handleUpdateQuantity}
              onRemove={handleRemoveItem}
            />
          ))}
        </div>

        {/* Coupon Section */}
        <div className="p-4 border-t">
          <div className="flex gap-2">
            <input
              type="text"
              value={couponCode}
              onChange={(e) => setCouponCode(e.target.value.toUpperCase())}
              placeholder="Enter coupon code"
              className="flex-1 px-3 py-2 border rounded"
              disabled={!!cart.couponCode}
            />
            <button
              onClick={handleApplyCoupon}
              disabled={!!cart.couponCode || isLoading}
              className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
            >
              Apply
            </button>
            {cart.couponCode && (
              <button
                onClick={removeCoupon}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Remove Coupon
              </button>
            )}
          </div>
          {cart.couponCode && (
            <p className="mt-2 text-sm text-green-600">
              Coupon {cart.couponCode} applied: -${(cart.discount || 0).toFixed(2)}
            </p>
          )}
        </div>

        {/* Shipping Section */}
        <div className="p-4 border-t">
          <button
            onClick={() => setShowShipping(!showShipping)}
            className="text-blue-600 hover:underline"
          >
            {showShipping ? 'Hide Shipping Options' : 'Show Shipping Options'}
          </button>
          {showShipping && (
            <div className="mt-2 space-y-2">
              {shippingOptions.map((option) => (
                <label key={option.id} className="flex items-center gap-2 p-2 border rounded hover:bg-gray-50 cursor-pointer">
                  <input
                    type="radio"
                    name="shipping"
                    value={option.id}
                    checked={selectedShippingOption?.id === option.id}
                    onChange={() => setShippingOption(option)}
                  />
                  <div className="flex-1">
                    <span className="font-medium">{option.name}</span>
                    <span className="text-sm text-gray-600 ml-2">
                      ${option.cost.toFixed(2)} - {option.estimatedDays} days
                    </span>
                  </div>
                </label>
              ))}
            </div>
          )}
        </div>

        {/* Summary */}
        <div className="p-4 border-t bg-gray-50 rounded-b-lg">
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span>Subtotal</span>
              <span>${(cart.subtotal || 0).toFixed(2)}</span>
            </div>
            {cart.discount > 0 && (
              <div className="flex justify-between text-green-600">
                <span>Discount</span>
                <span>-${(cart.discount || 0).toFixed(2)}</span>
              </div>
            )}
            <div className="flex justify-between">
              <span>Shipping</span>
              <span>${(cart.shippingCost || 0).toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span>Tax ({(TAX_RATE * 100).toFixed(0)}%)</span>
              <span>${(cart.tax || 0).toFixed(2)}</span>
            </div>
            <div className="flex justify-between font-bold text-lg pt-2 border-t">
              <span>Total</span>
              <span>${(cart.total || 0).toFixed(2)}</span>
            </div>
          </div>

          <div className="mt-4 flex gap-2">
            <button
              onClick={() => clearCart()}
              className="px-4 py-2 border border-red-600 text-red-600 rounded hover:bg-red-50"
            >
              Clear Cart
            </button>
            <button
              onClick={handleCheckout}
              disabled={isCheckingOut || isLoading}
              className="flex-1 px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
            >
              {isCheckingOut ? 'Processing...' : 'Proceed to Checkout'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### Step 4: Product Page Integration

```tsx
// src/components/ProductPage.tsx
'use client';

import React, { useState } from 'react';
import { useCartStore } from '../store/cartStore';
import { Product } from '../types/cart.types';

export function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1);
  const { addItem, isInCart, getAvailableStock } = useCartStore();
  
  const inCart = isInCart(product.id);
  const availableStock = getAvailableStock(product.id);
  const maxQuantity = Math.min(product.stock, product.maxPerOrder || Infinity);
  
  const handleAddToCart = async () => {
    try {
      await addItem(product, quantity);
      // Show success message
    } catch (error) {
      // Show error message
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-4">
      <div className="flex flex-col md:flex-row gap-8">
        <div className="md:w-1/2">
          <img 
            src={product.image || '/placeholder.png'} 
            alt={product.name}
            className="w-full rounded-lg"
          />
        </div>
        <div className="md:w-1/2">
          <h1 className="text-3xl font-bold mb-4">{product.name}</h1>
          <p className="text-gray-600 mb-4">{product.description}</p>
          <p className="text-2xl font-bold mb-4">${product.price.toFixed(2)}</p>
          
          <div className="mb-4">
            <p className="text-sm text-gray-600">
              {product.stock > 0 ? (
                <span className="text-green-600">In Stock ({product.stock} available)</span>
              ) : (
                <span className="text-red-600">Out of Stock</span>
              )}
            </p>
            {product.maxPerOrder && (
              <p className="text-sm text-gray-500">
                Max {product.maxPerOrder} per order
              </p>
            )}
          </div>

          {inCart && (
            <div className="mb-4 p-2 bg-blue-50 text-blue-700 rounded">
              This item is already in your cart
            </div>
          )}

          <div className="flex gap-4">
            <div className="flex items-center gap-2">
              <button
                onClick={() => setQuantity(q => Math.max(1, q - 1))}
                className="w-10 h-10 rounded border hover:bg-gray-100"
                disabled={quantity <= 1}
              >
                -
              </button>
              <span className="w-12 text-center">{quantity}</span>
              <button
                onClick={() => setQuantity(q => Math.min(maxQuantity, q + 1))}
                className="w-10 h-10 rounded border hover:bg-gray-100"
                disabled={quantity >= maxQuantity}
              >
                +
              </button>
            </div>
            <button
              onClick={handleAddToCart}
              disabled={product.stock === 0 || isLoading}
              className="flex-1 px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
            >
              {inCart ? 'Update Cart' : 'Add to Cart'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

---

## The Verification: Testing the Shopping Cart

### Step 1: Test Cart Operations

```javascript
// In browser console
import { useCartStore } from './src/store/cartStore';

// Create a mock product
const product = {
  id: 'prod-1',
  name: 'Test Product',
  price: 29.99,
  stock: 100,
  maxPerOrder: 10,
  description: 'Test product',
  category: 'test',
  currency: 'USD',
};

const store = useCartStore.getState();

// Add item
await store.addItem(product, 2);
console.log('Cart:', store.cart);
console.log('Item count:', store.getItemCount());
console.log('Subtotal:', store.calculateSubtotal());

// Update quantity
await store.updateQuantity('prod-1', 5);
console.log('Updated quantity:', store.getItemQuantity('prod-1'));

// Apply coupon
await store.applyCoupon('SAVE10');
console.log('Discount:', store.cart?.discount);
console.log('Total:', store.cart?.total);

// Remove item
await store.removeItem('prod-1');
console.log('Cart after removal:', store.cart);

// Clear cart
await store.clearCart();
console.log('Cart after clear:', store.cart);
```

### Step 2: Test Offline Behavior

1. Open DevTools → Network → Offline
2. Add item to cart
3. ✅ Item should appear in UI
4. ✅ Item should be queued for sync
5. Turn network back online
6. ✅ Queue should process automatically

### Step 3: Test Inventory Validation

1. Add item with quantity exceeding stock
2. ✅ Should show error
3. Try adding more than maxPerOrder
4. ✅ Should show error

### Step 4: Test Tax and Shipping Calculations

1. Add items totaling less than $100
2. ✅ Shipping cost should apply
3. Add items totaling over $100
4. ✅ Shipping should be free

### Step 5: Test Coupon Validation

1. Apply valid coupon 'SAVE10'
2. ✅ Discount should apply
3. Apply invalid coupon
4. ✅ Should show error
5. Remove coupon
6. ✅ Discount should be removed

---

## Deep Dive: Advanced Cart Features

### Cart Abandonment Tracking

```typescript
// src/store/cartAbandonment.ts
import { useCartStore } from './cartStore';
import { useEffect, useState } from 'react';

export function useCartAbandonment() {
  const [lastActive, setLastActive] = useState(Date.now());
  const cart = useCartStore((state) => state.cart);

  useEffect(() => {
    const interval = setInterval(() => {
      const now = Date.now();
      const inactiveTime = now - lastActive;
      
      // If user has been inactive for 5 minutes with items in cart
      if (inactiveTime > 5 * 60 * 1000 && cart && cart.items.length > 0) {
        // Save cart state for reminder
        localStorage.setItem('abandoned_cart', JSON.stringify({
          cart,
          timestamp: now,
        }));
        
        // Could trigger email reminder
        console.log('Cart abandoned:', cart);
      }
    }, 60000);

    // Update last active on user interaction
    const updateActivity = () => setLastActive(Date.now());
    window.addEventListener('click', updateActivity);
    window.addEventListener('scroll', updateActivity);

    return () => {
      clearInterval(interval);
      window.removeEventListener('click', updateActivity);
      window.removeEventListener('scroll', updateActivity);
    };
  }, [cart, lastActive]);
}
```

### Multi-Cart Support

```typescript
// src/store/multiCartStore.ts
import { create } from 'zustand';

interface MultiCartStore {
  carts: Record<string, Cart>;
  activeCartId: string | null;
  
  createCart: (id: string) => void;
  switchCart: (id: string) => void;
  deleteCart: (id: string) => void;
  mergeCarts: (sourceId: string, targetId: string) => void;
}

export const useMultiCartStore = create<MultiCartStore>()(
  immer((set, get) => ({
    carts: {},
    activeCartId: null,

    createCart: (id: string) => {
      set((state) => {
        state.carts[id] = {
          id,
          items: [],
          subtotal: 0,
          tax: 0,
          shippingCost: 0,
          discount: 0,
          total: 0,
          currency: 'USD',
          updatedAt: new Date(),
        };
        state.activeCartId = id;
      });
    },

    switchCart: (id: string) => {
      set({ activeCartId: id });
    },

    deleteCart: (id: string) => {
      set((state) => {
        delete state.carts[id];
        if (state.activeCartId === id) {
          state.activeCartId = Object.keys(state.carts)[0] || null;
        }
      });
    },

    mergeCarts: (sourceId: string, targetId: string) => {
      set((state) => {
        const source = state.carts[sourceId];
        const target = state.carts[targetId];
        if (!source || !target) return;
        
        // Merge items
        for (const sourceItem of source.items) {
          const targetItem = target.items.find(
            i => i.productId === sourceItem.productId
          );
          if (targetItem) {
            targetItem.quantity += sourceItem.quantity;
          } else {
            target.items.push(sourceItem);
          }
        }
        
        // Delete source cart
        delete state.carts[sourceId];
        if (state.activeCartId === sourceId) {
          state.activeCartId = targetId;
        }
      });
    },
  }))
);
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Not Checking Stock on Add

```typescript
// ❌ BAD: Adding without stock check
addItem: (product, quantity) => {
  set((state) => {
    state.cart.items.push({ product, quantity });
  });
}

// ✅ GOOD: Check stock before adding
addItem: async (product, quantity) => {
  if (quantity > product.stock) {
    throw new Error('Not enough stock');
  }
  // ... add to cart
}
```

### Pitfall 2: Losing Cart on Page Refresh

```typescript
// ❌ BAD: No persistence
const useCartStore = create((set) => ({ /* ... */ }));

// ✅ GOOD: Use persist middleware
const useCartStore = create(
  persist((set) => ({ /* ... */ }), { name: 'cart-storage' })
);
```

### Pitfall 3: Not Handling Quantity Updates

```typescript
// ❌ BAD: Allowing negative quantities
updateQuantity: (productId, quantity) => {
  set((state) => {
    const item = state.cart.items.find(i => i.productId === productId);
    if (item) item.quantity = quantity;
  });
}

// ✅ GOOD: Validate quantity
updateQuantity: async (productId, quantity) => {
  if (quantity < 0) return;
  if (quantity === 0) {
    await removeItem(productId);
    return;
  }
  // ... update
}
```

---

## Shopping Cart Checklist

- [ ] Add item with inventory validation
- [ ] Remove item from cart
- [ ] Update quantity with stock check
- [ ] Clear entire cart
- [ ] Calculate subtotal, tax, shipping, total
- [ ] Apply and remove coupons
- [ ] Select shipping options
- [ ] Persist cart across sessions
- [ ] Offline support with queued actions
- [ ] Sync cart with server
- [ ] Error handling for all operations
- [ ] UI feedback for loading states
- [ ] Optimistic updates for responsive UI

---

## Key Takeaways

1. **Inventory validation**: Always check stock before adding items
2. **Offline support**: Queue actions and sync when online
3. **Optimistic updates**: Update UI immediately, sync in background
4. **Persistence**: Save cart state across sessions
5. **Calculations**: Keep totals in sync with cart changes
6. **Coupons**: Validate and apply discounts
7. **Shipping**: Calculate based on subtotal and selected option
8. **Error handling**: Graceful error messages and fallbacks
9. **Performance**: Memoize cart components to prevent cascading re-renders
10. **Testing**: Test offline, inventory, coupon, and calculation scenarios

---

## What's Next

You've built a production-ready shopping cart. Next, you'll learn how to build complex dashboards with filters, preferences, and data caching.

