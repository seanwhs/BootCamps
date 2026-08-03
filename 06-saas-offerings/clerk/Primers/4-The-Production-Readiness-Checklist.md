# Primer 4: The Production Readiness Checklist

## Deploying Clerk-Powered Applications to Production

Welcome to the fourth primer in the Clerk Mastery Series. Before you deploy your Clerk-powered application to production, you need to ensure it's secure, scalable, and maintainable. This primer provides a comprehensive checklist of everything you must verify before going live.

---

## Pre-Deployment Checklist

### 1. Clerk Configuration

#### Production Instance

- [ ] **Create a production instance** in Clerk Dashboard
  - Development instances (`*.clerk.accounts.dev`) are not for production
  - Production instances use your custom domain

- [ ] **Configure a custom domain**
  - `auth.yourdomain.com` (recommended) or `yourdomain.com`
  - Add DNS TXT records for verification
  - Wait for DNS propagation (up to 48 hours)

- [ ] **Update OAuth credentials**
  - Replace Clerk's default OAuth credentials with your own
  - For Google: Create OAuth 2.0 credentials in Google Cloud Console
  - For GitHub: Create OAuth App in GitHub Developer Settings
  - For other providers: Follow their OAuth setup guides

- [ ] **Configure redirect URLs**
  ```bash
  # Development
  http://localhost:3000/sign-in
  http://localhost:3000/dashboard
  http://localhost:3000/sign-up

  # Production (replace with your domain)
  https://yourdomain.com/sign-in
  https://yourdomain.com/dashboard
  https://yourdomain.com/sign-up
  ```

- [ ] **Set up webhook endpoints**
  - Configure in Clerk Dashboard → Webhooks
  - Use production endpoint URL
  - Copy the signing secret (`whsec_`)
  - Test webhooks before going live

#### Environment Variables

- [ ] **Use the correct keys**

  | Environment Variable | Development | Production |
  |---------------------|-------------|------------|
  | `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | `pk_test_...` | `pk_live_...` |
  | `CLERK_SECRET_KEY` | `sk_test_...` | `sk_live_...` |
  | `CLERK_WEBHOOK_SECRET` | `whsec_test_...` | `whsec_...` |
  | `DATABASE_URL` | Local DB URL | Production DB URL |

- [ ] **Secure environment variables**
  - Never commit `.env` files to version control
  - Use secret management (Vercel Secrets, AWS Secrets Manager, etc.)
  - Rotate secrets regularly

### 2. Database Configuration

#### Schema & Migrations

- [ ] **Run migrations on production database**
  ```bash
  npx prisma migrate deploy  # For Prisma
  # or
  npm run db:migrate  # For other ORMs
  ```

- [ ] **Set up connection pooling**
  - Serverless environments need connection pooling
  - Use: Supabase, RDS Proxy, or connection poolers
  - Configure pool size (typically 10-20 connections)

- [ ] **Configure backups**
  - Automated daily backups
  - Point-in-time recovery (if available)
  - Retention policy (7-30 days)

#### Data Synchronization

- [ ] **User data sync strategy**
  - Webhooks are the recommended approach
  - For Clerk user events, sync to your database
  - Verify sync works before deployment

- [ ] **Handle sync failures gracefully**
  - Log sync errors
  - Retry failed syncs
  - Implement manual sync fallback

### 3. Authentication Flow

#### Sign-In & Sign-Up

- [ ] **Test all sign-in methods**
  - Email/password
  - Google OAuth
  - GitHub OAuth
  - Magic links (if enabled)
  - MFA (if enabled)

- [ ] **Test sign-up flow**
  - Email verification
  - Phone verification (if enabled)
  - Organization creation (if applicable)

- [ ] **Test password reset flow**
  - "Forgot password" link
  - Reset email delivery
  - Password update

#### Session Management

- [ ] **Session timeout configured**
  - Set appropriate timeout (typically 30 days max)
  - Consider shorter for sensitive applications

- [ ] **Test session persistence**
  - Closing/reopening browser
  - Multiple tabs
  - Multiple devices

- [ ] **Test remote sign-out**
  - Users can sign out from any device
  - Sessions are invalidated server-side

#### Organization Management (if applicable)

- [ ] **Organization creation**
  - Users can create organizations
  - Creator is assigned admin role
  - Organization slug is unique

- [ ] **Member invitation flow**
  - Users can invite others
  - Invitation emails are delivered
  - Email templates are branded

- [ ] **Role management**
  - Admins can change member roles
  - Changes take effect immediately

### 4. Security Hardening

#### HTTP Security Headers

- [ ] **Content Security Policy (CSP)**
  ```typescript
  // In middleware.ts
  Content-Security-Policy: default-src 'self';
                         script-src 'self' https://clerk.accounts.dev;
                         style-src 'self' 'unsafe-inline';
                         img-src 'self' data: https://img.clerk.com;
                         connect-src 'self' https://api.clerk.com;
  ```

- [ ] **Other security headers**
  ```
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  X-XSS-Protection: 1; mode=block
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  ```

#### Rate Limiting

- [ ] **API route rate limiting**
  ```typescript
  // In your API routes
  import { rateLimit } from "@/lib/rate-limit";

  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,  // 15 minutes
    maxRequests: 100,           // 100 requests per window
  });
  ```

- [ ] **Authentication endpoint rate limiting**
  - Clerk handles this automatically
  - Configure in Clerk Dashboard

#### CORS Configuration

- [ ] **Restrict allowed origins**
  ```typescript
  const allowedOrigins = [
    'https://yourdomain.com',
    'https://www.yourdomain.com',
  ];
  ```

### 5. Performance Optimization

#### Caching Strategy

- [ ] **Implement caching for auth data**
  ```typescript
  // lib/auth-helpers.ts
  import { cache } from "react";

  export const getCurrentUser = cache(async () => {
    return await currentUser();
  });
  ```

- [ ] **Cache user data appropriately**
  - User preferences (5 minutes)
  - Organization data (5 minutes)
  - Session data (on-demand)

#### Bundle Optimization

- [ ] **Code splitting**
  - Clerk SDKs are automatically split
  - Ensure you're only importing what you need

- [ ] **Image optimization**
  - Use Clerk's image optimization (`https://img.clerk.com`)
  - Or use Next.js Image component

