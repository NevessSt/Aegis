# Project Aegis Architecture Diagram

## High-Level System Architecture

```mermaid
graph TD
    Client[Flutter Mobile App/Desktop] <--> |End-to-End Encrypted Data| API[Node.js / Express API]
    API <--> |Encrypted Blobs Only| DB[(PostgreSQL)]
    API <--> |Stripe Webhooks| Stripe[Stripe Billing]
    
    subgraph Flutter App
        UI[Presentation Riverpod] --> Domain[Domain Layer]
        Domain --> Repos[Repositories]
        Repos --> Encrypt[Encryption Engine AES-256-GCM]
        Encrypt --> LocalDB[(Isar Local DB)]
        Encrypt --> SyncManager[Sync Manager]
        SyncManager --> API
        
        KeyMgr[Key Manager Argon2] --> SecureEnclave[Device Secure Enclave/Keystore]
        Biometrics[Biometric Auth] --> KeyMgr
    end
    
    subgraph Backend Zero-Knowledge
        Auth[JWT Auth]
        BlobStore[Encrypted Blob Store]
        KeyWrap[Wrapped Key Storage]
    end
```

## Security Flow
1. User creates account with Password.
2. App derives `MasterKey` via Argon2 using Password + Salt.
3. `MasterKey` generates a random `SyncKey` and `LocalKey`.
4. `LocalKey` encrypts Isar database and is stored in Secure Enclave, unlocked via Biometrics.
5. Notes are encrypted individually with AES-256-GCM using unique IVs.
6. For Cloud Sync: `SyncKey` is encrypted by `MasterKey`, and sent to server as `WrappedSyncKey`.
7. Encrypted notes are uploaded. Server never sees `SyncKey` or `MasterKey`.
