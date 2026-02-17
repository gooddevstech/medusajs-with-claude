import { listCategories } from "@lib/data/categories"
import { listCollections } from "@lib/data/collections"
import { Text, clx } from "@medusajs/ui"

import LocalizedClientLink from "@modules/common/components/localized-client-link"

export default async function Footer() {
  const { collections } = await listCollections({
    fields: "*products",
  })
  const productCategories = await listCategories()

  return (
    <footer className="bg-bloom-charcoal text-white w-full">
      <div className="content-container flex flex-col w-full">
        <div className="flex flex-col gap-y-8 xsmall:flex-row items-start justify-between py-16 small:py-24">
          <div className="flex flex-col gap-y-4">
            <LocalizedClientLink
              href="/"
              className="font-heading text-3xl text-white hover:text-bloom-blush transition-colors"
            >
              The Bloom Shop
            </LocalizedClientLink>
            <p className="text-white/60 font-body text-sm max-w-xs leading-relaxed">
              Handcrafted bouquets and floral arrangements for every occasion.
              Delivering beauty and joy, one bloom at a time.
            </p>
          </div>
          <div className="font-body text-sm gap-10 md:gap-x-16 grid grid-cols-2 sm:grid-cols-3">
            {productCategories && productCategories?.length > 0 && (
              <div className="flex flex-col gap-y-3">
                <span className="text-white font-semibold tracking-wider uppercase text-xs">
                  Categories
                </span>
                <ul
                  className="grid grid-cols-1 gap-2"
                  data-testid="footer-categories"
                >
                  {productCategories?.slice(0, 6).map((c) => {
                    if (c.parent_category) {
                      return
                    }

                    const children =
                      c.category_children?.map((child) => ({
                        name: child.name,
                        handle: child.handle,
                        id: child.id,
                      })) || null

                    return (
                      <li
                        className="flex flex-col gap-2 text-white/60"
                        key={c.id}
                      >
                        <LocalizedClientLink
                          className={clx(
                            "hover:text-bloom-blush transition-colors",
                            children && "font-medium text-white/80"
                          )}
                          href={`/categories/${c.handle}`}
                          data-testid="category-link"
                        >
                          {c.name}
                        </LocalizedClientLink>
                        {children && (
                          <ul className="grid grid-cols-1 ml-3 gap-2">
                            {children &&
                              children.map((child) => (
                                <li key={child.id}>
                                  <LocalizedClientLink
                                    className="hover:text-bloom-blush transition-colors"
                                    href={`/categories/${child.handle}`}
                                    data-testid="category-link"
                                  >
                                    {child.name}
                                  </LocalizedClientLink>
                                </li>
                              ))}
                          </ul>
                        )}
                      </li>
                    )
                  })}
                </ul>
              </div>
            )}
            {collections && collections.length > 0 && (
              <div className="flex flex-col gap-y-3">
                <span className="text-white font-semibold tracking-wider uppercase text-xs">
                  Collections
                </span>
                <ul
                  className={clx(
                    "grid grid-cols-1 gap-2 text-white/60",
                    {
                      "grid-cols-2": (collections?.length || 0) > 3,
                    }
                  )}
                >
                  {collections?.slice(0, 6).map((c) => (
                    <li key={c.id}>
                      <LocalizedClientLink
                        className="hover:text-bloom-blush transition-colors"
                        href={`/collections/${c.handle}`}
                      >
                        {c.title}
                      </LocalizedClientLink>
                    </li>
                  ))}
                </ul>
              </div>
            )}
            <div className="flex flex-col gap-y-3">
              <span className="text-white font-semibold tracking-wider uppercase text-xs">
                Help
              </span>
              <ul className="grid grid-cols-1 gap-2 text-white/60">
                <li>
                  <LocalizedClientLink
                    href="/account"
                    className="hover:text-bloom-blush transition-colors"
                  >
                    My Account
                  </LocalizedClientLink>
                </li>
                <li>
                  <LocalizedClientLink
                    href="/cart"
                    className="hover:text-bloom-blush transition-colors"
                  >
                    Cart
                  </LocalizedClientLink>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div className="flex w-full py-6 justify-between border-t border-white/10">
          <Text className="text-white/40 text-xs font-body">
            &copy; {new Date().getFullYear()} The Bloom Shop. All rights reserved.
          </Text>
        </div>
      </div>
    </footer>
  )
}
