const mysql = require('mysql2/promise');

class DatabaseService {
  constructor() {
    this.pool = null;
    this.init();
  }

  async init() {
    try {
      this.pool = mysql.createPool({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'trinity',
        password: process.env.DB_PASSWORD || 'trinity',
        database: process.env.DB_NAME || 'characters',
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
      });
      
      console.log('Database connection pool created');
    } catch (error) {
      console.error('Database connection failed:', error);
    }
  }

  async query(sql, params = []) {
    try {
      const [rows] = await this.pool.execute(sql, params);
      return rows;
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  async getConnection() {
    return await this.pool.getConnection();
  }
}

module.exports = new DatabaseService();