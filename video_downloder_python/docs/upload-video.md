# WidCash App — API Usage Guide

API reference for the **WidCash** mobile app. Covers **Fetch Reels** and **Withdrawal** endpoints.

---

## Base URL

| Environment | URL |
|---|---|
| Production | `https://widcash.preptm.com` |
| Development | `http://localhost:5120` |

---

## Response Format

All endpoints return this wrapper:

```json
{
  "Success": true,
  "Message": "string",
  "Data": <T>
}
```

| Field | Type | Description |
|---|---|---|
| `Success` | `boolean` | `true` = success, `false` = error |
| `Message` | `string` | Status message |
| `Data` | `T \| null` | Response payload or `null` on error |

---

## 1. Fetch Reels

```
POST /api/Reel/fetch
```

Fetch a paginated list of reels with optional keyword filter. Uses **cursor-based pagination**.

### Request

**Content-Type:** `application/json`

| Field | Type | Required | Description |
|---|---|---|---|
| `Timestamp` | `string` (ISO 8601) | Yes | Cursor — returns records created **before** this time. Pass current UTC time for first page. |
| `PageSize` | `integer` (≥ 1) | Yes | Number of records per page |
| `Keyword` | `string` | No | Filter by keyword (partial match). Pass `null` or `""` for all reels. |

**First page request:**
```json
{
  "Timestamp": "2026-03-16T12:00:00Z",
  "PageSize": 10,
  "Keyword": null
}
```

**With keyword filter:**
```json
{
  "Timestamp": "2026-03-16T12:00:00Z",
  "PageSize": 10,
  "Keyword": "cricket"
}
```

### Response — `200 OK`

```json
{
  "Success": true,
  "Message": "Success",
  "Data": [
    {
      "FileName": "https://widcash.preptm.com/Content/Reel/3f2a1b4c-9e8d-7f6a-5b4c-3d2e1f0a9b8c_myvideo.mp4",
      "AdditionalData": "My first reel",
      "Keyword": "cricket",
      "CreatedAt": "2026-03-14T08:22:11Z"
    },
    {
      "FileName": "https://widcash.preptm.com/Content/Reel/7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d_highlights.mp4",
      "AdditionalData": "Match highlights",
      "Keyword": "cricket",
      "CreatedAt": "2026-03-13T15:10:44Z"
    }
  ]
}
```

| Field | Type | Description |
|---|---|---|
| `FileName` | `string` | Full video URL — use directly in video player |
| `AdditionalData` | `string` | Metadata stored at upload time |
| `Keyword` | `string` | Keyword tag |
| `CreatedAt` | `string` (ISO 8601) | Upload timestamp (UTC) |

### Pagination

| Page | How |
|---|---|
| **First page** | `Timestamp` = current UTC time |
| **Next page** | `Timestamp` = `CreatedAt` of the **last item** received |
| **No more data** | `Data` array is empty `[]` |

### Error Responses

```json
{
  "Success": false,
  "Message": "Invalid request. Timestamp and PageSize are required.",
  "Data": null
}
```

### Dart (Flutter) Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://widcash.preptm.com';

Future<List<dynamic>> fetchReels({
  required DateTime timestamp,
  int pageSize = 10,
  String? keyword,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/Reel/fetch'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'Timestamp': timestamp.toUtc().toIso8601String(),
      'PageSize': pageSize,
      'Keyword': keyword,
    }),
  );

  final result = jsonDecode(response.body);
  if (result['Success'] == true) {
    return result['Data'] as List<dynamic>;
  } else {
    throw Exception(result['Message']);
  }
}

// --- Usage ---

// First page (all reels)
final reels = await fetchReels(timestamp: DateTime.now().toUtc());

// First page (filtered by keyword)
final cricketReels = await fetchReels(
  timestamp: DateTime.now().toUtc(),
  keyword: 'cricket',
);

// Next page (pass CreatedAt of last item)
final nextPage = await fetchReels(
  timestamp: DateTime.parse(reels.last['CreatedAt']),
);

