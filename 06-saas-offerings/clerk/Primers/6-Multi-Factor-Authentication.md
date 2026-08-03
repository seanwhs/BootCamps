# Primer 6: Clerk's Multi-Factor Authentication (MFA)

## Implementing Extra Security Layers

Welcome to the sixth primer in the Clerk Mastery Series. This primer provides a comprehensive understanding of Multi-Factor Authentication (MFA) — what it is, why it matters, and how Clerk implements it. MFA is essential for protecting user accounts from unauthorized access, especially in enterprise and high-value applications.

---

## What is Multi-Factor Authentication?

### The Three Authentication Factors

MFA requires users to provide two or more verification factors from different categories:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    The Three Authentication Factors                        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Something You KNOW                                                 │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Information only the user should know                            │   │
│  │                                                                     │   │
│  │  Examples: Password, PIN, Security Questions, Passphrase          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Something You HAVE                                                 │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Physical device the user possesses                               │   │
│  │                                                                     │   │
│  │  Examples: Phone (SMS OTP, Authenticator App), Security Key,      │   │
│  │  Smart Card, Hardware Token                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Something You ARE                                                  │   │
│  │  ──────────────────────────────────────────────────────────         │   │
│  │  Biometric characteristics of the user                            │   │
│  │                                                                     │   │
│  │  Examples: Fingerprint, Face Recognition, Iris Scan, Voice Print  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Why MFA Matters

| Threat | Without MFA | With MFA |
|--------|-------------|----------|
| **Stolen Password** | Attacker gains access | Attacker blocked (needs second factor) |
| **Phishing** | User tricked into giving password | Even if password is stolen, second factor prevents access |
| **Credential Stuffing** | Leaked passwords from other sites used | Second factor prevents automated attacks |
| **Man-in-the-Middle** | Session hijacking | MFA prevents session replay |
| **Password Reuse** | One breach compromises multiple accounts | Each account requires its own second factor |

**Statistics**:
- MFA blocks 99.9% of account compromise attacks
- 80% of data breaches could be prevented with MFA
- Users are 6x less likely to be compromised with MFA enabled

---

## Clerk's MFA Implementation

### Supported MFA Methods

| Method | Type | Description | Use Case |
|--------|------|-------------|----------|
| **SMS OTP** | Something You Have (Phone) | One-time code sent via SMS | Quick setup, universal compatibility |
| **TOTP** | Something You Have (Authenticator App) | Time-based one-time code (Google Authenticator, Authy) | More secure than SMS, offline capable |
| **WebAuthn** | Something You Have (Security Key) / Something You Are (Biometrics) | FIDO2/WebAuthn security keys, fingerprint, face ID | Highest security, phish-proof |

### MFA Configuration in Clerk Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Clerk Dashboard MFA Configuration                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  User & Authentication → Multi-Factor Authentication               │   │
│  │                                                                     │   │
│  │  ☑ Enable SMS OTP                                                │   │
│  │     └─ Country code: [+1]                                            │   │
│  │     └─ Rate limit: [5] attempts per [15] minutes                 │   │
│  │                                                                     │   │
│  │  ☑ Enable TOTP                                                   │   │
│  │     └─ Setup via Clerk's UserProfile component                    │   │
│  │                                                                     │   │
│  │  ☑ Enable WebAuthn                                               │   │
│  │     └─ Supports: Yubikey, Touch ID, Windows Hello, Face ID      │   │
│  │                                                                     │   │
│  │  ☑ Require MFA for users with role: [admin]                    │   │
│  │  ☑ Allow users to manage MFA in profile                         │   │
│  │  ☐ Enforce MFA for all users (Enterprise)                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## MFA Flow: How It Works

### The Complete MFA Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MFA Flow                                                 │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. User Signs In                                                 │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     User provides first factor (email/password)                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  2. MFA Check                                                      │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     Clerk checks if MFA is enabled for the user                   │   │
│  │     - If enabled: Proceed to MFA step                            │   │
│  │     - If not enabled: Complete sign-in                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  3. MFA Verification                                               │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     User provides second factor:                                   │   │
│  │     - SMS OTP: Code sent to phone                                 │   │
│  │     - TOTP: Code from authenticator app                          │   │
│  │     - WebAuthn: Security key or biometrics                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  4. Completion                                                     │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Second factor verified                                       │   │
│  │     - Session created                                              │   │
│  │     - User redirected                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### MFA Flow in Code

