# Project Aegis Scalability Plan

## 1. Database Scaling (PostgreSQL)
The zero-knowledge design places very little computational load on the server. The `EncryptedBlob` table will grow massive but querying is strictly user-scoped (`userId`) and time-scoped (`lastModified`).
- **Phase 1**: Vertical scaling of single managed PostgreSQL instance (e.g., AWS RDS or Supabase).
- **Phase 2**: Partition `EncryptedBlob` based on hash of `userId` (Horizontal Sharding).
- **Phase 3**: Migrate large blob payloads (the `ciphertext` column) to AWS S3 / Cloudflare R2, leaving only the metadata (IV, MAC, Pointers) in Postgres.

## 2. API Servers (Node.js)
Since Express servers do absolutely zero encryption/decryption (only simple JWT auth + proxying bytes), they are stateless.
- Deploy via Docker containers in a Kubernetes Cluster (EKS) or ECS.
- Front with AWS API Gateway or Cloudflare for DDoS protection and geographic load balancing.
- Auto-scale based on CPU / Network Ingress.

## 3. Storage Costs 
Cost structure directly correlates to raw storage. We limit upload sizes (e.g., max 10MB per note/image). 
To prevent abuse:
- Enforce storage quotas on the Free + Premium tiers via Express middleware before Postgres insertion. 
- Implement an automated purge cronjob that deletes blobs for users whose Premium subscription lazily expired more than 30 days ago.
