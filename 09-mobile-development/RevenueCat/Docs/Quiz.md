# RevenueCat Masterclass: Comprehensive Quiz & Test Bank

## Complete Assessment Package with Answer Keys

---

# SECTION 1: FOUNDATIONAL KNOWLEDGE QUIZZES

---

## Quiz 1: RevenueCat Core Concepts
**Difficulty: Beginner | 15 Questions | 15 Minutes**

---

### Multiple Choice Questions

**1. What is RevenueCat's primary purpose?**

A) A replacement for Apple's App Store and Google Play
B) A payment processing service like Stripe for mobile subscriptions
C) An app development framework
D) A social media platform for developers

<details>
<summary>Answer</summary>
**B** - RevenueCat is the "Stripe for mobile subscriptions" - it handles the complex infrastructure of in-app purchases and subscriptions across platforms.
</details>

---

**2. Which of the following correctly describes the relationship between Products, Packages, and Offerings?**

A) Products contain Offerings, which contain Packages
B) Packages contain Products, which contain Offerings
C) Offerings contain Packages, which map to Products
D) All three are independent and unrelated

<details>
<summary>Answer</summary>
**C** - Offerings contain Packages (e.g., monthly, annual), and each Package maps to a specific Product in each app store (iOS and Android).
</details>

---

**3. What is an Entitlement in RevenueCat?**

A) A discount code for subscriptions
B) The premium features users unlock by subscribing
C) A type of subscription plan
D) A user's email address

<details>
<summary>Answer</summary>
**B** - Entitlements represent the premium features or content that users gain access to when they subscribe.
</details>

---

**4. Where are Products created in RevenueCat's architecture?**

A) Only in the RevenueCat dashboard
B) Only in App Store Connect or Google Play Console
C) In both App Store Connect AND RevenueCat dashboard
D) Through a separate third-party service

<details>
<summary>Answer</summary>
**B** - Products must be created in App Store Connect (iOS) and Google Play Console (Android) first. RevenueCat syncs with these products.
</details>

---

**5. What is an Offering in RevenueCat?**

A) A single subscription product
B) A group of Packages presented to users
C) A user's active entitlements
D) A promotional discount

<details>
<summary>Answer</summary>
**B** - An Offering is a collection of Packages (e.g., monthly and annual plans) that you present to users on your paywall.
</details>

---

**6. True or False: RevenueCat can work without any app store configuration.**

A) True
B) False

<details>
<summary>Answer</summary>
**B** - False. RevenueCat requires products to be created in App Store Connect and/or Google Play Console before they can be used.
</details>

---

**7. What is the purpose of the CustomerInfo object?**

A) To store user login credentials
B) To contain all information about a user's subscriptions and entitlements
C) To track app usage analytics
D) To manage push notifications

<details>
<summary>Answer</summary>
**C** - CustomerInfo contains all subscription data including active entitlements, expiration dates, and purchase history.
</details>

---

**8. Which API key is safe to include in your mobile app code?**

A) Secret API Key
B) Webhook API Key
C) Public API Key
D) All of the above are safe

<details>
<summary>Answer</summary>
**C** - The Public API Key is designed to be included in client-side code. Secret and Webhook keys should be kept on your server.
</details>

---

**9. What is the primary function of RevenueCat's addCustomerInfoUpdateListener?**

A) To detect when the app is opened
B) To receive real-time updates when subscription status changes
C) To log user analytics events
D) To send push notifications

<details>
<summary>Answer</summary>
**B** - The listener provides real-time updates whenever CustomerInfo changes (e.g., after purchase, renewal, cancellation).
</details>

---

**10. Which statement about RevenueCat and offline support is TRUE?**

A) RevenueCat doesn't work offline at all
B) RevenueCat requires constant internet connection for all features
C) RevenueCat can cache subscription state for offline access
D) RevenueCat handles offline purchases directly with the app store

<details>
<summary>Answer</summary>
**C** - RevenueCat caches subscription state locally, allowing users to access premium features even without an internet connection.
</details>

---

### True/False Questions

**11. Entitlements must be created in App Store Connect before they can be used in RevenueCat.**

<details>
<summary>Answer</summary>
**False** - Entitlements are created in the RevenueCat dashboard. Products are created in App Store Connect/Google Play Console.
</details>

---

**12. You can change pricing in RevenueCat without submitting a new app version.**

<details>
<summary>Answer</summary>
**True** - Pricing is managed through Offerings in the RevenueCat dashboard, which can be updated without app store review.
</details>

---

**13. RevenueCat only supports monthly and annual subscriptions.**

<details>
<summary>Answer</summary>
**False** - RevenueCat supports all subscription durations supported by app stores (weekly, monthly, quarterly, annual, etc.).
</details>

---

**14. The Secret API Key should be stored securely in your app's source code.**

<details>
<summary>Answer</summary>
**False** - Secret API Keys should never be stored in client-side code. They should be kept on your server and used for server-side operations.
</details>

---

**15. RevenueCat handles receipt validation automatically.**

<details>
<summary>Answer</summary>
**True** - One of RevenueCat's primary benefits is automatic receipt validation with both Apple and Google app stores.
</details>

---

## Quiz 2: Paywall & Purchase Flow
**Difficulty: Intermediate | 15 Questions | 15 Minutes**

---

### Multiple Choice Questions

**1. What are the three essential elements of a conversion-optimized paywall?**

A) Price, description, and contact information
B) Value proposition, pricing options, and clear call-to-action
C) Images, animations, and sound effects
D) Newsletter signup, social media links, and user ratings

<details>
<summary>Answer</summary>
**B** - The three essential elements are: communicating value, presenting clear options, and making the next step obvious.
</details>

---

**2. What is the purpose of price anchoring?**

A) To confuse users about pricing
B) To make a specific option seem more valuable by showing it alongside other options
C) To hide the actual price
D) To increase the price after users commit

<details>
<summary>Answer</summary>
**A** - Price anchoring makes the annual plan appear more valuable when shown alongside the monthly plan (e.g., "Only $8.33/month vs $9.99/month").
</details>

---

**3. What should you display when a user cancels a purchase mid-flow?**

A) A technical error message
B) A user-friendly message acknowledging the cancellation
C) Nothing - just close the paywall
D) A popup asking "Why did you cancel?"

<details>
<summary>Answer</summary>
**B** - Show a message like "You cancelled the purchase. No charges were made." This confirms their action and builds trust.
</details>

---

**4. Which purchase state is NOT part of a standard purchase flow?**

A) Idle
B) Processing
C) Success
D) Archiving

<details>
<summary>Answer</summary>
**D** - Standard states are: idle, loading/processing, success, error, and restoring. Archiving is not a purchase state.
</details>

---

**5. What is the correct way to handle the PURCHASE_CANCELLED error?**

A) Show a generic error message
B) Show a user-friendly message and allow the user to try again
C) Automatically retry the purchase
D) Crash the app

<details>
<summary>Answer</summary>
**B** - Show a friendly message like "You cancelled the purchase" and let the user try again if they want to.
</details>

---

**6. Which of the following is a best practice for paywall design?**

A) Show as many options as possible (5+)
B) Hide the price until users tap "Subscribe"
C) Highlight the best value option
D) Make it impossible to leave without subscribing

<details>
<summary>Answer</summary>
**C** - Highlight the best value option (typically the annual plan) to guide users toward the most profitable choice.
</details>

---

**7. What is the purpose of the restore purchases feature?**

A) To allow users to get refunds
B) To recover previous purchases on a new device
C) To change subscription plans
D) To cancel subscriptions

<details>
<summary>Answer</summary>
**B** - Restore purchases allows users to recover their subscriptions when they get a new device or reinstall the app.
</details>

---

**8. True or False: Apple requires a restore purchases button in all apps with subscriptions.**

A) True
B) False

<details>
<summary>Answer</summary>
**A** - True. Apple's App Store Review Guidelines require apps with subscriptions to include a restore purchases feature.
</details>

---

**9. Which error type is MOST appropriate when a user has no internet connection during purchase?**

A) PURCHASE_CANCELLED
B) NETWORK_ERROR
C) INVALID_CREDENTIALS
D) PRODUCT_NOT_AVAILABLE

<details>
<summary>Answer</summary>
**B** - NETWORK_ERROR should be shown with a message like "Please check your internet connection and try again."
</details>

---

**10. What is the best practice for handling the purchase success state?**

A) Immediately dismiss the paywall with no feedback
B) Show a confirmation message and transition to the main app
C) Ask the user to rate the app
D) Show a discount code for future purchases

<details>
<summary>Answer</summary>
**B** - Show a success message (e.g., "Welcome! You now have access to all premium features") and then transition to the main app.
</details>

---

### Scenario Questions

**11. A user taps "Subscribe" and the purchase sheet appears. They authenticate with Face ID and the purchase processes. Suddenly, the app crashes. What should happen when the user reopens the app?**

A) The purchase should be lost
B) RevenueCat should automatically sync and restore the subscription
C) The user should have to repurchase
D) The app should show an error message

<details>
<summary>Answer</summary>
**B** - RevenueCat automatically syncs with the app store. When the app reopens, getCustomerInfo() will return the updated CustomerInfo with the subscription.
</details>

---

**12. What would happen if you tried to use a Product ID that doesn't exist in App Store Connect?**

A) The purchase would complete successfully
B) RevenueCat would create the product automatically
C) You would get a PRODUCT_NOT_AVAILABLE error
D) The app would crash

<details>
<summary>Answer</summary>
**C** - The Product ID must exist in the app store. If it doesn't, RevenueCat returns a PRODUCT_NOT_AVAILABLE error.
</details>

---

**13. What should you do when showing a free trial offer?**

A) Hide the fact that it will auto-renew
B) Clearly display the trial duration and auto-renewal information
C) Only mention the trial after purchase
D) Show the trial as a separate, unconnected option

<details>
<summary>Answer</summary>
**B** - App store guidelines require clear disclosure of trial terms, including duration and auto-renewal information.
</details>

---

