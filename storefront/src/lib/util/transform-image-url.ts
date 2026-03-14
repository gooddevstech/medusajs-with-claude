const BACKEND_URL =
  process.env.NEXT_PUBLIC_MEDUSA_BACKEND_URL || "http://localhost:9000"

export function transformImageUrl(url?: string | null): string | undefined {
  if (!url) return undefined
  if (url.startsWith("http://localhost:9000")) {
    return url.replace("http://localhost:9000", BACKEND_URL)
  }
  return url
}