```typescript
// app/components/SignInWithMFA.tsx
"use client";

import { useSignIn } from "@clerk/nextjs";
import { useState } from "react";
import { useRouter } from "next/navigation";

export function SignInWithMFA() {
  const { isLoaded, signIn, setActive } = useSignIn();
  const router = useRouter();
  
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mfaCode, setMfaCode] = useState("");
  const [mfaMethod, setMfaMethod] = useState<"totp" | "sms" | "webauthn" | null>(null);
  const [step, setStep] = useState<"credentials" | "mfa">("credentials");
  const [error, setError] = useState("");
  const [availableFactors, setAvailableFactors] = useState<any[]>([]);

  // Step 1: Handle credentials
  const handleCredentialsSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;
    
    try {
      const signInAttempt = await signIn.create({
        identifier: email,
        password,
      });
      
      if (signInAttempt.status === "complete") {
        await setActive({ session: signInAttempt.createdSessionId });
        router.push("/dashboard");
        return;
      }
      
      if (signInAttempt.status === "needs_second_factor") {
        // MFA is required
        setAvailableFactors(signInAttempt.availableSecondFactors || []);
        setStep("mfa");
        
        // Determine which method to use
        const hasTOTP = signInAttempt.availableSecondFactors?.some(
          (f: any) => f.strategy === "totp"
        );
        const hasSMS = signInAttempt.availableSecondFactors?.some(
          (f: any) => f.strategy === "phone_code"
        );
        
        if (hasTOTP) {
          setMfaMethod("totp");
        } else if (hasSMS) {
          setMfaMethod("sms");
        }
        
        return;
      }
    } catch (err: any) {
      setError(err.message);
    }
  };

  // Step 2: Handle MFA verification
  const handleMFAVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;
    
    try {
      let verificationAttempt;
      
      if (mfaMethod === "totp") {
        // For TOTP, the user will provide the code
        verificationAttempt = await signIn.attemptSecondFactor({
          strategy: "totp",
          code: mfaCode,
        });
      } else if (mfaMethod === "sms") {
        // First, send the SMS code
        // Then, verify with the code
        if (availableFactors.length > 0) {
          // Find the phone code factor
          const smsFactor = availableFactors.find(
            (f: any) => f.strategy === "phone_code"
          );
          
          if (!smsFactor) {
            setError("SMS verification not available");
            return;
          }
          
          // The first call sends the code
          if (!mfaCode) {
            // Send the SMS
            await signIn.prepareSecondFactor({
              strategy: "phone_code",
              phoneNumberId: smsFactor.phoneNumberId,
            });
            
            // Show a message and wait for user to enter code
            setError("SMS sent to your phone. Please enter the code.");
            return;
          }
          
          // The second call verifies the code
          verificationAttempt = await signIn.attemptSecondFactor({
            strategy: "phone_code",
            code: mfaCode,
            phoneNumberId: smsFactor.phoneNumberId,
          });
        }
      }
      
      if (verificationAttempt?.status === "complete") {
        await setActive({ session: verificationAttempt.createdSessionId });
        router.push("/dashboard");
      }
    } catch (err: any) {
      setError(err.message);
    }
  };

  // MFA input form
  if (step === "mfa") {
    return (
      <form onSubmit={handleMFAVerify}>
        <h2>Two-Factor Authentication Required</h2>
        
        {mfaMethod === "totp" && (
          <div>
            <label>Enter code from authenticator app</label>
            <input
              type="text"
              value={mfaCode}
              onChange={(e) => setMfaCode(e.target.value)}
              placeholder="000000"
              required
            />
          </div>
        )}
        
        {mfaMethod === "sms" && (
          <div>
            <label>Enter code sent to your phone</label>
            <input
              type="text"
              value={mfaCode}
              onChange={(e) => setMfaCode(e.target.value)}
              placeholder="000000"
              required
            />
          </div>
        )}
        
        {error && <div className="error">{error}</div>}
        
        <button type="submit">Verify</button>
      </form>
    );
  }

  // Credentials form
  return (
    <form onSubmit={handleCredentialsSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div className="error">{error}</div>}
      <button type="submit">Sign In</button>
    </form>
  );
}
```

---

## TOTP (Time-Based One-Time Password)

### What is TOTP?

TOTP is an algorithm that generates a one-time password based on:

- A shared secret (seed) stored in the authenticator app
- The current time (in 30-second intervals)

This creates a code that changes every 30 seconds, making it very secure.

