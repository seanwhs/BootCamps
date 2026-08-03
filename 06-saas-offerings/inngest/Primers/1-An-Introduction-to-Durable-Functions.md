# Primer 1: An Introduction to Durable Functions

**Estimated Time**: 10 Minutes
**Prerequisites**: Basic knowledge of JavaScript/TypeScript and Node.js. An existing project or a new one created for the tutorial.

## 1. The Problem: Why We Need Durable Functions

Imagine you're building an e-commerce platform. When a customer places an order, your system needs to handle several tasks: processing payment, checking inventory, scheduling shipment, and sending a confirmation email. In a traditional application, you might process these steps sequentially in a single request.

```javascript
// A typical, fragile approach in a web request
app.post("/api/order", async (req, res) => {
  await processPayment(req.body);
  await checkInventory(req.body.items);
  await scheduleShipment(req.body);
  await sendConfirmation(req.body);
  res.send({ success: true });
});
```

This code looks simple, but it is highly brittle. What happens if `scheduleShipment()` fails halfway through? The inventory is already updated, and the customer has been charged, but the order will never be shipped. If the server crashes after `processPayment()`, that customer will be charged but the order is completely lost .

**Inngest offers a fundamentally different approach: Durable Functions.** They are designed to guarantee completion from start to finish, surviving any failure along the way .

## 2. The Solution: Durable Functions

A Durable Function breaks a process into modular, independent steps. Each step is atomic and can be retried automatically in case of failure. The system maintains the state of the entire function, so if it fails in the middle, it can resume from the last successful step, not from the beginning .

The core concepts are:

*   **Events**: A signal that something happened (e.g., `order/created`). Events are the triggers for your functions .
*   **Functions**: The durable workflow itself, defined to run in response to an event.
*   **Steps (`step.run`)**: A unit of work within a function. Each step is durable and automatically retried on failure .

The same order processing logic, written as a Durable Function, looks like this:

```javascript
const orderProcessingWorkflow = inngest.createFunction(
  { id: "order-processing-workflow" },
  { event: "order/placed" },
  async ({ event, step }) => {
    // Step 1: Process the payment. If it fails, it retries.
    const paymentConfirmation = await step.run("process-payment", async () => {
      return await processPayment(event.data.orderDetails);
    });

    // Step 2: Check inventory. If it fails, it retries.
    const inventoryStatus = await step.run("check-inventory", async () => {
      return await checkInventory(event.data.orderDetails.items);
    });

    // Step 3: Schedule shipment. If it fails, it retries.
    const shipmentDetails = await step.run("schedule-shipment", async () => {
      return await scheduleShipment(event.data.orderDetails);
    });

    // Step 4: Send confirmation. If it fails, it retries.
    await step.run("send-notification", async () => {
      return await sendNotification(event.data.customerId);
    });
  }
);
```

If any step fails, Inngest automatically retries it. If the server crashes after `process-payment`, Inngest will re-execute the function, skip the already-successful `process-payment` step, and resume from `check-inventory`. This prevents duplicate work and ensures the process eventually completes .

## 3. Let's Get Started

In this primer, we will set up your development environment and write your first Durable Function.

### A. Setup

First, ensure you have a Node.js project ready. You can create a new one if needed:

```bash
npx create-next-app@latest my-inngest-app --ts --eslint --tailwind --src-dir --app
cd my-inngest-app
```

Next, install the Inngest SDK:

```bash
npm install inngest
# or
pnpm add inngest
```

### B. Run the Inngest Dev Server

The Inngest Dev Server is a local environment that simulates the full Inngest platform. It allows you to test your functions without any infrastructure setup .

1.  First, install the Inngest CLI:
    ```bash
    curl -sSfL https://cli.inngest.com/install.sh | sh
    ```

2.  Start the Dev Server:
    ```bash
    npx inngest-cli@latest dev -u http://localhost:3000/api/inngest
    ```

3.  Open your browser to [http://localhost:8288](http://localhost:8288) to see the Dev Server UI. You will use this dashboard to monitor and test your functions .

### C. Setup your Inngest Client and API Route

Create a client and a serve handler so Inngest can discover and invoke your functions.

1.  **Create the client**: Create a new file at `src/inngest/client.ts` .
    ```javascript
    import { Inngest } from "inngest";

    export const inngest = new Inngest({ id: "my-app" });
    ```

2.  **Set up the API route**: Create the file `src/app/api/inngest/route.ts`. This is the endpoint Inngest calls to register and invoke your functions .
    ```javascript
    import { serve } from "inngest/next";
    import { inngest } from "../../../inngest/client";

    // We'll export an empty array of functions for now
    export const { GET, POST, PUT } = serve({
      client: inngest,
      functions: [],
    });
    ```

### D. Write your First Function

Now, let's create a "Hello, World!" function. This function will wait for an event, sleep for a second, and return a message .

1.  **Define the function**: In your `src/inngest/client.ts` file, add the following:
    ```javascript
    import { Inngest } from "inngest";

    export const inngest = new Inngest({ id: "my-app" });

    // Your new function
    const helloWorld = inngest.createFunction(
      { id: "hello-world", triggers: [{ event: "test/hello.world" }] },
      async ({ event, step }) => {
        await step.sleep("wait-a-moment", "1s");
        return { message: `Hello ${event.data.email}!` };
      }
    );

    // Add the function to the exported array
    export const functions = [helloWorld];
    ```

2.  **Register the function**: Update your API route to register the function, making it discoverable by Inngest .
    ```javascript
    // src/app/api/inngest/route.ts
    import { serve } from "inngest/next";
    import { inngest, functions } from "../../../inngest/client";

    export const { GET, POST, PUT } = serve({
      client: inngest,
      functions, // This is the array we exported
    });
    ```

### E. Trigger your Function

You can trigger your function in two ways: from the Inngest Dev Server UI, or from your application code .

**Option 1: Trigger from the Dev Server UI**

1.  Open the Dev Server at `http://localhost:8288`.
2.  Go to the "Functions" tab and find your `hello-world` function.
3.  Click "Invoke".
4.  In the pop-up, send a JSON payload like:
    ```json
    {
      "data": {
        "email": "test@example.com"
      }
    }
    ```
5.  Click "Invoke Function". You will see the run appear, and you can click into it to see its output and the step's timeline .

**Option 2: Trigger from Your Application Code**

Create a new API route in your application that sends the event .

1.  Create the file `src/app/api/hello/route.ts`.
2.  Add the following code:
    ```javascript
    import { NextResponse } from "next/server";
    import { inngest } from "../../../inngest/client";

    export async function GET() {
      await inngest.send({
        name: "test/hello.world",
        data: {
          email: "testUser@example.com",
        },
      });

      return NextResponse.json({ message: "Event sent!" });
    }
    ```

3.  Make a request to your new endpoint to send the event:
    ```bash
    curl -X GET http://localhost:3000/api/hello
    ```
    You will see a new run appear in the Dev Server UI.

---

## Next Steps

You've just written and executed your first durable function! You learned how to:

*   Identify problems that require durable execution.
*   Create an Inngest client and API route.
*   Write a function with a durable step (`step.run`).
*   Trigger it from both the Dev Server and your code.

This is the foundation. You can now start building more complex workflows by chaining steps together with `step.run()` for reliability, or use `step.sleep()` and `step.waitForEvent()` for long-running, human-in-the-loop processes.