**14. What is the appropriate response when a user's purchase is successful but no entitlements are granted?**

A) Show a "Purchase Complete" message and ignore the entitlements
B) Show a message explaining the issue and suggest restoring purchases
C) Report it as a bug and crash
D) Automatically give the user all entitlements

<details>
<summary>Answer</summary>
**B** - This is an edge case that sometimes happens. Guide the user to restore purchases, which should resolve the issue.
</details>

---

**15. Which of the following should be included in your paywall's terms and conditions section?**

A) Only the price
B) Links to Terms of Service and Privacy Policy
C) The developer's contact information
D) A subscription countdown timer

<details>
<summary>Answer</summary>
**B** - App store guidelines require links to your Terms of Service and Privacy Policy in the paywall.
</details>

---

## Quiz 3: Subscription State Management
**Difficulty: Intermediate | 15 Questions | 15 Minutes**

---

### Multiple Choice Questions

**1. What is the primary benefit of using React Context for subscription state management?**

A) It makes the code run faster
B) It provides a global source of truth accessible to any component
C) It automatically handles all RevenueCat API calls
D) It reduces app bundle size

<details>
<summary>Answer</summary>
**B** - React Context provides a centralized state that any component can access, ensuring consistent subscription data across the app.
</details>

---

**2. What is the correct way to check if a user has a specific entitlement?**

A) Check if the user is logged in
B) Check if the entitlement exists in customerInfo.entitlements.active
C) Check if the user's email is verified
D) Check the device's purchase history

<details>
<summary>Answer</summary>
**B** - The entitlement is active if it exists in the customerInfo.entitlements.active object.
</details>

---

**3. Which pattern should you use to protect an entire screen from unauthorized access?**

A) A simple conditional check in the screen
B) The RequireEntitlement wrapper component
C) A navigation guard
D) Both B and C are appropriate

<details>
<summary>Answer</summary>
**D** - Both RequireEntitlement (component-level) and navigation guards are valid approaches for protecting screens.
</details>

---

**4. What is account migration in the context of RevenueCat?**

A) Moving a user's subscription from one device to another
B) Transferring a subscription from an anonymous user to an authenticated account
C) Changing a user's email address
D) Upgrading from monthly to annual

<details>
<summary>Answer</summary>
**B** - Account migration is the process of transferring a subscription purchased while anonymous to a user account, allowing access across devices.
</details>

---

**5. What is the purpose of caching subscription state?**

A) To reduce RevenueCat API calls
B) To provide offline access to subscription data
C) To speed up app launch
D) All of the above

<details>
<summary>Answer</summary>
**D** - Caching reduces API calls, provides offline access, and speeds up app launch by showing cached data immediately.
</details>

---

**6. Which method is used to identify a user to RevenueCat?**

A) setUserEmail()
B) setAppUserID()
C) identifyUser()
D) setUserId()

<details>
<summary>Answer</summary>
**B** - setAppUserID() is the RevenueCat method for identifying users. It's called for both authenticated and anonymous users.
</details>

---

**7. What happens when you call resetAppUserID()?**

A) The user's subscription is cancelled
B) The user is logged out of the app
C) RevenueCat clears the current user ID and generates a new anonymous ID
D) All of the above

<details>
<summary>Answer</summary>
**C** - resetAppUserID() clears the current user ID and generates a new anonymous ID, typically used when a user logs out.
</details>

---

**8. True or False: Anonymous users in RevenueCat can purchase subscriptions.**

A) True
B) False

<details>
<summary>Answer</summary>
**A** - True. Anonymous users can purchase subscriptions. The subscription is tied to the anonymous ID, which is stored on the device.
</details>

---

**9. What should you do when an authenticated user logs in and has an existing subscription?**

A) Do nothing - the subscription is already linked
B) Call setAppUserID() to link the subscription to their account
C) Create a new subscription for the user
D) Cancel the existing subscription

<details>
<summary>Answer</summary>
**B** - SetAppUserID() should be called when a user logs in. RevenueCat will automatically associate any existing purchases with that ID.
</details>

---

**10. What is the recommended maximum age for cached subscription data?**

A) 1 hour
B) 12 hours
C) 24 hours
D) 7 days

<details>
<summary>Answer</summary>
**C** - Cached data should typically expire after 24 hours to balance offline access with data freshness.
</details>

---

### Scenario Questions

**11. A user purchases a subscription while logged out. They then create an account and log in. What should happen?**

A) The subscription is lost and they must repurchase
B) The subscription should be transferred to their new account
C) The subscription remains tied to the anonymous ID
D) The user gets a free trial automatically

<details>
<summary>Answer</summary>
**B** - The subscription should be transferred to their account using setAppUserID(), which associates all purchases with the new user ID.
</details>

---

**12. Your app shows a premium badge for users with the "premium" entitlement. A user who was subscribed just cancelled. What should happen?**

A) The badge should stay since they were once subscribed
B) The badge should disappear when the subscription expires or is cancelled
C) The badge should flash red
D) The badge should only appear during the grace period

<details>
<summary>Answer</summary>
**B** - The entitlement is only active while the subscription is active. When the subscription expires or is cancelled, the entitlement is revoked.
</details>

---

**13. What is the difference between customerInfo.entitlements.active and customerInfo.entitlements.all?**

A) active contains only currently active entitlements; all contains all entitlements (including expired)
B) all contains all entitlements; active is a subset
C) There is no difference
D) active is for Android, all is for iOS

<details>
<summary>Answer</summary>
**A** - active contains currently active entitlements. all contains all entitlements ever granted, including expired and cancelled ones.
</details>

---

**14. You need to check if a user has access to a premium feature before making an API call. What's the best approach?**

A) Check the entitlement client-side and assume it's correct
B) Check the entitlement client-side AND verify server-side
C) Only check server-side
D) Don't check at all - let the API handle it

<details>
<summary>Answer</summary>
**B** - Client-side check improves UX (hiding features). Server-side verification prevents unauthorized API access. Use both for security.
</details>

---

**15. What should be the loading state behavior when checking an entitlement?**

A) Show nothing until the check completes
B) Show a loading spinner while checking
C) Assume the user has access while checking
D) Show a generic error message

<details>
<summary>Answer</summary>
**B** - Show a loading state (spinner or placeholder) while checking entitlements to prevent UI flicker or incorrect state.
</details>

---

## Quiz 4: Webhooks & Backend Integration
**Difficulty: Advanced | 15 Questions | 15 Minutes**

---

### Multiple Choice Questions

**1. What is the primary purpose of RevenueCat webhooks?**

A) To send notifications to users
B) To notify your server of subscription events in real-time
C) To display advertisements
D) To track app downloads

<details>
<summary>Answer</summary>
**B** - Webhooks send real-time notifications to your server when subscription events occur (purchase, renewal, cancellation, etc.).
</details>

---

**2. Why is webhook signature verification important?**

A) It makes the data easier to read
B) It ensures the webhook request is coming from RevenueCat, not an attacker
C) It removes sensitive data from the request
D) It speeds up processing

<details>
<summary>Answer</summary>
**B** - Signature verification prevents attackers from sending fake webhook requests to your server by confirming the request originated from RevenueCat.
</details>

---

**3. What HTTP status code should your webhook endpoint return to prevent RevenueCat from retrying?**

A) 200 OK
B) 400 Bad Request
C) 500 Internal Server Error
D) 301 Moved Permanently

<details>
<summary>Answer</summary>
**A** - Always return 200 OK to indicate successful receipt, even if processing fails internally. This prevents RevenueCat from retrying.
</details>

---

**4. Which of the following is NOT a subscription lifecycle event?**

A) INITIAL_PURCHASE
B) RENEWAL
C) USER_CLICKED
D) CANCELLATION

<details>
<summary>Answer</summary>
**C** - USER_CLICKED is not a RevenueCat webhook event. Standard events include INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION, REFUND, etc.
</details>

---

**5. What should you do when a CANCELLATION webhook is received?**

A) Immediately revoke all access
B) Update the database status and prepare for win-back campaigns
C) Delete the user's account
D) Send a "why are you leaving" survey

<details>
<summary>Answer</summary>
**B** - Update the user's status in your database and prepare for potential win-back campaigns. Don't revoke access immediately - they still have access until expiration.
</details>

---

**6. What is the correct time to revoke premium access for a user?**

A) Immediately upon cancellation
B) When the subscription expiration date passes
C) When the user requests a refund
D) When the webhook is received

<details>
<summary>Answer</summary>
**B** - Users who cancel should keep access until their paid period ends. Revoke access when the expiration date passes.
</details>

---

**7. What is idempotency and why is it important for webhook processing?**

A) Making the code faster
B) Processing an event multiple times without negative side effects
C) Encrypting the webhook data
D) Validating the webhook signature

<details>
<summary>Answer</summary>
**B** - Idempotency ensures that processing the same event multiple times (due to retries) doesn't cause duplicate actions or data corruption.
</details>

---

**8. Which HTTP header does RevenueCat use to sign webhook requests?**

A) X-Webhook-Signature
B) Authorization
C) X-API-Key
D) Content-Type

<details>
<summary>Answer</summary>
**A** - RevenueCat uses the X-Webhook-Signature header to include the HMAC signature for request verification.
</details>

---

**9. What is the recommended way to handle an error during webhook processing?**

A) Return a 500 status code
B) Return a 200 status code and log the error internally
C) Ignore the error
D) Return a 400 status code

<details>
<summary>Answer</summary>
**B** - Always return 200 to prevent RevenueCat retries, then log the error and handle it through your internal monitoring/alerting system.
</details>

---

**10. What happens to a user's subscription during a grace period?**

A) They lose access immediately
B) They keep access while attempting to resolve billing issues
C) They get a refund
D) Their subscription is automatically renewed

<details>
<summary>Answer</summary>
**B** - During the grace period, users retain access while the system attempts to resolve payment issues (e.g., updating expired credit cards).
</details>

---

### Scenario Questions

**11. A webhook event arrives with a signature that doesn't match the expected signature. What should you do?**

