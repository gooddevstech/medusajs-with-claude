import React, { Suspense } from "react"

import ImageGallery from "@modules/products/components/image-gallery"
import ProductActions from "@modules/products/components/product-actions"
import ProductOnboardingCta from "@modules/products/components/product-onboarding-cta"
import ProductTabs from "@modules/products/components/product-tabs"
import RelatedProducts from "@modules/products/components/related-products"
import ProductInfo from "@modules/products/templates/product-info"
import SkeletonRelatedProducts from "@modules/skeletons/templates/skeleton-related-products"
import { notFound } from "next/navigation"
import { HttpTypes } from "@medusajs/types"

import ProductActionsWrapper from "./product-actions-wrapper"

type ProductTemplateProps = {
  product: HttpTypes.StoreProduct
  region: HttpTypes.StoreRegion
  countryCode: string
  images: HttpTypes.StoreProductImage[]
}

const ProductTemplate: React.FC<ProductTemplateProps> = ({
  product,
  region,
  countryCode,
  images,
}) => {
  if (!product || !product.id) {
    return notFound()
  }

  return (
    <>
      <div
        className="content-container flex flex-col small:flex-row small:items-start py-8 small:py-12 relative gap-x-8"
        data-testid="product-container"
      >
        <div className="flex flex-col small:sticky small:top-48 small:py-0 small:max-w-[350px] w-full py-8 gap-y-8">
          <ProductInfo product={product} />
          <ProductTabs product={product} />
        </div>
        <div className="block w-full relative">
          <ImageGallery images={images} />
        </div>
        <div className="flex flex-col small:sticky small:top-48 small:py-0 small:max-w-[350px] w-full py-8 gap-y-8">
          <ProductOnboardingCta />
          <Suspense
            fallback={
              <ProductActions
                disabled={true}
                product={product}
                region={region}
              />
            }
          >
            <ProductActionsWrapper id={product.id} region={region} />
          </Suspense>
          {/* Delivery Info */}
          <div className="border border-bloom-charcoal/10 p-6 flex flex-col gap-4">
            <h4 className="font-heading text-lg text-bloom-charcoal">Delivery Information</h4>
            <div className="flex items-start gap-3">
              <span className="text-bloom-sage text-lg">🚚</span>
              <div>
                <p className="font-body text-sm font-medium text-bloom-charcoal">Same-Day Delivery</p>
                <p className="font-body text-xs text-bloom-charcoal-light">Order before 2pm for delivery today</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <span className="text-bloom-sage text-lg">🎁</span>
              <div>
                <p className="font-body text-sm font-medium text-bloom-charcoal">Gift Wrapping</p>
                <p className="font-body text-xs text-bloom-charcoal-light">Complimentary gift wrapping available</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div
        className="content-container my-16 small:my-24"
        data-testid="related-products-container"
      >
        <Suspense fallback={<SkeletonRelatedProducts />}>
          <RelatedProducts product={product} countryCode={countryCode} />
        </Suspense>
      </div>
    </>
  )
}

export default ProductTemplate