### TOTP Setup Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TOTP Setup Flow                                          │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. User Navigates to Security Settings                           │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     User clicks "Enable Two-Factor Authentication"               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  2. Clerk Generates Secret                                         │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Generates a unique TOTP secret                               │   │
│  │     - Creates a QR code for scanning                               │   │
│  │     - Provides manual entry key                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  3. User Scans QR Code                                              │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Opens authenticator app (Google Authenticator, Authy)       │   │
│  │     - Scans QR code or enters key manually                       │   │
│  │     - App starts generating codes                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  4. Verify Setup                                                   │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - User enters current code from authenticator app             │   │
│  │     - Clerk verifies the code                                     │   │
│  │     - If successful, TOTP is enabled                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  5. Backup Codes Generated                                          │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Clerk generates 10 backup codes                              │   │
│  │     - User must save them securely                                │   │
│  │     - Backup codes can be used if authenticator app is lost      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### TOTP Setup Code

```typescript
// app/profile/security/page.tsx
"use client";

import { useUser, useClerk } from "@clerk/nextjs";
import { useState, useEffect } from "react";

export function SetupTOTP() {
  const { user } = useUser();
  const { session } = useClerk();
  const [isLoading, setIsLoading] = useState(false);
  const [totpSecret, setTotpSecret] = useState<string | null>(null);
  const [qrCode, setQrCode] = useState<string | null>(null);
  const [verificationCode, setVerificationCode] = useState("");
  const [backupCodes, setBackupCodes] = useState<string[]>([]);
  const [step, setStep] = useState<"init" | "verify" | "done">("init");
  const [error, setError] = useState("");

  // Initialize TOTP setup
  const initiateSetup = async () => {
    setIsLoading(true);
    setError("");
    
    try {
      // This is a simplified example - Clerk handles this through UserProfile
      // For headless implementation:
      const totp = await user?.createTotp();
      
      if (totp) {
        setTotpSecret(totp.secret);
        setQrCode(totp.qrCode);
        setStep("verify");
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  // Verify TOTP setup
  const verifySetup = async () => {
    setIsLoading(true);
    setError("");
    
    try {
      // Verify the code and enable TOTP
      const result = await user?.verifyTotp({
        code: verificationCode,
      });
      
      if (result?.verified) {
        // TOTP is now enabled
        // Get backup codes
        const backupCodesResult = await user?.getBackupCodes();
        if (backupCodesResult) {
          setBackupCodes(backupCodesResult.codes);
          setStep("done");
        }
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  if (step === "init") {
    return (
      <div>
        <h2>Set Up Two-Factor Authentication</h2>
        <p>Scan the QR code with your authenticator app</p>
        <button onClick={initiateSetup} disabled={isLoading}>
          {isLoading ? "Generating..." : "Set Up TOTP"}
        </button>
        {error && <div className="error">{error}</div>}
      </div>
    );
  }

  if (step === "verify") {
    return (
      <div>
        <h2>Verify Setup</h2>
        {qrCode && (
          <div>
            <img src={qrCode} alt="TOTP QR Code" />
            <p>Or enter this key manually: {totpSecret}</p>
          </div>
        )}
        <p>Enter the 6-digit code from your authenticator app:</p>
        <input
          type="text"
          value={verificationCode}
          onChange={(e) => setVerificationCode(e.target.value)}
          placeholder="000000"
          maxLength={6}
        />
        <button onClick={verifySetup} disabled={isLoading}>
          {isLoading ? "Verifying..." : "Verify"}
        </button>
        {error && <div className="error">{error}</div>}
      </div>
    );
  }

  if (step === "done") {
    return (
      <div>
        <h2>✅ Two-Factor Authentication Enabled</h2>
        <p>Save these backup codes in a secure place:</p>
        <div className="backup-codes">
          {backupCodes.map((code, index) => (
            <code key={index}>{code}</code>
          ))}
        </div>
        <p className="warning">
          ⚠️ Store these codes securely. They can be used to access your account
          if you lose access to your authenticator app.
        </p>
        <button onClick={() => window.location.reload()}>
          Done
        </button>
      </div>
    );
  }

  return null;
}
```

---

## WebAuthn (Security Keys & Biometrics)

### What is WebAuthn?

WebAuthn (Web Authentication) is a web standard for passwordless authentication using:
- Physical security keys (YubiKey, Titan Security Key)
- Platform authenticators (Touch ID, Windows Hello, Face ID)
- Phone-based authenticators (Android, iOS)

### WebAuthn Benefits