A) Process the event anyway
B) Return a 401 Unauthorized response
C) Log the event and continue processing
D) Send an email alert and process the event

<details>
<summary>Answer</summary>
**B** - Return 401 Unauthorized. This indicates the request is not from RevenueCat and should not be processed.
</details>

---

**12. You receive a webhook for a subscription renewal but your database already shows the user as active with a future expiration date. What should you do?**

A) Update the expiration date to the new one
B) Ignore the webhook since the user is already active
C) Reset the user's subscription status
D) Send a duplicate purchase email

<details>
<summary>Answer</summary>
**A** - Update the expiration date to the new one. The renewal extends the subscription, so the database should reflect the new expiration.
</details>

---

**13. A user requests a refund through the app store. What event does RevenueCat send?**

A) CANCELLATION
B) REFUND
C) EXPIRATION
D) BILLING_ISSUE

<details>
<summary>Answer</summary>
**B** - REFUND events are sent when a refund is processed through the app store. This should trigger access revocation and database updates.
</details>

---

**14. You want to send a win-back email to users who cancelled 7 days ago. How should you implement this?**

A) Check the CANCELLATION webhook and set a reminder
B) Query your database for users who cancelled 7 days ago
C) Send emails to all users who ever cancelled
D) Use RevenueCat's win-back feature directly

<details>
<summary>Answer</summary>
**B** - Store cancellation dates from webhooks in your database, then query for users who meet the criteria for your win-back campaign.
</details>

---

**15. Why is it important to handle all webhook event types, even ones you don't expect?**

A) To ensure the code compiles
B) Because RevenueCat may introduce new event types or your app may expand
C) To generate more logs
D) To make the code more complex

<details>
<summary>Answer</summary>
**B** - RevenueCat may introduce new event types, or your app may expand to support more features. Handling unexpected events prevents issues.
</details>

---

# SECTION 2: SCENARIO-BASED QUESTIONS

---

## Scenario 1: The New User Journey
**Difficulty: Intermediate | 5 Questions**

---

**Scenario:** Sarah downloads FitTrack Pro for the first time. She wants to try the app before committing to a subscription.

**1.1 What should the app show Sarah when she first opens it?**

A) Immediately show the paywall
B) Show the paywall only after she tries 3 free workouts
C) Show the paywall immediately after onboarding
D) Show the paywall only in settings

<details>
<summary>Answer</summary>
**C** - Onboarding paywalls are most effective. Apps like Mojo report 50%+ of trial conversions from onboarding paywalls.
</details>

---

**1.2 Sarah decides to sign up for a free trial. What information must be clearly displayed?**

A) Trial duration and auto-renewal terms
B) Only the price of the subscription
C) The developer's email address
D) A countdown timer

<details>
<summary>Answer</summary>
**A** - App store guidelines require clear disclosure of trial duration and auto-renewal information before purchase.
</details>

---

**1.3 Sarah completes the trial sign-up. What should happen immediately after?**

A) The app should show a "success" message and grant access to premium features
B) Sarah should be asked to rate the app
C) The app should show a loading screen indefinitely
D) Sarah should get an error message

<details>
<summary>Answer</summary>
**A** - Show a success message (e.g., "Welcome to FitTrack Pro!") and grant access to premium features. Update CustomerInfo automatically.
</details>

---

**1.4 Three days into her trial, Sarah's credit card expires. What should the app do?**

A) Cancel her trial immediately
B) Send a notification about the payment issue and allow time to update payment
C) Automatically extend her trial
D) Delete her account

<details>
<summary>Answer</summary>
**B** - RevenueCat sends BILLING_ISSUE and GRACE_PERIOD events. Your app/backend should notify the user to update payment.
</details>

---

**1.5 Sarah doesn't update her payment and the trial expires. What should happen?**

A) All premium access should be immediately revoked
B) Access should be revoked only when the subscription officially expires
C) Sarah should get a permanent free trial
D) The app should delete itself

<details>
<summary>Answer</summary>
**B** - The subscription should expire at the end of the trial period. The app should revoke premium access at that time and show an upgrade prompt.
</details>

---

## Scenario 2: The Account Migration
**Difficulty: Intermediate | 5 Questions**

---

**Scenario:** Alex downloaded FitTrack Pro and subscribed while logged out. A week later, Alex creates an account.

**2.1 What is the current state of Alex's subscription?**

A) The subscription is only accessible on the device it was purchased on
B) The subscription is lost
C) The subscription is still valid but tied to an anonymous RevenueCat ID
D) The subscription automatically transferred when Alex created an account

<details>
<summary>Answer</summary>
**C** - The subscription is valid and tied to the anonymous RevenueCat ID on that device. It hasn't been associated with any user account yet.
</details>

---

**2.2 What method should be called to transfer the subscription?**

A) transferSubscription()
B) setAppUserID()
C) migrateUser()
D) linkSubscription()

<details>
<summary>Answer</summary>
**B** - setAppUserID() transfers all purchases from the anonymous ID to the new user ID, associating the subscription with the user account.
</details>

---

**2.3 What is the correct order of operations for the account migration flow?**

A) Create account → Show success → Call setAppUserID()
B) Call setAppUserID() → Create account → Show success
C) Create account → Call setAppUserID() → Refresh CustomerInfo
D) Refresh CustomerInfo → Create account → Call setAppUserID()

<details>
<summary>Answer</summary>
**C** - Create the user account first, then call setAppUserID() to transfer the subscription, then refresh CustomerInfo to confirm.
</details>

---

**2.4 After calling setAppUserID(), what should happen?**

A) The user should restart the app
B) RevenueCat should sync and the user should have access across devices
C) The user should see an error
D) The subscription should be cancelled

<details>
<summary>Answer</summary>
**B** - RevenueCat syncs the subscription with the new user ID. The user should now have access on any device where they log in.
</details>

---

**2.5 What should happen if the user logs out after migration?**

A) The subscription should stay with the user account
B) The subscription should revert to the anonymous ID
C) The subscription should be cancelled
D) The user should lose all access

<details>
<summary>Answer</summary>
**A** - The subscription remains associated with the user account. When they log in again, they'll still have access.
</details>

---

## Scenario 3: The Churn Prevention
**Difficulty: Advanced | 5 Questions**

---

**Scenario:** FitTrack Pro has a 5% monthly churn rate. The product team wants to implement churn reduction strategies.

**3.1 What is the first step in a churn reduction strategy?**

A) Offer deep discounts to everyone
B) Understand why users are leaving
C) Remove the cancellation button
D) Make cancellation impossible

<details>
<summary>Answer</summary>
**B** - Understand why users are leaving before implementing strategies. Use surveys, analytics, and user feedback.
</details>

---

**3.2 What should you do when a user submits a cancellation?**

A) Immediately cancel their subscription
B) Ask "Why are you leaving?" and offer a retention discount
C) Delete their account
D) Send them a survey after cancellation

<details>
<summary>Answer</summary>
**B** - The cancellation flow is a key retention opportunity. Ask for feedback and consider offering a discount or alternative plan.
</details>

---

**3.3 A user's payment fails. How long should the grace period typically be?**

A) 1 day
B) 3-7 days
C) 1 month
D) 1 year

<details>
<summary>Answer</summary>
**B** - Grace periods typically range from 3-7 days, giving users time to update their payment method before losing access.
</details>

---

**3.4 What's the most effective way to notify users about expiring access?**

A) One notification the day it expires
B) Multiple notifications (1 day, 3 days, 5 days after expiry)
C) Notifications at 7 days, 3 days, and 1 day before expiration
D) No notifications - let them figure it out

<details>
<summary>Answer</summary>
**C** - Send notifications before the expiration to give users time to act. At 7 days, 3 days, and 1 day before expiration is a common pattern.
</details>

---

**3.5 What type of win-back offer is most effective?**

A) 10% discount
B) 30-50% discount or first month free
C) 90% discount
D) No discount - just reminder emails

<details>
<summary>Answer</summary>
**B** - 30-50% discounts or a free month are commonly effective. The discount should be meaningful enough to entice return.
</details>

---

# SECTION 3: PRACTICAL EXERCISES

---

## Exercise 1: Paywall Implementation
**Difficulty: Intermediate | 30 Minutes**

---

### Task
Implement a complete paywall screen with the following requirements:

1. Show two subscription options: Monthly ($9.99) and Annual ($99.99)
2. Annual option should show "Save 20%" badge
3. Highlight the Annual option as "Best Value"
4. Include a "Restore Purchases" button
5. Show proper loading states
6. Handle purchase errors gracefully

### Starter Code
```tsx
import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useRevenueCat } from '../hooks/useRevenueCat';

export const PaywallScreen = () => {
  // TODO: Implement the paywall
  return (
    <View style={styles.container}>
      {/* Your code here */}
    </View>
  );
};
```

### Solution Hints

<details>
<summary>Solution Structure</summary>

```tsx
const PaywallScreen = () => {
  const { offerings, purchasePackage, restorePurchases } = useRevenueCat();
  const [selectedPackage, setSelectedPackage] = useState(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  
  const handlePurchase = async () => {
    if (!selectedPackage) return;
    setIsPurchasing(true);
    try {
      await purchasePackage(selectedPackage);
    } catch (error) {
      // Show error
    } finally {
      setIsPurchasing(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Unlock Premium Features</Text>
      
      {/* Package Cards */}
      {offerings?.current?.availablePackages.map((pkg) => (
        <TouchableOpacity 
          key={pkg.identifier}
          style={[
            styles.packageCard,
            selectedPackage?.identifier === pkg.identifier && styles.selected
          ]}
          onPress={() => setSelectedPackage(pkg)}
        >
          <Text style={styles.packageName}>{pkg.identifier}</Text>
          <Text style={styles.packagePrice}>{pkg.localizedPriceString}</Text>
          {pkg.identifier === 'annual' && (
            <Text style={styles.bestValue}>⭐ Best Value</Text>
          )}
        </TouchableOpacity>
      ))}
      
      {/* Purchase Button */}
      <TouchableOpacity 
        style={styles.purchaseButton}
        onPress={handlePurchase}
        disabled={isPurchasing || !selectedPackage}
      >
        <Text style={styles.purchaseText}>
          {isPurchasing ? 'Processing...' : 'Subscribe'}
        </Text>
      </TouchableOpacity>
      
      {/* Restore Button */}
      <TouchableOpacity onPress={restorePurchases}>
        <Text style={styles.restoreText}>Restore Purchases</Text>
      </TouchableOpacity>
    </View>
  );
};
```
</details>