// Use the video URL
for (final reel in reels) {
  print(reel['FileName']);       // full video URL
  print(reel['AdditionalData']);
  print(reel['Keyword']);
  print(reel['CreatedAt']);
}
```

---

## 2. Withdrawal Request

```
POST /api/Withdrawal/request
```

Create a new withdrawal request for coin cashout.

### Request

**Content-Type:** `application/json`

| Field | Type | Required | Description |
|---|---|---|---|
| `TotalCoins` | `decimal` | Yes | Amount of coins to withdraw |
| `UUID` | `string` | Yes | User identifier |
| `UpiId` | `string` | No | UPI ID for payment |
| `AccountNo` | `string` (max 50) | No | Bank account number |
| `IFSCCode` | `string` (max 20) | No | Bank IFSC code |
| `Email` | `string` (max 200) | No | User email address |

**Example — UPI withdrawal:**
```json
{
  "TotalCoins": 500.50,
  "UUID": "user-uuid-here",
  "UpiId": "user@upi"
}
```

**Example — Bank account withdrawal:**
```json
{
  "TotalCoins": 1000.00,
  "UUID": "user-uuid-here",
  "AccountNo": "1234567890",
  "IFSCCode": "SBIN0001234",
  "Email": "user@example.com"
}
```

### Response — `200 OK`

```json
{
  "Success": true,
  "Message": "Withdrawal request submitted successfully.",
  "Data": "Success"
}
```

### Error Responses

```json
{
  "Success": false,
  "Message": "Invalid request. TotalCoins and UUID are required.",
  "Data": null
}
```

### Dart (Flutter) Example

```dart
Future<String> requestWithdrawal({
  required double totalCoins,
  required String uuid,
  String? upiId,
  String? accountNo,
  String? ifscCode,
  String? email,
}) async {
  final body = <String, dynamic>{
    'TotalCoins': totalCoins,
    'UUID': uuid,
  };
  if (upiId != null) body['UpiId'] = upiId;
  if (accountNo != null) body['AccountNo'] = accountNo;
  if (ifscCode != null) body['IFSCCode'] = ifscCode;
  if (email != null) body['Email'] = email;

  final response = await http.post(
    Uri.parse('$baseUrl/api/Withdrawal/request'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  final result = jsonDecode(response.body);
  if (result['Success'] == true) {
    return result['Message'];
  } else {
    throw Exception(result['Message']);
  }
}

// --- Usage ---

// UPI withdrawal
await requestWithdrawal(
  totalCoins: 500.50,
  uuid: 'user-uuid-here',
  upiId: 'user@upi',
);

// Bank account withdrawal
await requestWithdrawal(
  totalCoins: 1000.00,
  uuid: 'user-uuid-here',
  accountNo: '1234567890',
  ifscCode: 'SBIN0001234',
  email: 'user@example.com',
);
```

---

## 3. Withdrawal History

```
POST /api/Withdrawal/history
```

Retrieve all withdrawal requests for a user.

### Request

**Content-Type:** `application/json`

**Body:** Plain string containing the UUID.

```json
"user-uuid-here"
```

### Response — `200 OK`

```json
{
  "Success": true,
  "Message": "Success",
  "Data": [
    {
      "Id": 1,
      "UUID": "user-uuid-here",
      "TotalCoins": 500.50,
      "UpiId": "user@upi",
      "AccountNo": null,
      "IFSCCode": null,
      "Email": "user@example.com",
      "PaymentStatus": "Pending",
      "Remarks": null,
      "CreatedAt": "2026-03-15T10:30:00Z"
    },
    {
      "Id": 2,
      "UUID": "user-uuid-here",
      "TotalCoins": 1000.00,
      "UpiId": null,
      "AccountNo": "1234567890",
      "IFSCCode": "SBIN0001234",
      "Email": "user@example.com",
      "PaymentStatus": "Completed",
      "Remarks": "Paid via NEFT",
      "CreatedAt": "2026-03-10T14:20:00Z"
    }
  ]
}
```

| Field | Type | Description |
|---|---|---|
| `Id` | `long` | Withdrawal request ID |
| `UUID` | `string` | User identifier |
| `TotalCoins` | `decimal` | Withdrawal amount |
| `UpiId` | `string \| null` | UPI ID |
| `AccountNo` | `string \| null` | Bank account number |
| `IFSCCode` | `string \| null` | IFSC code |
| `Email` | `string \| null` | Email address |
| `PaymentStatus` | `string` | `Pending`, `Completed`, `Failed`, or `Rejected` |
| `Remarks` | `string \| null` | Admin remarks |
| `CreatedAt` | `string` (ISO 8601) | Request creation timestamp (UTC) |

### Error Responses

```json
{
  "Success": false,
  "Message": "UUID is required.",
  "Data": null
}
```

### Dart (Flutter) Example

```dart
Future<List<dynamic>> getWithdrawalHistory(String uuid) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/Withdrawal/history'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(uuid),
  );

  final result = jsonDecode(response.body);
  if (result['Success'] == true) {
    return result['Data'] as List<dynamic>;
  } else {
    throw Exception(result['Message']);
  }
}

// --- Usage ---

final history = await getWithdrawalHistory('user-uuid-here');

for (final item in history) {
  print('${item['TotalCoins']} coins — ${item['PaymentStatus']}');
  print('Requested: ${item['CreatedAt']}');
  if (item['UpiId'] != null) print('UPI: ${item['UpiId']}');
  if (item['AccountNo'] != null) print('Account: ${item['AccountNo']}');
}
```

---

## Quick Reference

| Action | Method | Endpoint |
|---|---|---|
| Fetch reels | `POST` | `/api/Reel/fetch` |
| Create withdrawal | `POST` | `/api/Withdrawal/request` |
| Withdrawal history | `POST` | `/api/Withdrawal/history` |

---

## Error Reference

| Endpoint | Error Message | Cause |
|---|---|---|
| Fetch Reels | `Invalid request. Timestamp and PageSize are required.` | Missing required fields |
| Fetch Reels | `Fetch failed: <detail>` | Server/DB error |
| Withdrawal Request | `Invalid request. TotalCoins and UUID are required.` | Missing required fields |
| Withdrawal History | `UUID is required.` | Empty or missing UUID |