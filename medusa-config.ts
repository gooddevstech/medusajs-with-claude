import { loadEnv, defineConfig } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    databaseDriverOptions: {
      connection: {
        ssl: false
      }
    },
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },
  modules: {
    eventBus: {
      resolve: "@medusajs/event-bus-redis",
      options: {
        redisUrl: process.env.REDIS_URL
      }
    },
    cacheService: {
      resolve: "@medusajs/cache-redis",
      options: {
        redisUrl: process.env.REDIS_URL,
        ttl: 30
      }
    },
    payment: {
      resolve: "@medusajs/medusa/payment",
      options: {
        providers: [
          {
            resolve: "./src/modules/payrex",
            id: "payrex",
            options: {
              secretKey: process.env.PAYREX_SECRET_KEY,
              webhookSecret: process.env.PAYREX_WEBHOOK_SECRET,
              captureType: "automatic",
            }
          }
        ]
      }
    }
  },
  admin: {
    vite: () => ({
      server: {
        host: '0.0.0.0',
        port: 5173,
        hmr: {
          host: 'localhost',
          port: 5173
        }
      }
    })
  }
})
