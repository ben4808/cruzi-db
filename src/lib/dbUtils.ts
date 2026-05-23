export function pickLocalizedText(val: unknown): string | undefined {
    if (val == null) return undefined;
    if (typeof val === "string") return val;
    if (typeof val === "object") {
        const v = val as Record<string, string>;
        return v.en ?? v[Object.keys(v)[0]];
    }
    return undefined;
}

export function getRandomInt(max: number) {
    return Math.floor(Math.random() * max);
}

export function generateId(): string {
    const charPool = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';
    let id = "";
    for (let i = 0; i < 11; i++) {
        id += charPool[getRandomInt(64)];
    }
    return id;
}

export function deepConvertToObject(data: unknown): unknown {
    if (data instanceof Map) {
        const obj: Record<string, unknown> = {};
        for (const [key, value] of data.entries()) {
            obj[key] = deepConvertToObject(value);
        }
        return obj;
    }

    if (Array.isArray(data)) {
        return data.map(item => deepConvertToObject(item));
    }

    if (typeof data === 'object' && data !== null) {
        const obj: Record<string, unknown> = {};
        for (const key in data) {
            if (Object.prototype.hasOwnProperty.call(data, key)) {
                obj[key] = deepConvertToObject((data as Record<string, unknown>)[key]);
            }
        }
        return obj;
    }

    return data;
}

export function entryToAllCaps(entry: string): string {
    const uppercasePhrase = entry.toUpperCase();
    const lettersOnlyPhrase = uppercasePhrase.replace(/[^a-zA-Z\u00C0-\u017F]/g, "");
    return lettersOnlyPhrase.replace(/\s/g, "");
}

export function zipArraysFlat<T, U>(arr1: T[], arr2: U[]): (T | U)[] {
    const result: (T | U)[] = [];
    const minLength = Math.min(arr1.length, arr2.length);

    for (let i = 0; i < minLength; i++) {
        result.push(arr1[i], arr2[i]);
    }

    return result;
}
