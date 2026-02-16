# The Bloom Shop - Online Flower Shop

A modern, performant online flower shop built with Next.js 15 and MedusaJS v2.

## About

The Bloom Shop is an ecommerce storefront for fresh flower delivery. This application provides a seamless shopping experience for customers to browse, select, and order beautiful floral arrangements.

## Features

- Browse fresh flower collections
- Product detail pages with beautiful imagery
- Shopping cart and checkout
- Customer accounts and order history
- Stripe payment integration
- Responsive design for mobile and desktop
- Fast performance with Next.js 15

## Tech Stack

This project is built with:
- [Next.js 15](https://nextjs.org/) - React framework
- [MedusaJS v2](https://medusajs.com/) - Ecommerce backend
- [Tailwind CSS](https://tailwindcss.com/) - Styling
- [TypeScript](https://www.typescriptlang.org/) - Type safety

## Prerequisites

You need a Medusa server running locally on port 9000. For setup instructions, see the [MedusaJS documentation](https://docs.medusajs.com/learn/installation).

## Getting Started

### Install Dependencies

```shell
yarn
```

### Environment Variables

```shell
cp .env.template .env.local
```

Configure your environment variables in `.env.local`:
- `NEXT_PUBLIC_MEDUSA_BACKEND_URL` - Your Medusa backend URL
- `NEXT_PUBLIC_STRIPE_KEY` - Your Stripe public key (for payments)

### Run Development Server

```shell
yarn dev
```

Your site will be running at http://localhost:8000

## Deployment

### Build for Production

```shell
yarn build
```

### Start Production Server

```shell
yarn start
```

## Payment Integration

This store uses [Stripe](https://stripe.com/) for payment processing. Configure your Stripe keys in `.env.local` and set up the Stripe integration in your Medusa backend following the [Stripe integration guide](https://docs.medusajs.com/resources/commerce-modules/payment/payment-provider/stripe).

## License

© 2026 The Bloom Shop. All rights reserved.
