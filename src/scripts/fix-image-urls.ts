import { ExecArgs } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export default async function fixImageUrls({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const { manager } = container.resolve(ContainerRegistrationKeys.PG_CONNECTION) as any

  const backendUrl = process.env.MEDUSA_BACKEND_URL || "http://localhost:9000"

  if (backendUrl === "http://localhost:9000") {
    logger.warn("MEDUSA_BACKEND_URL is not set or is localhost — skipping fix.")
    return
  }

  logger.info(`Replacing localhost:9000 image URLs with ${backendUrl}...`)

  const result = await manager.query(
    `UPDATE product_image
     SET url = replace(url, 'http://localhost:9000', $1)
     WHERE url LIKE 'http://localhost:9000%'
     RETURNING url`,
    [backendUrl]
  )

  logger.info(`Updated ${result.rowCount} product image(s).`)

  const thumbResult = await manager.query(
    `UPDATE product
     SET thumbnail = replace(thumbnail, 'http://localhost:9000', $1)
     WHERE thumbnail LIKE 'http://localhost:9000%'
     RETURNING thumbnail`,
    [backendUrl]
  )

  logger.info(`Updated ${thumbResult.rowCount} product thumbnail(s).`)
  logger.info("Done.")
}
