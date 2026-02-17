import { Metadata } from "next"

import FeaturedProducts from "@modules/home/components/featured-products"
import Hero from "@modules/home/components/hero"
import { listCollections } from "@lib/data/collections"
import { getRegion } from "@lib/data/regions"
import LocalizedClientLink from "@modules/common/components/localized-client-link"

export const metadata: Metadata = {
  title: "The Bloom Shop - Handcrafted Fuzzy Wire Flowers",
  description:
    "Beautiful handcrafted fuzzy wire flowers that last forever. Perfect for any occasion.",
}

export default async function Home(props: {
  params: Promise<{ countryCode: string }>
}) {
  const params = await props.params

  const { countryCode } = params

  const region = await getRegion(countryCode)

  const { collections } = await listCollections({
    fields: "id, handle, title",
  })

  if (!collections || !region) {
    return null
  }

  return (
    <>
      <Hero />
      <div className="py-16 small:py-24">
        <ul className="flex flex-col">
          <FeaturedProducts collections={collections} region={region} />
        </ul>
      </div>

      {/* Brand Story Section */}
      <section className="bg-white py-16 small:py-24">
        <div className="content-container">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-3xl small:text-5xl font-heading text-bloom-charcoal mb-6">
              Our Story
            </h2>
            <p className="text-bloom-charcoal-light font-body text-base small:text-lg leading-relaxed">
              At The Bloom Shop, we believe every flower tells a story.<br/>
              Our artists handcraft each arrangement with the perfect gift for any occasion, bringing beauty and joy to life&apos;s most
              meaningful moments.<br/>
              They never need water!
            </p>
          </div>

          {/* Trust Badges */}
          <div className="grid grid-cols-2 small:grid-cols-4 gap-8 small:gap-12">
            <div className="flex flex-col items-center text-center gap-3">
              <div className="w-16 h-16 rounded-full bg-bloom-blush-light flex items-center justify-center">
                <span className="text-2xl">🌸</span>
              </div>
              <h3 className="font-heading text-lg text-bloom-charcoal">
                Made with Love
              </h3>
              <p className="text-sm text-bloom-charcoal-light font-body">
                100% Hand Made
              </p>
            </div>
            <div className="flex flex-col items-center text-center gap-3">
              <div className="w-16 h-16 rounded-full bg-bloom-blush-light flex items-center justify-center">
                <span className="text-2xl">💐</span>
              </div>
              <h3 className="font-heading text-lg text-bloom-charcoal">
                Eco
              </h3>
              <p className="text-sm text-bloom-charcoal-light font-body">
                No waste and last forever
              </p>
            </div>
            <div className="flex flex-col items-center text-center gap-3">
              <div className="w-16 h-16 rounded-full bg-bloom-blush-light flex items-center justify-center">
                <span className="text-2xl">✨</span>
              </div>
              <h3 className="font-heading text-lg text-bloom-charcoal">
                Unique
              </h3>
              <p className="text-sm text-bloom-charcoal-light font-body">
                One of a Kind
              </p>
            </div>
            <div className="flex flex-col items-center text-center gap-3">
              <div className="w-16 h-16 rounded-full bg-bloom-blush-light flex items-center justify-center">
                <span className="text-2xl">🚚</span>
              </div>
              <h3 className="font-heading text-lg text-bloom-charcoal">
                Same-Day Delivery
              </h3>
              <p className="text-sm text-bloom-charcoal-light font-body">
                Order before 2pm for delivery today
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-bloom-sage py-16 small:py-24">
        <div className="content-container text-center">
          <h2 className="text-3xl small:text-5xl font-heading text-white mb-4">
            Ready to Brighten Someone&apos;s Day?
          </h2>
          <p className="text-white/80 font-body text-base small:text-lg mb-8 max-w-2xl mx-auto">
            Browse our curated collection of fresh flowers and gifts, perfect
            for every occasion.
          </p>
          <LocalizedClientLink
            href="/store"
            className="inline-block px-10 py-4 bg-white text-bloom-charcoal font-body text-sm tracking-wider uppercase hover:bg-bloom-cream transition-colors duration-300"
          >
            Shop All Flowers
          </LocalizedClientLink>
        </div>
      </section>
    </>
  )
}
