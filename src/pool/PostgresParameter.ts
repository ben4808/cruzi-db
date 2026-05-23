export interface PostgresParameter {
    name: string;
    value: string | Date | number | boolean | null | object | unknown[];
}
