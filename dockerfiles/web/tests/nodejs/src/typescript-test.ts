// TypeScript test file
interface Person {
    name: string;
    age: number;
}

class Greeter<T extends Person> {
    private greeting: string;

    constructor(message: string) {
        this.greeting = message;
    }

    greet(person: T): string {
        return `${this.greeting}, ${person.name}! You are ${person.age} years old.`;
    }
}

// Test decorators
function logged(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const original = descriptor.value;
    descriptor.value = function(...args: any[]) {
        console.log(`Calling ${propertyKey} with args:`, args);
        return original.apply(this, args);
    };
}

class Calculator {
    @logged
    add(a: number, b: number): number {
        return a + b;
    }
}

// Test async/generics
async function fetchData<T>(url: string): Promise<T> {
    // Simulated fetch
    return {} as T;
}

// Test type guards
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

// Test template literal types
type EventName = `on${Capitalize<string>}`;
const eventName: EventName = 'onClick';

// Test conditional types
type IsArray<T> = T extends any[] ? true : false;
type Test1 = IsArray<string[]>; // true
type Test2 = IsArray<number>; // false

console.log('✓ TypeScript compilation successful');

export { Greeter, Calculator };