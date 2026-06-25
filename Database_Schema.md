# Firestore Database Schema - Multi-Store & Multi-Branch

This schema supports multiple businesses (Tenants), each having multiple locations (Branches).

## 1. Tenants (Organization)
**Collection:** `tenants`
*   `id`: string
*   `businessName`: string
*   `logoUrl`: string
*   `subscriptionPlan`: string

## 2. Branches (Locations)
**Collection:** `branches`
*   `id`: string
*   `tenantId`: string (Ref to `tenants`)
*   `branchName`: string
*   `address`: string
*   `phoneNumber`: string
*   `gstin`: string (Branch-specific if applicable)

## 3. Users (Employees)
**Collection:** `users`
*   `uid`: string
*   `tenantId`: string
*   `branchId`: string (Assigned branch, null for global admins)
*   `role`: string ('owner', 'manager', 'cashier')
*   `email`: string
*   `permissions`: array<string>

## 4. Products (Catalog)
**Collection:** `products`
*   `id`: string
*   `tenantId`: string
*   `name`: string
*   `sku`: string
*   `taxRate`: number
*   `basePrice`: number

## 5. Branch Inventory (Stock per Location)
**Collection:** `branch_inventory`
*   `id`: string (`productId_branchId`)
*   `productId`: string
*   `branchId`: string
*   `tenantId`: string
*   `currentStock`: number
*   `lowStockThreshold`: number

## 6. Invoices (Sales)
**Collection:** `invoices`
*   `id`: string
*   `tenantId`: string
*   `branchId`: string
*   `invoiceNumber`: string
*   `staffId`: string
*   `date`: timestamp
*   `grandTotal`: number
*   `items`: array (snapshot of product details at time of sale)

## 7. Inventory Transactions
**Collection:** `inventory_transactions`
*   `id`: string
*   `tenantId`: string
*   `branchId`: string
*   `productId`: string
*   `type`: string ('in', 'out', 'transfer')
*   `quantity`: number
*   `date`: timestamp

## 8. Expenses
**Collection:** `expenses`
*   `id`: string
*   `tenantId`: string
*   `branchId`: string
*   `amount`: number
*   `category`: string
*   `date`: timestamp
