import { Heading } from "@medusajs/ui"
import Image from "next/image"
import LocalizedClientLink from "@modules/common/components/localized-client-link"

const Hero = () => {
  return (
    <div className="h-[85vh] w-full border-b border-ui-border-base relative overflow-hidden">
      <Image
        src="/banner.jpg"
        alt="The Bloom Shop - Forever Flowers"
        fill
        priority
        className="object-cover"
      />
      <div className="absolute inset-0 bg-black/30 z-10" />
      <div className="absolute inset-0 z-20 flex flex-col justify-center items-center text-center px-6 small:px-32 gap-6">
        <Heading
          level="h2"
          className="text-3xl small:text-5xl font-heading text-bloom-charcoal mb-6 leading-tight text-white font-bold drop-shadow-lg"
        >
          Flowers That Last Forever
        </Heading>
        <p className="text-lg small:text-xl text-white/90 max-w-2xl font-body drop-shadow-md">
          Handcrafted with Love ❤️🌷
        </p>
        <LocalizedClientLink
          href="/store"
          className="mt-4 px-8 py-3 bg-white text-black font-semibold rounded-full hover:bg-white/90 transition-colors"
        >
          Shop Now
        </LocalizedClientLink>
      </div>
    </div>
  )
}

export default Hero