---

## Exercise 2: Feature Guard Implementation
**Difficulty: Intermediate | 20 Minutes**

---

### Task
Create a `RequireEntitlement` component that:

1. Checks if the user has the required entitlement
2. Shows a loading state while checking
3. Shows an upgrade prompt if access is denied
4. Shows the children if access is granted

### Starter Code
```tsx
interface RequireEntitlementProps {
  entitlementId: string;
  children: React.ReactNode;
  onUpgradePress?: () => void;
}

export const RequireEntitlement: React.FC<RequireEntitlementProps> = ({
  entitlementId,
  children,
  onUpgradePress,
}) => {
  // TODO: Implement the component
  return null;
};
```

### Solution Hints

<details>
<summary>Solution Structure</summary>

```tsx
export const RequireEntitlement: React.FC<RequireEntitlementProps> = ({
  entitlementId,
  children,
  onUpgradePress,
}) => {
  const { hasEntitlement } = useSubscription();
  const [hasAccess, setHasAccess] = useState<boolean | null>(null);
  
  useEffect(() => {
    const checkAccess = async () => {
      const access = await hasEntitlement(entitlementId);
      setHasAccess(access);
    };
    checkAccess();
  }, [entitlementId, hasEntitlement]);
  
  // Loading state
  if (hasAccess === null) {
    return <ActivityIndicator size="large" />;
  }
  
  // Access granted
  if (hasAccess) {
    return <>{children}</>;
  }
  
  // Access denied - show upgrade prompt
  return (
    <View style={styles.container}>
      <Text style={styles.lockIcon}>🔒</Text>
      <Text style={styles.title}>Premium Feature</Text>
      <Text style={styles.description}>
        Upgrade to access this premium feature.
      </Text>
      <TouchableOpacity 
        style={styles.upgradeButton}
        onPress={onUpgradePress || (() => navigateToPaywall())}
      >
        <Text style={styles.upgradeText}>Upgrade Now</Text>
      </TouchableOpacity>
    </View>
  );
};
```
</details>

---

# SECTION 4: COMPREHENSIVE FINAL EXAM

---

## Final Exam: RevenueCat Mastery
**Difficulty: Comprehensive | 50 Questions | 60 Minutes**

---

### Part A: Multiple Choice (25 Questions)
**Select the best answer for each question.**

**1. What is the primary purpose of RevenueCat?**

A) To replace Apple's App Store
B) To simplify cross-platform in-app purchase implementation
C) To design mobile app interfaces
D) To manage app store listings

<details>
<summary>Answer</summary>
**B** - RevenueCat simplifies cross-platform in-app purchase and subscription implementation by providing a unified SDK and API.

---

**2. Which component represents what users unlock when they subscribe?**

A) Product
B) Package
C) Offering
D) Entitlement

<details>
<summary>Answer</summary>
**D** - Entitlements represent the premium features users unlock (e.g., "premium_workouts", "nutrition_tracking").

---

**3. Where must Products be created before using them in RevenueCat?**

A) Only in the RevenueCat dashboard
B) In App Store Connect and/or Google Play Console
C) In RevenueCat's API
D) In the app's source code

<details>
<summary>Answer</summary>
**B** - Products must be created in the respective app stores first. RevenueCat syncs with these existing products.

---

**4. Which API key is safe to include in your mobile app's source code?**

A) Secret API Key
B) Webhook API Key
C) Public API Key
D) All of the above

<details>
<summary>Answer</summary>
**C** - The Public API Key is designed to be included in client-side code. Secret and Webhook keys should be kept server-side.

---

**5. What is the purpose of the `addCustomerInfoUpdateListener` method?**

A) To check if the user is logged in
B) To receive real-time updates when subscription status changes
C) To send push notifications
D) To track screen views

<details>
<summary>Answer</summary>
**B** - This listener provides real-time CustomerInfo updates when subscription changes occur (purchase, renewal, etc.).

---

**6. What is the recommended way to handle a PURCHASE_CANCELLED error?**

A) Show a generic technical error
B) Show a user-friendly message and allow the user to try again
C) Automatically retry the purchase
D) Crash the app

<details>
<summary>Answer</summary>
**B** - Show a friendly message like "You cancelled the purchase. No charges were made." and let the user try again.

---

**7. Which of the following is NOT a standard purchase flow state?**

A) Idle
B) Processing
C) Success
D) Archiving

<details>
<summary>Answer</summary>
**D** - Archiving is not a standard purchase state. Standard states are idle, loading/processing, success, error, and restoring.

---

**8. True or False: Apple requires a restore purchases button in all apps with subscriptions.**

A) True
B) False

<details>
<summary>Answer</summary>
**A** - True. Apple's App Store Review Guidelines require a restore purchases feature for apps with subscriptions.

---

**9. What is account migration in RevenueCat?**

A) Moving a user's subscription to a new device
B) Transferring a subscription from an anonymous user to an authenticated account
C) Changing subscription plans
D) Creating a new user account

<details>
<summary>Answer</summary>
**B** - Account migration transfers subscriptions from anonymous users to authenticated accounts, enabling cross-device access.

---

**10. Which method is used to identify a user to RevenueCat?**

A) setUserEmail()
B) setAppUserID()
C) identifyUser()
D) setUserId()

<details>
<summary>Answer</summary>
**B** - setAppUserID() is the RevenueCat method for identifying users.

---

**11. What should happen when resetAppUserID() is called?**

A) The user's subscription is cancelled
B) RevenueCat clears the current user ID and generates a new anonymous ID
C) The user is permanently banned
D) All purchases are refunded

<details>
<summary>Answer</summary>
**B** - resetAppUserID() clears the current user ID and generates a new anonymous ID, typically used on logout.

---

**12. What is the primary purpose of RevenueCat webhooks?**

A) To send notifications to users
B) To notify your server of subscription events
C) To display advertisements
D) To track downloads

<details>
<summary>Answer</summary>
**B** - Webhooks send real-time notifications to your server when subscription events occur.

---

**13. Why is webhook signature verification important?**

A) It makes the data easier to read
B) It ensures the webhook request is from RevenueCat, not an attacker
C) It removes sensitive data
D) It speeds up processing

<details>
<summary>Answer</summary>
**B** - Signature verification prevents attackers from sending fake webhook requests by confirming the request's origin.

---

**14. What HTTP status code should your webhook endpoint return to prevent RevenueCat from retrying?**

A) 200 OK
B) 400 Bad Request
C) 500 Internal Server Error
D) 301 Moved Permanently

<details>
<summary>Answer</summary>
**A** - Return 200 OK to indicate successful receipt, even if processing fails internally, to prevent retries.

---

**15. Which event type indicates a user has cancelled their subscription?**

A) INITIAL_PURCHASE
B) RENEWAL
C) CANCELLATION
D) REFUND

<details>
<summary>Answer</summary>
**C** - CANCELLATION events are sent when a user cancels their subscription.

---

**16. What happens during a grace period?**

A) The user loses access immediately
B) The user keeps access while resolving billing issues
C) The subscription is automatically renewed
D) The user gets a refund

<details>
<summary>Answer</summary>
**B** - During the grace period, users retain access while the system attempts to resolve payment issues.

---

**17. What is the key metric that measures the percentage of users who stop subscribing?**

A) MRR
B) ARPU
C) Churn Rate
D) LTV

<details>
<summary>Answer</summary>
**C** - Churn Rate measures the percentage of subscribers who cancel their subscriptions.

---

**18. What is price anchoring in paywall design?**

A) Hiding the price until the user subscribes
B) Making a specific option more valuable by showing it alongside other options
C) Increasing the price after purchase
D) Showing the price in a different currency

<details>
<summary>Answer</summary>
**B** - Price anchoring makes an option more attractive by showing it relative to other options (e.g., "Save 20% with annual").

---

**19. What should be included in your paywall's terms and conditions section?**

A) Only the price
B) Links to Terms of Service and Privacy Policy
C) Developer contact information
D) Subscription countdown timer

<details>
<summary>Answer</summary>
**B** - App store guidelines require links to your Terms of Service and Privacy Policy.

---

**20. How should you handle the EXPIRATION webhook event?**

A) Immediately delete the user's account
B) Update the user's status to "expired" and revoke premium access
C) Send a "why did you leave" survey
D) Automatically renew the subscription

<details>
<summary>Answer</summary>
**B** - Update the user's status to expired and revoke premium access. The subscription period has ended.

---

**21. What is the correct way to check if a user has a specific entitlement?**

A) Check if the user is logged in
B) Check if the entitlement exists in customerInfo.entitlements.active
C) Check the user's email
D) Check the device's purchase history

<details>
<summary>Answer</summary>
**B** - The entitlement is active if it exists in customerInfo.entitlements.active.

---

**22. What is the recommended maximum age for cached subscription data?**

A) 1 hour
B) 12 hours
C) 24 hours
D) 7 days

<details>
<summary>Answer</summary>
**C** - Cached data should typically expire after 24 hours to balance offline access with data freshness.

---

**23. Which event type is sent when a user receives a refund?**

A) CANCELLATION
B) REFUND
C) EXPIRATION
D) BILLING_ISSUE

<details>
<summary>Answer</summary>
**B** - REFUND events are sent when a refund is processed through the app store.

---

**24. What is the purpose of the `setAppUserID` method?**

A) To set the user's email
B) To associate a user with their purchases
C) To change the user's password
D) To create a new user account

<details>
<summary>Answer</summary>
**B** - setAppUserID associates a user's identity with their purchases, enabling cross-device access.

---

**25. Which component groups packages for display to users?**

