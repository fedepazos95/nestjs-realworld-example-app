export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  secretKey: process.env.SECRET_KEY,
  database: {
    host: process.env.DATABASE_HOST,
    port: parseInt(process.env.DATABASE_PORT, 10),
    username: process.env.DATABASE_USERNAME,
    password: process.env.DATABASE_PASSWORD,
    name: process.env.DATABASE_NAME,
  },
});