| Benefit | Description |
|---------|-------------|
| **Phishing-Resistant** | Tokens are bound to the specific site (domain) |
| **Biometric Support** | Fingerprint, face, or voice recognition |
| **Hardware Security** | Private keys never leave the device |
| **No Shared Secrets** | No passwords to leak or intercept |
| **FIDO2 Standard** | Open standard, widely supported |

### WebAuthn Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WebAuthn Authentication Flow                            │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. User Initiates Authentication                                  │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - User clicks "Sign in with Security Key"                      │   │
│  │     - Or uses passkey option                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  2. Browser Requests Credential                                    │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Browser prompts user for security key/biometrics            │   │
│  │     - User taps security key / uses biometrics                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  3. Credential Signed                                               │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Authenticator signs challenge with private key              │   │
│  │     - Signed credential returned to browser                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  4. Server Verifies                                                 │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Clerk verifies the signature                                  │   │
│  │     - Checks the credential ID                                    │   │
│  │     - Verifies the domain (prevents phishing)                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### WebAuthn Setup Code

```typescript
// app/components/SetupWebAuthn.tsx
"use client";

import { useUser } from "@clerk/nextjs";
import { useState } from "react";

export function SetupWebAuthn() {
  const { user } = useUser();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const handleSetupWebAuthn = async () => {
    setIsLoading(true);
    setError("");
    setSuccess(false);

    try {
      // Create a WebAuthn credential
      // This will trigger the browser's WebAuthn API
      const result = await user?.createWebAuthnCredential({
        // Options can be customized
        authenticatorSelection: {
          userVerification: "required",
          residentKey: "preferred",
        },
        // Challenge is generated by Clerk
        // Client data is automatically handled
      });

      if (result) {
        setSuccess(true);
      }
    } catch (err: any) {
      if (err.message.includes("user cancelled")) {
        setError("Setup was cancelled");
      } else {
        setError(err.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <h3>Add Security Key</h3>
      <p>
        Use a physical security key (YubiKey) or platform authenticator
        (Touch ID, Windows Hello) to sign in securely.
      </p>

      {success && (
        <div className="success">
          ✅ Security key added successfully!
        </div>
      )}

      {error && (
        <div className="error">
          ❌ {error}
        </div>
      )}

      <button
        onClick={handleSetupWebAuthn}
        disabled={isLoading || !user}
      >
        {isLoading ? "Setting up..." : "Add Security Key"}
      </button>

      <div className="info">
        <p>ℹ️ WebAuthn provides the highest level of security:</p>
        <ul>
          <li>✅ Phishing-resistant</li>
          <li>✅ Private key never leaves the device</li>
          <li>✅ Supports biometric verification</li>
        </ul>
      </div>
    </div>
  );
}
```

---

## Backup Codes

### What Are Backup Codes?

Backup codes are one-time-use codes that can be used when primary MFA methods are unavailable:
- Lost or broken phone
- Authenticator app not installed
- Security key lost

