To address your cost optimization challenge in Azure using a serverless architecture while keeping billing records available and API contracts intact, we can implement a **hybrid data archival strategy**. Here's a breakdown of a real-world solution tailored to your scenario.

---

## ✅ Solution Overview

### Strategy:

* **Hot Data (Recent 3 months)**: Keep in Azure Cosmos DB.
* **Cold Data (Older than 3 months)**: Move to Azure Blob Storage in a structured and queryable format (e.g., JSON or Parquet).
* **Unified API Layer**: A logic layer that abstracts Cosmos DB and Blob Storage, so your APIs don’t need to change.

---

## 💡 Architecture Diagram

```
           +-------------------+
           |   API Layer       |
           | (Function App /   |
           |  App Service)     |
           +--------+----------+
                    |
         +----------+-----------+
         |                      |
+--------v--------+    +--------v--------+
| Cosmos DB       |    | Azure Blob       |
| (Hot Data <= 3M)|    | Storage (Cold)   |
+-----------------+    +------------------+
                             |
                     +-------v--------+
                     | Index DB (Optional)|
                     | (Table Storage)   |
                     +-------------------+
```

---

## 🚀 Implementation Plan

### 1. **Cold Storage Migration**

Move records older than 3 months from Cosmos DB to Azure Blob Storage.

#### Pseudocode for Archival (Run via Azure Function Timer Trigger or Durable Function):

```python
def archive_old_billing_records():
    now = datetime.utcnow()
    archive_before = now - timedelta(days=90)

    # Query old records
    old_records = cosmos_query(f"SELECT * FROM c WHERE c.createdAt < '{archive_before.isoformat()}'")

    for record in old_records:
        blob_path = f"billing-records/{record['userId']}/{record['createdAt'][:10]}/{record['id']}.json"
        upload_to_blob(blob_path, json.dumps(record))
        delete_from_cosmos(record['id'])
```

#### Azure Blob Storage Structure:

```
billing-records/
  └── userId/
      └── yyyy-mm-dd/
          └── recordId.json
```

---

### 2. **Data Retrieval Logic (Abstract Layer)**

Wrap the Cosmos DB + Blob logic behind a unified interface. Modify your internal data access service, NOT the API contract.

#### Pseudocode:

```python
def get_billing_record(record_id):
    record = get_from_cosmos(record_id)
    if record:
        return record
    
    # If not in Cosmos, fallback to blob
    blob_record = lookup_blob(record_id)
    if blob_record:
        return blob_record

    return None
```

**Optionally**: Maintain an index (record ID → blob path) in Azure Table Storage for faster blob lookup.

---

### 3. **Blob Indexing (Optional but Recommended)**

To reduce lookup latency in Blob, maintain a small **index table** in Azure Table Storage:

* PartitionKey = record prefix (e.g., `2022-01`)
* RowKey = record ID
* BlobPath = path in Blob Storage

---

### 4. **Automation & Monitoring**

* Use Azure Durable Functions or Data Factory to orchestrate periodic data archival.
* Use Application Insights to monitor failed transfers or access latency.
* Implement retry policies for blob access.

---

## 🧾 Cost Optimization Benefits

| Component          | Optimization                                          |
| ------------------ | ----------------------------------------------------- |
| Cosmos DB RU/s     | Reduced read/write units by offloading old data       |
| Cosmos Storage     | Reduced storage size = lower cost                     |
| Azure Blob Storage | Much cheaper (\$0.018/GB for cool tier vs. Cosmos DB) |
| Cold Access        | Satisfied within seconds via Blob + Index             |

---

## ⚙️ Deployment Commands (CLI Example)

### 1. Create Blob Storage

```bash
az storage account create --name billingarchive --resource-group myRG --sku Standard_GRS
az storage container create --name billing-records --account-name billingarchive
```

### 2. Create Timer Trigger Function for Archival

In `function.json`:

```json
{
  "schedule": "0 0 * * * *", // daily
  "type": "timerTrigger",
  "direction": "in",
  "name": "myTimer"
}
```

### 3. Assign Identity & Role to Access Blob

```bash
az functionapp identity assign --name myFunction --resource-group myRG
az role assignment create \
  --assignee <principal-id> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/.../resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/billingarchive
```

---

## ✅ No Downtime or API Changes

* Cold records are transparently served via the logic layer.
* Cosmos DB continues to serve hot data at low latency.
* Archival is incremental and non-blocking.

---

## ✅ Simplicity

* Leverages native Azure services.
* Minimal code changes required.
* Serverless scaling supported.

---

## 🔚 Summary

| Requirement           | Met |
| --------------------- | --- |
| Reduce cost           | ✅   |
| Keep data available   | ✅   |
| Maintain API contract | ✅   |
| No downtime           | ✅   |
| Simple to implement   | ✅   |

Update with terraform script for provison the Infrastructure using terraform for the requirement.
