import { Pool } from 'pg';
import { PostgresParameter } from './PostgresParameter';

let pool: Pool;
const databaseUrl = process.env.DATABASE_URL;

if (databaseUrl) {
    pool = new Pool({
        connectionString: databaseUrl,
    });
} else {
    pool = new Pool({
        user: process.env.DB_USER,
        host: process.env.DB_HOST || 'localhost',
        database: process.env.DB_NAME || 'cruzi',
        password: process.env.DB_PASSWORD,
        port: parseInt(process.env.DB_PORT || '5432'),
    });
}

export async function sqlQuery(isFunction: boolean, queryOrFunctionName: string, parameters?: PostgresParameter[]): Promise<any[]> {
    try {
        let queryText: string;
        const paramValues: unknown[] =
            parameters ? parameters.map(param => {
                if (Array.isArray(param.value)) {
                    return JSON.stringify(param.value);
                }
                return param.value;
            }) : [];

        if (isFunction) {
            const placeholders = parameters ? parameters.map((_, index) => `$${index + 1}`).join(', ') : '';
            queryText = `SELECT * FROM ${queryOrFunctionName}(${placeholders})`;
        } else {
            queryText = queryOrFunctionName;
        }

        const result = await pool.query(queryText, paramValues);
        return result.rows;
    } catch (err) {
        console.error('SQL query error:', err);
        throw err;
    }
}