### Backup Codes Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Backup Codes Flow                                        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  1. MFA Setup Complete                                              │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     After enabling MFA, Clerk generates 10 backup codes            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  2. User Saves Codes                                                │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - Displayed once                                              │   │
│  │     - Must be saved securely                                      │   │
│  │     - Recommended: Password manager, physical vault             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  3. User Uses Backup Code                                           │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - On sign-in, click "Use a backup code"                       │   │
│  │     - Enter one of the 10 codes                                    │   │
│  │     - Code is consumed (can't be used again)                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  4. Generate New Codes                                              │   │
│  │     ──────────────────────────────────────────────────────────      │   │
│  │     - After using all codes                                       │   │
│  │     - Or request new codes in security settings                  │   │
│  │     - Old codes are invalidated                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Backup Codes Implementation

```typescript
// app/components/BackupCodes.tsx
"use client";

import { useUser } from "@clerk/nextjs";
import { useState } from "react";

export function BackupCodes() {
  const { user } = useUser();
  const [codes, setCodes] = useState<string[]>([]);
  const [showCodes, setShowCodes] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const generateNewCodes = async () => {
    setIsLoading(true);
    setError("");
    
    try {
      const result = await user?.getBackupCodes();
      
      if (result) {
        setCodes(result.codes);
        setShowCodes(true);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const regenerateCodes = async () => {
    if (!confirm("Generating new codes will invalidate all existing backup codes. Continue?")) {
      return;
    }
    
    setIsLoading(true);
    setError("");
    
    try {
      const result = await user?.regenerateBackupCodes();
      
      if (result) {
        setCodes(result.codes);
        setShowCodes(true);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="backup-codes-container">
      <h3>Backup Codes</h3>
      <p>
        Backup codes can be used to sign in if you lose access to your
        authenticator app or security key.
      </p>

      {error && <div className="error">{error}</div>}

      {!showCodes ? (
        <button onClick={generateNewCodes} disabled={isLoading}>
          {isLoading ? "Generating..." : "Generate Backup Codes"}
        </button>
      ) : (
        <div>
          <p className="warning">
            ⚠️ Save these codes in a secure place. Each code can only be used once.
          </p>
          <div className="codes-grid">
            {codes.map((code, index) => (
              <code key={index} className="backup-code">{code}</code>
            ))}
          </div>
          <div className="actions">
            <button onClick={regenerateCodes} disabled={isLoading}>
              Regenerate Codes
            </button>
            <button onClick={() => setShowCodes(false)}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
```

---

## MFA Management in UserProfile

### Clerk's Built-in MFA Management

Clerk's `<UserProfile/>` component provides MFA management out of the box:

```typescript
// app/profile/page.tsx
import { UserProfile } from "@clerk/nextjs";

export default function ProfilePage() {
  return (
    <div className="profile-container">
      <UserProfile
        appearance={{
          elements: {
            rootBox: "w-full max-w-4xl mx-auto",
          },
        }}
        // MFA is automatically included in the Security section
      />
    </div>
  );
}
```

### What Users Can Manage

| Feature | Description |
|---------|-------------|
| **Enable TOTP** | Set up authenticator app |
| **Disable TOTP** | Remove authenticator app |
| **View Backup Codes** | See available backup codes |
| **Regenerate Backup Codes** | Generate new codes |
| **Add Security Key** | Register WebAuthn credential |
| **Remove Security Key** | Unregister WebAuthn credential |
| **SMS OTP Management** | Add/remove phone numbers |

---

## MFA Security Best Practices

### Configuration Guidelines

| Setting | Recommendation | Why |
|---------|----------------|-----|
| **MFA Enforcement** | Require for admin roles | Protect high-privilege accounts |
| **MFA Voluntary** | Allow all users to enable | Encourage adoption |
| **SMS OTP** | Use only as backup | SMS can be intercepted |
| **TOTP** | Primary method | Secure, widely available |
| **WebAuthn** | Enable for all users | Highest security level |
| **Backup Codes** | Require upon MFA setup | Prevent lockouts |
| **Rate Limiting** | Limit attempts | Prevent brute force |

### Common MFA Pitfalls

| Pitfall | Impact | Solution |
|---------|--------|----------|
| **SMS-only MFA** | Vulnerable to SIM swapping | Enable TOTP or WebAuthn |
| **No backup codes** | User lockout | Generate and enforce saving |
| **Forgotten backup codes** | Account recovery issues | Store in password manager |
| **No MFA for admins** | Elevated risk | Mandatory MFA for admin roles |
| **No recovery process** | User frustration | Document recovery process |
| **Poor UX** | Users skip MFA | Clean, simple implementation |

---

## Quick Reference: MFA Strategies

| Strategy | Strategy | Use Case |
|----------|----------|----------|
| **TOTP** | Authenticator app | General users |
| **SMS OTP** | SMS code | Backup method |
| **WebAuthn** | Security key/biometrics | High-security users |
| **Backup Codes** | One-time use | Account recovery |
| **Mandatory** | Required for all users | Enterprise, compliance |
| **Optional** | User can enable | Consumer apps |
| **Conditional** | Required based on risk | Adaptive authentication |

---

## Key Takeaways

1. **MFA prevents 99.9% of account compromises** — Essential for security
2. **Clerk supports multiple MFA methods** — SMS, TOTP, WebAuthn
3. **WebAuthn is the most secure** — Phishing-resistant, hardware-backed
4. **Backup codes are critical** — Prevent user lockouts
5. **MFA can be managed via UserProfile** — Built-in UI component
6. **MFA can be enforced per role** — Admins require MFA
7. **Rate limiting is important** — Prevent brute force attacks

---

## Ready to Implement?

This primer covers MFA implementation in Clerk. Now proceed to:

- **Part 2: Server-Side Security** for protecting APIs with MFA
- **Part 3: Multi-Tenant SaaS** for organization-level MFA policies
- **Part 5: React 19 & Next.js 16** for modern MFA UI patterns

**Secure your application with multi-factor authentication!**