A) Product
B) Package
C) Offering
D) Entitlement

<details>
<summary>Answer</summary>
**C** - Offerings group packages for display to users on your paywall.

---

### Part B: Scenario Analysis (25 Questions)
**Read each scenario and select the best answer.**

---

**Scenario 1: Free Trial User**
*Maria signs up for a 7-day free trial. She loves the app but forgets to cancel. The trial ends and her credit card is charged.*

**26. What should happen on the day of the trial expiration?**

A) The app should automatically cancel the trial
B) The app should charge the user's card and grant full access
C) The app should show an error
D) The app should delete her account

<details>
<summary>Answer</summary>
**B** - RevenueCat automatically handles the transition from trial to paid subscription. The user is charged and keeps access.

---

**27. Maria notices the charge on her card and requests a refund. What event does RevenueCat send?**

A) CANCELLATION
B) REFUND
C) EXPIRATION
D) BILLING_ISSUE

<details>
<summary>Answer</summary>
**B** - REFUND events are sent when refunds are processed.

---

**28. What should Maria's access status be after the refund?**

A) She should keep access
B) Access should be revoked
C) Access should be extended
D) She should get a free month

<details>
<summary>Answer</summary>
**B** - Access should be revoked after the refund is processed through the app store.

---

**Scenario 2: Cross-Device User**
*John subscribes on his iPhone. He also has an iPad and wants to access premium features there.*

**29. What should John do to access his subscription on the iPad?**

A) Purchase a separate subscription for the iPad
B) Use the same App Store account (iOS automatically syncs)
C) Contact support
D) Buy a new subscription

<details>
<summary>Answer</summary>
**B** - App Store purchases are tied to the App Store account. Using the same account on the iPad automatically gives access.

---

**30. If John's subscription was purchased through RevenueCat, what happens when he opens the app on iPad?**

A) He needs to restore purchases
B) RevenueCat syncs and automatically grants access
C) He needs to repurchase
D) He needs to enter a code

<details>
<summary>Answer</summary>
**B** - RevenueCat syncs across devices with the same App User ID. Customers are automatically granted access.

---

**Scenario 3: Anonymous to Authenticated User**
*Sara purchased a subscription while using the app as a guest. She now wants to create an account to access the subscription on other devices.*

**31. What method should be called to transfer the subscription?**

A) transferSubscription()
B) setAppUserID()
C) migrateUser()
D) linkSubscription()

<details>
<summary>Answer</summary>
**B** - setAppUserID() transfers purchases from the anonymous ID to the new user ID.

---

**32. What is the correct order of operations?**

A) Create account → Call setAppUserID() → Refresh CustomerInfo
B) Call setAppUserID() → Create account → Show success
C) Refresh CustomerInfo → Create account → Call setAppUserID()
D) Create account → Show success → Call setAppUserID()

<details>
<summary>Answer</summary>
**A** - Create the user account first, then call setAppUserID() to transfer the subscription, then refresh CustomerInfo to confirm.

---

**33. After the transfer, what should happen?**

A) Sara should lose access
B) Sara should have access across all devices where she logs in
C) Sara should be asked to repurchase
D) Sara should get a refund

<details>
<summary>Answer</summary>
**B** - The subscription is now tied to Sara's account, enabling access on any device where she logs in.

---

**Scenario 4: Failed Payment**
*Tom's monthly subscription fails to renew because his credit card expired.*

**34. What event does RevenueCat send first?**

A) CANCELLATION
B) BILLING_ISSUE
C) EXPIRATION
D) REFUND

<details>
<summary>Answer</summary>
**B** - BILLING_ISSUE events are sent when a payment fails.

---

**35. What happens during the grace period?**

A) Tom loses access immediately
B) Tom keeps access while resolving payment
C) Tom gets a free month
D) Tom's subscription is automatically cancelled

<details>
<summary>Answer</summary>
**B** - During the grace period, Tom keeps access while the system attempts to resolve the payment issue.

---

**36. If Tom doesn't update his payment method, what event is sent when his access ends?**

A) CANCELLATION
B) EXPIRATION
C) REFUND
D) BILLING_ISSUE

<details>
<summary>Answer</summary>
**B** - EXPIRATION events are sent when the subscription expires.

---

**Scenario 5: Churn Prevention**
*Emma has been a subscriber for 6 months. She submits a cancellation request.*

**37. What is the best practice when Emma initiates cancellation?**

A) Immediately cancel the subscription
B) Show a retention offer and ask why she's leaving
C) Delete her account
D) Send a survey after cancellation

<details>
<summary>Answer</summary>
**B** - Ask for feedback and consider offering a retention discount or alternative plan.

---

**38. When should Emma's access be revoked?**

A) Immediately upon cancellation
B) At the end of the current billing period
C) After 30 days
D) When the cancellation webhook is received

<details>
<summary>Answer</summary>
**B** - Users should keep access until the end of their paid period.

---

**39. If Emma accepts a win-back offer 10 days after cancellation, what should happen?**

A) She should get a new subscription from scratch
B) The win-back offer should be applied to a new subscription
C) Her original subscription should be reactivated
D) She should pay the full price

<details>
<summary>Answer</summary>
**B** - Win-back offers typically apply to new subscriptions with a special discount.

---

**Scenario 6: A/B Testing**
*FitTrack Pro wants to test two different paywall designs.*

**40. What should be tested?**

A) Different colors
B) Different pricing, messaging, and layouts
C) Different app icons
D) Different loading animations

<details>
<summary>Answer</summary>
**B** - Test elements that impact conversion: pricing, messaging, layout, trial lengths, and offers.

---

**41. What is the most important metric to track for paywall A/B testing?**

A) App downloads
B) Conversion rate
C) Daily active users
D) Session length

<details>
<summary>Answer</summary>
**B** - Conversion rate is the key metric for paywall A/B testing.

---

**42. How long should an A/B test typically run?**

A) 1 day
B) 1 week
C) 1 month
D) Until statistical significance is reached

<details>
<summary>Answer</summary>
**D** - Run tests until you achieve statistical significance. This may take days or weeks depending on traffic.

---

**Scenario 7: Production Monitoring**
*The FitTrack Pro team notices MRR has dropped 15% in the last week.*

**43. What should be the first step in investigating?**

A) Panic
B) Check webhook logs and RevenueCat dashboard
C) Email all users
D) Change all prices

<details>
<summary>Answer</summary>
**B** - Check webhook logs and RevenueCat dashboard for unusual patterns in subscription events.

---

**44. Which metric would help identify if the drop is due to increased churn?**

A) ARPU
B) LTV
C) Churn Rate
D) Conversion Rate

<details>
<summary>Answer</summary>
**C** - Churn Rate would indicate if more users than usual are cancelling.

---

**45. What automated monitoring should be in place?**

A) None - just manual checks
B) Alerts for revenue drops, churn spikes, and technical errors
C) Weekly email reports only
D) Monthly dashboard reviews

<details>
<summary>Answer</summary>
**B** - Automated alerts for revenue drops, churn spikes, and technical errors enable quick response to issues.

---

**Scenario 8: Offline Mode**
*Mia is in a tunnel with no internet but wants to access her premium workouts.*

**46. Can Mia access premium workouts without internet?**

A) No - RevenueCat requires internet
B) Yes - if subscription state is cached locally
C) No - the app won't open
D) Yes - but only for 5 minutes

<details>
<summary>Answer</summary>
**B** - Cached subscription state allows offline access to premium features.

---

**47. How long does cached subscription data remain valid?**

A) 1 hour
B) 24 hours
C) 7 days
D) Indefinitely

<details>
<summary>Answer</summary>
**B** - 24 hours is a common cache expiry time, but apps can implement different strategies.

---

**48. What should happen when Mia reconnects to the internet?**

A) The app should refresh CustomerInfo
B) The app should do nothing
C) The app should log her out
D) The app should delete cached data

<details>
<summary>Answer</summary>
**A** - The app should refresh CustomerInfo to ensure the subscription state is up-to-date.

---

**49. If Mia's subscription expired during the offline period, what should happen when she reconnects?**

A) She should keep access
B) Access should be revoked and she should be prompted to upgrade
C) She should be logged out
D) The app should crash

<details>
<summary>Answer</summary>
**B** - When reconnected, CustomerInfo should update to show the expired subscription, and the app should revoke access with an upgrade prompt.

---

**Scenario 9: Feature Gating**
*FitTrack Pro wants to show a "Premium" badge for users with the "premium_workouts" entitlement.*

**50. What's the correct way to implement this?**

A) Check if the user is logged in
B) Check if the entitlement exists in customerInfo.entitlements.active
C) Check the user's email
D) Show the badge to all users

<details>
<summary>Answer</summary>
**B** - Check if the entitlement exists in customerInfo.entitlements.active. If yes, show the badge; if no, don't.

---

### Answer Key: Comprehensive Final Exam

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|----|--------|
| 1 | B | 11 | B | 21 | B | 31 | B | 41 | B |
| 2 | D | 12 | B | 22 | C | 32 | A | 42 | D |
| 3 | B | 13 | B | 23 | B | 33 | B | 43 | B |
| 4 | C | 14 | A | 24 | B | 34 | B | 44 | C |
| 5 | B | 15 | C | 25 | C | 35 | B | 45 | B |
| 6 | B | 16 | B | 26 | B | 36 | B | 46 | B |
| 7 | D | 17 | C | 27 | B | 37 | B | 47 | B |
| 8 | A | 18 | B | 28 | B | 38 | B | 48 | A |
| 9 | B | 19 | B | 29 | B | 39 | B | 49 | B |
| 10 | B | 20 | B | 30 | B | 40 | B | 50 | B |

---

# SECTION 5: ANSWER KEY SUMMARY

---

## Quiz Answer Keys at a Glance

### Quiz 1: RevenueCat Core Concepts
1. B
2. C
3. B
4. B
5. B
6. B
7. B
8. C
9. B
10. C
11. False
12. True
13. False
14. False
15. True