- [ ] **Minimize client-side JavaScript**
  - Use Server Components where possible
  - Use Server Actions instead of API calls when applicable

### 6. Monitoring & Observability

#### Health Checks

- [ ] **Implement health check endpoint**
  ```typescript
  // app/api/health/route.ts
  export async function GET() {
    // Check database connection
    // Check Clerk API connection
    return NextResponse.json({ status: "healthy" });
  }
  ```

- [ ] **Add to monitoring service**
  - Uptime monitoring (Pingdom, UptimeRobot)
  - Synthetic monitoring (Vercel Analytics)
  - Status page (optional)

#### Logging

- [ ] **Structured logging**
  ```typescript
  // lib/logger.ts
  export const logger = {
    info: (message: string, context?: any) => {
      console.log(JSON.stringify({ level: "info", message, ...context }));
    },
    // ... error, warn, debug
  };
  ```

- [ ] **Log important events**
  - User sign-in attempts
  - Authentication failures
  - Session changes
  - Organization changes
  - Admin actions

#### Error Tracking

- [ ] **Set up error tracking**
  - Sentry (recommended)
  - LogRocket
  - Datadog
  - AWS CloudWatch

- [ ] **Capture authentication errors**
  ```typescript
  // Example with Sentry
  import * as Sentry from "@sentry/nextjs";

  try {
    await signInWithGoogle();
  } catch (error) {
    Sentry.captureException(error, {
      tags: { flow: "social-login", provider: "google" },
    });
  }
  ```

### 7. Testing

#### Automated Tests

- [ ] **Unit tests**
  - Authentication helpers
  - Authorization functions
  - Server Actions

- [ ] **Integration tests**
  - API routes
  - Database operations
  - Webhook processing

- [ ] **End-to-end tests**
  - Sign-in flow
  - Sign-up flow
  - Protected route access
  - Organization management

#### Manual Testing

- [ ] **Test all user flows**
  - Sign up with email
  - Sign up with Google
  - Sign up with GitHub
  - Sign in with email
  - Sign in with Google
  - Sign in with GitHub
  - Password reset
  - Email verification
  - MFA (if enabled)
  - Organization creation
  - Organization switching
  - Member invitations
  - Role changes

