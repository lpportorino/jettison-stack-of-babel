import express from 'express';
import axios from 'axios';
import _ from 'lodash';
import { createServer } from 'http';

console.log('=== Jon-Babylon Node.js Test ===');
console.log(`Node.js version: ${process.version}`);

// Test ES modules
const app = express();
const port = 3000;

// Test async/await
async function testAsync() {
    console.log('Testing async/await...');
    await new Promise(resolve => setTimeout(resolve, 100));
    console.log('✓ Async/await works');
}

// Test Lodash
const numbers = [1, 2, 3, 4, 5];
const doubled = _.map(numbers, n => n * 2);
console.log('Lodash test:', doubled);

// Test Express
app.get('/', (req, res) => {
    res.json({ message: 'Hello from Express!' });
});

// Test modern JavaScript features
const testModernJS = () => {
    // Optional chaining
    const obj = { a: { b: { c: 42 } } };
    console.log('Optional chaining:', obj?.a?.b?.c);

    // Nullish coalescing
    const value = null ?? 'default';
    console.log('Nullish coalescing:', value);

    // Array methods
    const result = [1, 2, 3, 4, 5]
        .filter(n => n > 2)
        .map(n => n ** 2)
        .reduce((acc, n) => acc + n, 0);
    console.log('Array methods result:', result);
};

// Run tests
(async () => {
    await testAsync();
    testModernJS();

    // Don't actually start the server in test mode
    if (process.env.NODE_ENV !== 'test') {
        const server = createServer(app);
        server.listen(port, () => {
            console.log(`Express server would listen on port ${port}`);
            server.close();
        });
    }

    console.log('✓ All Node.js tests passed!');
})();