### Quiz 2: Paywall & Purchase Flow
1. B
2. B
3. B
4. D
5. B
6. C
7. B
8. A
9. B
10. B
11. B
12. C
13. B
14. B
15. B

### Quiz 3: Subscription State Management
1. B
2. B
3. D
4. B
5. D
6. B
7. C
8. A
9. B
10. C
11. B
12. B
13. A
14. B
15. B

### Quiz 4: Webhooks & Backend Integration
1. B
2. B
3. A
4. C
5. B
6. B
7. B
8. A
9. B
10. B
11. B
12. A
13. B
14. B
15. B

---

# SECTION 6: COMPREHENSIVE PRACTICE EXAM

## Practice Exam: Complete RevenueCat Mastery
**100 Questions | 2 Hours | Comprehensive Assessment**

This practice exam covers all topics from the RevenueCat Masterclass series. Use it to test your knowledge before implementing RevenueCat in production.

---

### Part A: Foundations (20 Questions)

**1. What are the four pillars of RevenueCat's architecture?**

A) Products, Prices, Plans, Payments
B) Products, Packages, Offerings, Entitlements
C) Products, Purchases, Packages, Plans
D) Prices, Payments, Plans, Purchases

<details>
<summary>Answer</summary>
**B** - Products, Packages, Offerings, Entitlements are the four core concepts.

---

**2. Which of the following is the correct relationship between Products and Packages?**

A) Products contain Packages
B) Packages map to Products
C) Products and Packages are the same
D) Packages contain Products

<details>
<summary>Answer</summary>
**B** - Packages map to Products (e.g., the "monthly" Package maps to `com.app.monthly` on iOS and `com.app.monthly` on Android).

---

**3. Where do you create Entitlements?**

A) App Store Connect
B) Google Play Console
C) RevenueCat Dashboard
D) In the app's source code

<details>
<summary>Answer</summary>
**C** - Entitlements are created in the RevenueCat Dashboard.

---

**4. Which RevenueCat component is a collection of Packages presented to users?**

A) Product
B) Package
C) Offering
D) Entitlement

<details>
<summary>Answer</summary>
**C** - Offerings are groups of Packages presented to users (e.g., "default" offering with Monthly and Annual plans).

---

**5. What is the main benefit of using RevenueCat over building native IAP?**

A) It's free
B) It provides a unified API and handles cross-platform complexity
C) It replaces the need for app store accounts
D) It automatically creates app store products

<details>
<summary>Answer</summary>
**B** - RevenueCat provides a unified API and handles cross-platform complexity, receipt validation, and subscription management.

---

**6. True or False: RevenueCat can be used without creating products in app stores.**

<details>
<summary>Answer</summary>
**False** - Products must exist in App Store Connect and/or Google Play Console before they can be used with RevenueCat.

---

**7. What is the primary function of a Public API Key?**

A) Server-side operations
B) Client-side SDK initialization
C) Webhook verification
D) Database encryption

<details>
<summary>Answer</summary>
**B** - The Public API Key is used for client-side SDK initialization.

---

**8. Which API key should never be stored in client-side code?**

A) Public API Key
B) Secret API Key
C) Both A and B
D) Neither A nor B

<details>
<summary>Answer</summary>
**B** - The Secret API Key should be kept server-side and never included in client code.

---

**9. What does CustomerInfo contain?**

A) User's login credentials
B) All subscription and entitlement data
C) App usage analytics
D) Push notification tokens

<details>
<summary>Answer</summary>
**B** - CustomerInfo contains all subscription data, including active entitlements, expiration dates, and purchase history.

---

**10. How does RevenueCat handle receipt validation?**

A) It doesn't - you must validate receipts yourself
B) It automatically validates receipts with Apple and Google
C) It only validates iOS receipts
D) It uses a third-party service

<details>
<summary>Answer</summary>
**B** - RevenueCat automatically validates receipts with both Apple and Google app stores.

---

**11. What is the recommended way to initialize RevenueCat?**

A) Call Purchases.configure() in every screen
B) Call Purchases.configure() once at app launch
C) Call Purchases.configure() only before purchases
D) Call Purchases.configure() in a background thread

<details>
<summary>Answer</summary>
**B** - Call Purchases.configure() once at app launch.

---

**12. What happens if you call Purchases.configure() without an appUserID?**

A) The app crashes
B) RevenueCat generates an anonymous user ID
C) RevenueCat uses the device ID
D) RevenueCat waits for a user ID

<details>
<summary>Answer</summary>
**B** - RevenueCat generates an anonymous user ID if none is provided.

---

**13. Which method is used to get the user's current subscription status?**

A) Purchases.getStatus()
B) Purchases.getCustomerInfo()
C) Purchases.getUserInfo()
D) Purchases.getSubscriptionInfo()

<details>
<summary>Answer</summary>
**B** - Purchases.getCustomerInfo() returns all subscription data for the current user.

---

**14. What is the purpose of the `addCustomerInfoUpdateListener` method?**

A) To listen for app state changes
B) To receive real-time subscription updates
C) To track user navigation
D) To log analytics events

<details>
<summary>Answer</summary>
**B** - The listener provides real-time updates when CustomerInfo changes.

---

**15. How does RevenueCat support offline access?**

A) It doesn't support offline access
B) It caches subscription state locally
C) It stores data in the app store cache
D) It uses offline receipts

<details>
<summary>Answer</summary>
**B** - RevenueCat caches subscription state locally for offline access.

---

**16. What is the recommended cache expiration time for subscription data?**

A) 1 hour
B) 24 hours
C) 7 days
D) Indefinitely

<details>
<summary>Answer</summary>
**B** - 24 hours is a common recommendation for cache expiration.

---

**17. Which component represents a single purchasable item in the app store?**

A) Entitlement
B) Offering
C) Package
D) Product

<details>
<summary>Answer</summary>
**D** - Product represents a single purchasable item (e.g., "Monthly Subscription - $9.99").

---

**18. What is the relationship between Offerings and Entitlements?**

A) Offerings contain Entitlements
B) Entitlements are granted through Offerings
C) There is no direct relationship
D) Offerings and Entitlements are the same

<details>
<summary>Answer</summary>
**B** - Users purchase Offerings (Packages) which grant them Entitlements.

---

**19. What is the purpose of the `setAppUserID` method?**

A) To set the user's display name
B) To associate a user with their purchases
C) To change the user's password
D) To create a new user account

<details>
<summary>Answer</summary>
**B** - setAppUserID associates a user's identity with their purchases for cross-device access.

---

**20. What happens when you call `resetAppUserID`?**

A) The user is logged out
B) RevenueCat clears the current user ID and generates a new anonymous ID
C) All purchases are deleted
D) The user's account is deleted

<details>
<summary>Answer</summary>
**B** - resetAppUserID clears the current user ID and generates a new anonymous ID.

---

### Part B: Paywall & Purchase Flow (20 Questions)

**21. What are the three essential elements of a conversion-optimized paywall?**

A) Price, description, and contact information
B) Value proposition, pricing options, and clear call-to-action
C) Images, animations, and sound effects
D) Newsletter signup, social links, and ratings

<details>
<summary>Answer</summary>
**B** - Value proposition, pricing options, and clear call-to-action are essential.

---

**22. Which paywall placement strategy typically has the highest conversion rate?**

A) Settings paywall
B) Contextual paywall
C) Onboarding paywall
D) Post-trial paywall

<details>
<summary>Answer</summary>
**C** - Onboarding paywalls typically have the highest conversion rates because users are most motivated.

---

**23. What is the purpose of highlighting the "Best Value" option?**

A) To confuse users
B) To guide users toward the most profitable option
C) To hide other options
D) To make the app look better

<details>
<summary>Answer</summary>
**B** - Highlighting the "Best Value" option guides users to the annual plan, which has higher LTV.

---

**24. What should you display when a user cancels a purchase mid-flow?**

A) A generic technical error
B) A user-friendly confirmation message
C) Nothing
D) A "why did you cancel" survey

<details>
<summary>Answer</summary>
**B** - Show a friendly message acknowledging the cancellation.

---

**25. Which of the following is NOT a purchase flow state?**

A) Idle
B) Processing
C) Restoring
D) Archiving

<details>
<summary>Answer</summary>
**D** - Archiving is not a standard purchase state.

---

**26. What error code indicates the user cancelled the purchase?**

A) NETWORK_ERROR
B) PURCHASE_CANCELLED
C) PRODUCT_NOT_AVAILABLE
D) INVALID_CREDENTIALS

<details>
<summary>Answer</summary>
**B** - PURCHASE_CANCELLED indicates the user cancelled the purchase.

---

**27. True or False: Apple requires a "Restore Purchases" button in all apps with subscriptions.**

<details>
<summary>Answer</summary>
**True** - Apple's App Store Review Guidelines require a restore purchases feature.

---

**28. What is the correct way to handle a successful purchase?**

A) Show a success message and transition to the main app
B) Immediately dismiss the paywall with no feedback
C) Ask the user to rate the app
D) Show a discount code

<details>
<summary>Answer</summary>
**A** - Show a success message and transition to the main app.

---

**29. Which error type is appropriate when a user has no internet connection?**

A) PURCHASE_CANCELLED
B) NETWORK_ERROR
C) PRODUCT_NOT_AVAILABLE
D) INVALID_CREDENTIALS

<details>
<summary>Answer</summary>
**B** - NETWORK_ERROR should be shown with a "check internet connection" message.

---

**30. What is the best practice for handling free trials?**

A) Hide the auto-renewal information
B) Clearly display trial duration and auto-renewal terms
C) Only mention the trial after purchase
D) Make the trial opt-out instead of opt-in

<details>
<summary>Answer</summary>
**B** - App store guidelines require clear disclosure of trial terms.

---

**31. What should happen when a user's purchase succeeds but no entitlements are granted?**

A) Show "Purchase Complete" and ignore the entitlements
B) Show a message explaining the issue and suggest restoring purchases
C) Crash the app
D) Automatically grant all entitlements

<details>
<summary>Answer</summary>
**B** - This edge case should be handled with a friendly message and restore suggestion.