- [ ] **Test edge cases**
  - Invalid credentials
  - Expired sessions
  - Locked accounts
  - Concurrent sessions
  - Session timeout

### 8. Deployment Strategy

#### Deployment Platform

- [ ] **Choose deployment platform**
  - Vercel (recommended for Next.js)
  - AWS (ECS, Lambda)
  - Google Cloud (Cloud Run)
  - Azure (App Service)

- [ ] **Configure build settings**
  - Environment variables set
  - Build command: `npm run build`
  - Output directory: `.next` (for Next.js)

#### Continuous Integration/Deployment

- [ ] **Set up CI/CD pipeline**
  - GitHub Actions
  - GitLab CI
  - Vercel (automatic deployments)

- [ ] **Deployment workflow**
  1. Push to `main` branch
  2. Run tests
  3. Build application
  4. Deploy to production

#### Rollback Strategy

- [ ] **Plan for rollbacks**
  - One-click rollback (Vercel)
  - Previous version redeployment
  - Database rollback script

### 9. Documentation

#### Internal Documentation

- [ ] **Architecture diagram**
  - Components and their relationships
  - Data flow
  - Authentication flow

- [ ] **Setup instructions**
  - How to set up a local development environment
  - Required environment variables
  - Database setup

- [ ] **Deployment guide**
  - Step-by-step deployment process
  - Rollback procedures
  - Troubleshooting guide

#### User Documentation

- [ ] **User guide**
  - How to sign up
  - How to sign in
  - How to reset password
  - How to manage profile
  - How to use organizations

### 10. Post-Deployment

#### Verification

- [ ] **Smoke test after deployment**
  - Sign in with each method
  - Access protected routes
  - Test webhooks
  - Verify database sync

- [ ] **Monitor for errors**
  - Check error tracking dashboard
  - Check logging service
  - Review Clerk Dashboard for any issues

#### Ongoing Maintenance

- [ ] **Regular security audits**
  - Check Clerk Dashboard for security events
  - Review access logs
  - Update dependencies

- [ ] **Performance monitoring**
  - Monitor response times
  - Check database performance
  - Review Clerk Dashboard performance metrics

---

## Quick Reference: Pre-Production Checklist Summary

| Category | Items | Status |
|----------|-------|--------|
| **Clerk Configuration** | Production instance, Custom domain, OAuth credentials, Redirect URLs, Webhooks | [ ] |
| **Environment Variables** | Correct keys, Secure storage, Rotated secrets | [ ] |
| **Database** | Migrations applied, Connection pooling, Backups | [ ] |
| **Authentication** | All sign-in methods, Sign-up flow, Password reset, MFA | [ ] |
| **Security Headers** | CSP, HSTS, CORS, Other security headers | [ ] |
| **Rate Limiting** | API routes, Authentication endpoints | [ ] |
| **Performance** | Caching, Bundle optimization, Image optimization | [ ] |
| **Monitoring** | Health checks, Logging, Error tracking | [ ] |
| **Testing** | Unit tests, Integration tests, E2E tests, Manual testing | [ ] |
| **Deployment** | Platform configured, CI/CD, Rollback plan | [ ] |
| **Documentation** | Internal docs, User docs | [ ] |
| **Post-Deployment** | Smoke tests, Monitoring, Maintenance plan | [ ] |

---

## Key Takeaways

1. **Production requires a separate Clerk instance** — Development instances are not for production
2. **Security headers are critical** — CSP, HSTS, CORS protect your users
3. **Rate limiting prevents abuse** — Especially for authentication endpoints
4. **Monitoring is essential** — You can't fix what you can't see
5. **Testing all flows** — Every authentication path must work
6. **Document everything** — Future you will thank you
7. **Have a rollback plan** — Things will go wrong; be prepared

---

## Ready to Deploy?

This primer covers everything you need to verify before going to production. Now proceed to:

- **Appendix B: Production Deployment & Security** for detailed implementation
- **Part 5: React 19 & Next.js 16** for production-ready full-stack patterns

**Go live with confidence!**
