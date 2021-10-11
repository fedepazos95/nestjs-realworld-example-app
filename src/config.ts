export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  secretKey: process.env.SECRET_KEY,
});