---

**32. What is price anchoring?**

A) Hiding the price until the user subscribes
B) Making an option more valuable by showing it alongside other options
C) Increasing the price after purchase
D) Showing the price in a different currency

<details>
<summary>Answer</summary>
**B** - Price anchoring makes options more attractive relative to each other.

---

**33. What is the recommended number of options on a paywall?**

A) 1
B) 2-3
C) 5+
D) As many as possible

<details>
<summary>Answer</summary>
**B** - 2-3 options is optimal to avoid decision paralysis.

---

**34. Which element builds trust on the paywall?**

A) High prices
B) Social proof (testimonials, ratings)
C) Complex terminology
D) Hidden terms

<details>
<summary>Answer</summary>
**B** - Social proof like testimonials and ratings builds trust.

---

**35. What is the purpose of the restore purchases flow?**

A) To get refunds
B) To recover previous purchases on a new device
C) To cancel subscriptions
D) To change plans

<details>
<summary>Answer</summary>
**B** - Restore purchases recovers previous purchases on a new device or after reinstall.

---

**36. What should you do when a purchase is processing?**

A) Show a loading state
B) Do nothing
C) Close the app
D) Show an error

<details>
<summary>Answer</summary>
**A** - Show a loading state while the purchase is processing.

---

**37. Which of the following should be included in the paywall's terms?**

A) Only the price
B) Links to Terms of Service and Privacy Policy
C) Developer's contact information
D) Subscription countdown timer

<details>
<summary>Answer</summary>
**B** - App store guidelines require links to Terms of Service and Privacy Policy.

---

**38. What is a product identifier in RevenueCat?**

A) A random string generated by RevenueCat
B) The unique ID for the product in the app store
C) The user's email address
D) The app's bundle ID

<details>
<summary>Answer</summary>
**B** - The product identifier is the unique ID from the app store.

---

**39. How do you check if a user has an active subscription?**

A) Check customerInfo.entitlements.active
B) Check if the user is logged in
C) Check the user's email
D) Check the device's purchase history

<details>
<summary>Answer</summary>
**A** - Check customerInfo.entitlements.active for active entitlements.

---

**40. What should be shown when a free user tries to access a premium feature?**

A) Nothing - they should be redirected automatically
B) An upgrade prompt explaining the feature requires a subscription
C) A technical error message
D) A survey asking why they want the feature

<details>
<summary>Answer</summary>
**B** - Show a friendly upgrade prompt explaining the feature requires a subscription.

---

### Part C: State Management & Access Control (20 Questions)

**41. What is the primary benefit of using React Context for subscription state?**

A) It makes the code faster
B) It provides a global source of truth accessible to any component
C) It automatically handles RevenueCat API calls
D) It reduces bundle size

<details>
<summary>Answer</summary>
**B** - React Context provides a centralized state accessible to any component.

---

**42. What is the correct way to check if a user has a specific entitlement?**

A) Check if the user is logged in
B) Check if the entitlement exists in customerInfo.entitlements.active
C) Check if the user's email is verified
D) Check the device's purchase history

<details>
<summary>Answer</summary>
**B** - Check customerInfo.entitlements.active for the entitlement.

---

**43. Which component should you use to protect an entire screen?**

A) EntitlementGate
B) RequireEntitlement
C) Conditional check
D) Navigation guard

<details>
<summary>Answer</summary>
**B** - RequireEntitlement is used to protect entire screens.

---

**44. What is account migration?**

A) Moving a subscription to a new device
B) Transferring a subscription from anonymous to authenticated
C) Changing subscription plans
D) Creating a new account

<details>
<summary>Answer</summary>
**B** - Account migration transfers subscriptions from anonymous to authenticated.

---

**45. Why is caching subscription state important?**

A) It reduces API calls
B) It provides offline access
C) It speeds up app launch
D) All of the above

<details>
<summary>Answer</summary>
**D** - Caching provides all three benefits.

---

**46. Which method sets the user's identity for RevenueCat?**

A) setUserEmail()
B) setAppUserID()
C) identifyUser()
D) setUserId()

<details>
<summary>Answer</summary>
**B** - setAppUserID() is the RevenueCat identity method.

---

**47. What is the difference between customerInfo.entitlements.active and .all?**

A) active contains current entitlements; all contains all entitlements
B) all contains current entitlements; active contains all entitlements
C) There is no difference
D) active is for iOS, all is for Android

<details>
<summary>Answer</summary>
**A** - active contains current entitlements; all contains all entitlements (including expired).

---

**48. What should happen when an authenticated user logs in and has an existing subscription?**

A) Nothing - the subscription is already linked
B) Call setAppUserID() to link the subscription to their account
C) Create a new subscription for the user
D) Cancel the existing subscription

<details>
<summary>Answer</summary>
**B** - Call setAppUserID() to link the subscription to the authenticated account.

---

**49. What is the recommended cache expiry time?**

A) 1 hour
B) 24 hours
C) 7 days
D) 30 days

<details>
<summary>Answer</summary>
**B** - 24 hours is the recommended cache expiry time.

---

**50. Which entitlement check is more secure?**

A) Client-side only
B) Server-side only
C) Client-side with server-side verification
D) Neither is secure

<details>
<summary>Answer</summary>
**C** - Client-side with server-side verification provides both UX and security.

---

**51. What is the purpose of the `addCustomerInfoUpdateListener`?**

A) To detect when the app is opened
B) To receive real-time subscription updates
C) To log analytics events
D) To send push notifications

<details>
<summary>Answer</summary>
**B** - The listener provides real-time subscription updates.

---

**52. What should be the loading state behavior when checking entitlements?**

A) Show nothing until complete
B) Show a loading spinner while checking
C) Assume access while checking
D) Show a generic error

<details>
<summary>Answer</summary>
**B** - Show a loading spinner while checking entitlements.

---

**53. What is the correct way to handle a user who purchased while anonymous and then creates an account?**

A) Have them repurchase
B) Transfer the subscription using setAppUserID()
C) Ignore the purchase
D) Cancel the purchase

<details>
<summary>Answer</summary>
**B** - Transfer the subscription using setAppUserID().

---

**54. How should premium features be gated in the UI?**

A) Only check on the server
B) Check entitlement and show/hide accordingly
C) Always show all features and handle errors
D) Show features based on device type

<details>
<summary>Answer</summary>
**B** - Check entitlements and show/hide UI elements accordingly.

---

**55. What happens when a user cancels their subscription?**

A) They lose access immediately
B) They keep access until the expiration date
C) Their account is deleted
D) They get a partial refund

<details>
<summary>Answer</summary>
**B** - Users keep access until the end of their paid period.

---

**56. What is the purpose of the `resetAppUserID` method?**

A) To delete the user's account
B) To clear the user ID and generate a new anonymous ID
C) To cancel all subscriptions
D) To log the user out of the app

<details>
<summary>Answer</summary>
**B** - resetAppUserID clears the user ID and generates a new anonymous ID.

---

**57. What's the best practice for checking entitlement before an API call?**

A) Only check client-side
B) Only check server-side
C) Check both client-side AND server-side
D) Don't check at all

<details>
<summary>Answer</summary>
**C** - Check both client-side (UX) and server-side (security).

---

**58. What is a grace period?**

A) A period where users get free access
B) A period where users keep access while resolving payment issues
C) A discount period
D) A trial period

<details>
<summary>Answer</summary>
**B** - Grace period is where users keep access while resolving payment issues.

---

**59. What should the app show when a user tries to access a gated feature without entitlement?**

A) A technical error
B) An upgrade prompt
C) Nothing
D) A loading spinner

<details>
<summary>Answer</summary>
**B** - Show an upgrade prompt explaining the feature requires a subscription.

---

**60. What is the difference between anonymous and authenticated users in RevenueCat?**

A) Anonymous users cannot purchase
B) Authenticated users have their purchases synced across devices
C) Anonymous users get all features for free
D) There is no difference

<details>
<summary>Answer</summary>
**B** - Authenticated users have their purchases synced across devices.

---

### Part D: Webhooks & Backend (20 Questions)

**61. What is the primary purpose of RevenueCat webhooks?**

A) To send notifications to users
B) To notify your server of subscription events
C) To display advertisements
D) To track downloads

<details>
<summary>Answer</summary>
**B** - Webhooks notify your server of subscription events.

---

**62. Why is webhook signature verification important?**

A) It makes data easier to read
B) It ensures the request is from RevenueCat
C) It removes sensitive data
D) It speeds up processing

<details>
<summary>Answer</summary>
**B** - Signature verification confirms the request originated from RevenueCat.

---

**63. What HTTP status code should your webhook return to prevent retries?**

A) 200 OK
B) 400 Bad Request
C) 500 Internal Server Error
D) 301 Moved Permanently

<details>
<summary>Answer</summary>
**A** - Return 200 OK to prevent RevenueCat retries.

---

**64. Which is NOT a RevenueCat webhook event type?**

A) INITIAL_PURCHASE
B) RENEWAL
C) USER_CLICKED
D) CANCELLATION

<details>
<summary>Answer</summary>
**C** - USER_CLICKED is not a RevenueCat webhook event.

---

**65. What should you do when a CANCELLATION webhook is received?**

A) Immediately revoke all access
B) Update database and prepare for win-back
C) Delete the user's account
D) Send a "why are you leaving" survey

<details>
<summary>Answer</summary>
**B** - Update database and prepare for win-back campaigns.

---

**66. When should you revoke premium access?**

A) Immediately upon cancellation
B) When the subscription expires
C) When the refund is processed
D) When the user requests it

<details>
<summary>Answer</summary>
**B** - Revoke access when the subscription expires.

---

**67. What is idempotency?**

A) Making the code faster
B) Processing an event multiple times without negative side effects
C) Encrypting the webhook data
D) Validating the signature

<details>
<summary>Answer</summary>
**B** - Idempotency ensures processing an event multiple times doesn't cause issues.

---

**68. Which header does RevenueCat use for webhook signatures?**

A) X-Webhook-Signature
B) Authorization
C) X-API-Key
D) Content-Type

<details>
<summary>Answer</summary>
**A** - RevenueCat uses X-Webhook-Signature.

---

**69. How should you handle webhook processing errors?**

A) Return a 500 status code
B) Return a 200 status code and log internally
C) Ignore the error
D) Return a 400 status code

<details>
<summary>Answer</summary>
**B** - Return 200 to prevent retries and log the error internally.

---

**70. What happens during a grace period?**

A) Users lose access immediately
B) Users keep access while resolving billing issues
C) Subscriptions are automatically renewed
D) Users get refunds

<details>
<summary>Answer</summary>
**B** - Users keep access while resolving billing issues.

---

**71. What event is sent when a user receives a refund?**

A) CANCELLATION
B) REFUND
C) EXPIRATION
D) BILLING_ISSUE

<details>
<summary>Answer</summary>
**B** - REFUND events are sent for refunds.

---

**72. What should happen with a renewal webhook?**

A) Create a new subscription
B) Update the expiration date
C) Cancel the subscription
D) Send a welcome email

<details>
<summary>Answer</summary>
**B** - Update the expiration date with the new renewal date.

---

**73. What is the purpose of the `managementURL` property?**

A) To cancel subscriptions
B) To let users manage their subscription
C) To change payment methods
D) To view purchase history

<details>
<summary>Answer</summary>
**B** - managementURL allows users to manage their subscription.

---

**74. Which webhook event should trigger a win-back campaign?**

A) INITIAL_PURCHASE
B) RENEWAL
C) EXPIRATION
D) REFUND

<details>
<summary>Answer</summary>
**C** - EXPIRATION events should trigger win-back campaigns.

---

**75. What should you do when a webhook signature is invalid?**

A) Process the event anyway
B) Return a 401 Unauthorized response
C) Log and process
D) Send an email and process

<details>
<summary>Answer</summary>
**B** - Return 401 Unauthorized for invalid signatures.

---

**76. How should you handle duplicate webhook events?**

A) Process both events
B) Use idempotency to prevent duplicate processing
C) Ignore all duplicates
D) Crash the server

<details>
<summary>Answer</summary>
**B** - Use idempotency to prevent duplicate processing.

---

**77. What is the BILLING_ISSUE event used for?**

A) User cancelled
B) Payment failed
C) Subscription expired
D) Refund processed

<details>
<summary>Answer</summary>
**B** - BILLING_ISSUE indicates a payment failure.

---

**78. What should happen when a GRACE_PERIOD event is received?**

A) Revoke access
B) Update status and notify user
C) Delete the user
D) Refund the user

<details>
<summary>Answer</summary>
**B** - Update status and notify the user to resolve payment issues.

---

**79. Why is it important to handle all webhook event types?**

A) To ensure the code compiles
B) Because RevenueCat may introduce new events
C) To generate more logs
D) To make the code more complex

<details>
<summary>Answer</summary>
**B** - RevenueCat may introduce new events or your app may expand to support more features.

---

**80. What is the recommended way to implement win-back campaigns?**

A) Send emails to all cancelled users
B) Query database for eligible users and send targeted offers
C) Use RevenueCat's win-back feature
D) Send a survey to all users

<details>
<summary>Answer</summary>
**B** - Query the database for users who meet the criteria and send targeted offers.

---

### Part E: Optimization & Production (20 Questions)

**81. What is MRR?**

A) Monthly Recurring Revenue
B) Monthly Revenue Rate
C) Maximum Recurring Revenue
D) Minimum Revenue Requirement

<details>
<summary>Answer</summary>
**A** - MRR is Monthly Recurring Revenue.

---

**82. What is Churn Rate?**

A) The percentage of users who cancel
B) The number of new users
C) The total revenue
D) The average price

<details>
<summary>Answer</summary>
**A** - Churn Rate is the percentage of subscribers who cancel.

---

**83. What is LTV in subscription businesses?**

A) Long-Term Value
B) Lifetime Value
C) Limited Time Value
D) Latest Transaction Value

<details>
<summary>Answer</summary>
**B** - LTV is Lifetime Value.

---

**84. Which is NOT a revenue optimization strategy?**

A) A/B testing paywalls
B) Reducing prices
C) Churn reduction
D) Conversion rate optimization

<details>
<summary>Answer</summary>
**B** - Reducing prices is not necessarily an optimization strategy.

---

**85. What is the purpose of RevenueCat Experiments?**

A) To crash the app
B) To A/B test paywalls and offers
C) To track user analytics
D) To send push notifications

<details>
<summary>Answer</summary>
**B** - RevenueCat Experiments is for A/B testing.

---

**86. What should you test with RevenueCat Experiments?**

A) App colors
B) Pricing, messaging, and layouts
C) App icons
D) Loading animations

<details>
<summary>Answer</summary>
**B** - Test pricing, messaging, and layouts that impact conversion.

---

**87. What is a win-back campaign?**

A) A campaign to get new users
B) A campaign to bring back cancelled users
C) A campaign to increase prices
D) A campaign to get referrals

<details>
<summary>Answer</summary>
**B** - Win-back campaigns bring back cancelled users.

---

**88. What is the recommended approach for A/B testing?**

A) Test everything at once
B) Test one variable at a time
C) Test randomly
D) Test for 1 day only

<details>
<summary>Answer</summary>
**B** - Test one variable at a time for clear results.

---

**89. What should you monitor in production?**

A) Only revenue
B) Revenue, churn, and technical errors
C) Only technical errors
D) Only user engagement

<details>
<summary>Answer</summary>
**B** - Monitor revenue, churn, and technical errors.

---

**90. What is ARPU?**

A) Average Revenue Per User
B) Annual Revenue Per Unit
C) Adjusted Revenue Per User
D) Accumulated Revenue Per User

<details>
<summary>Answer</summary>
**A** - ARPU is Average Revenue Per User.

---

**91. What should you do when monitoring shows a revenue drop?**

A) Panic and change everything
B) Investigate webhook logs and dashboard
C) Email all users
D) Change all prices

<details>
<summary>Answer</summary>
**B** - Investigate webhook logs and RevenueCat dashboard for unusual patterns.

---

**92. What is the purpose of the `managementURL` in CustomerInfo?**

A) To cancel the subscription
B) To let users manage their subscription
C) To change the user's email
D) To view purchase history

<details>
<summary>Answer</summary>
**B** - managementURL lets users manage their subscription.

---

**93. How should you implement churn reduction?**

A) Make cancellation impossible
B) Understand why users leave and address those reasons
C) Offer discounts to everyone
D) Remove the cancellation button

<details>
<summary>Answer</summary>
**B** - Understand why users leave and address those reasons.

---

**94. What is the best practice for the cancellation flow?**

A) Immediately cancel with no questions
B) Ask for feedback and offer retention options
C) Make it difficult to cancel
D) Cancel after 30 days

<details>
<summary>Answer</summary>
**B** - Ask for feedback and offer retention options.

---

**95. How long should A/B tests typically run?**

A) 1 day
B) Until statistical significance is reached
C) 1 month
D) 1 year

<details>
<summary>Answer</summary>
**B** - Run tests until statistical significance is reached.

---

**96. What is the role of notifications in churn reduction?**

A) To annoy users
B) To remind users about expiring access and payment issues
C) To send ads
D) To share app updates

<details>
<summary>Answer</summary>
**B** - Notifications remind users about expiring access and payment issues.

---

**97. What should be in a production monitoring system?**

A) Only revenue tracking
B) Alerts for revenue drops, churn spikes, and errors
C) Weekly reports only
D) Monthly dashboard reviews

<details>
<summary>Answer</summary>
**B** - Alerts for revenue drops, churn spikes, and errors.

---

**98. What is the recommended approach for paywall optimization?**

A) Use the same design for all users
B) A/B test different designs
C) Ask users what they want
D) Copy competitors' designs

<details>
<summary>Answer</summary>
**B** - A/B test different paywall designs for optimization.

---

**99. What metric is most important for measuring paywall effectiveness?**

A) App downloads
B) Conversion rate
C) Daily active users
D) Session length

<details>
<summary>Answer</summary>
**B** - Conversion rate is the key paywall metric.

---

**100. What is the final step before launching a subscription app to production?**

A) Submit to app stores
B) Complete a production readiness checklist
C) Delete the app
D) Add more features

<details>
<summary>Answer</summary>
**B** - Complete a production readiness checklist before launching.

---

### Practice Exam Answer Key

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|----|--------|
| 1 | B | 21 | B | 41 | B | 61 | B | 81 | A |
| 2 | B | 22 | C | 42 | B | 62 | B | 82 | A |
| 3 | C | 23 | B | 43 | B | 63 | A | 83 | B |
| 4 | C | 24 | B | 44 | B | 64 | C | 84 | B |
| 5 | B | 25 | D | 45 | D | 65 | B | 85 | B |
| 6 | F | 26 | B | 46 | B | 66 | B | 86 | B |
| 7 | B | 27 | T | 47 | A | 67 | B | 87 | B |
| 8 | B | 28 | A | 48 | B | 68 | A | 88 | B |
| 9 | B | 29 | B | 49 | B | 69 | B | 89 | B |
| 10 | B | 30 | B | 50 | C | 70 | B | 90 | A |
| 11 | B | 31 | B | 51 | B | 71 | B | 91 | B |
| 12 | B | 32 | B | 52 | B | 72 | B | 92 | B |
| 13 | B | 33 | B | 53 | B | 73 | B | 93 | B |
| 14 | B | 34 | B | 54 | B | 74 | C | 94 | B |
| 15 | B | 35 | B | 55 | B | 75 | B | 95 | B |
| 16 | B | 36 | A | 56 | B | 76 | B | 96 | B |
| 17 | D | 37 | B | 57 | C | 77 | B | 97 | B |
| 18 | B | 38 | B | 58 | B | 78 | B | 98 | B |
| 19 | B | 39 | A | 59 | B | 79 | B | 99 | B |
| 20 | B | 40 | B | 60 | B | 80 | B | 100 | B |
