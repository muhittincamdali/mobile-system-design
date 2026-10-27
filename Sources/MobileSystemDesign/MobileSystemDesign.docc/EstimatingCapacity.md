# Estimating capacity

Turn a feature's usage into request rates, bandwidth, storage and phone budgets.

## Overview

A design discussion needs rough numbers before it can choose between architectures: whether a
feature needs a cache in front of the database, whether thumbnails must be resized on the
server, whether a phone can hold a day of messages. ``CapacityEstimate`` and ``ClientBudget``
make that arithmetic explicit and repeatable.

### Server-side numbers

Describe one day of usage:

```swift
let feed = try CapacityEstimate(
    dailyActiveUsers: 2_000_000,
    requestsPerUserPerDay: 40,
    averageResponseBytes: 30_000,
    uploadsPerUserPerDay: 0.2,
    averageUploadBytes: 1_500_000,
    retentionDays: 365,
    peakFactor: 3
)
```

| Property                                    | Formula                          | Value   |
| ------------------------------------------- | -------------------------------- | ------- |
| ``CapacityEstimate/averageRequestsPerSecond`` | users × requests ÷ 86,400        | ≈ 926   |
| ``CapacityEstimate/peakRequestsPerSecond``    | average × peak factor            | ≈ 2,778 |
| ``CapacityEstimate/dailyEgressBytes``         | requests per day × response size | 2.4 TB  |
| ``CapacityEstimate/dailyIngressBytes``        | users × uploads × upload size    | 600 GB  |
| ``CapacityEstimate/storageBytes``             | daily ingress × retention        | 219 TB  |
| ``CapacityEstimate/dailyBytesPerUser``        | requests × response size         | 1.2 MB  |

Size the servers for the peak, not the average. The peak factor is an assumption: traffic of
a consumer app follows the time of day, so the busiest hour carries several times the average
load; measure it once the app has users. Storage is before replication and backups.

The initializer throws ``CapacityEstimate/InvalidInput`` naming the first parameter that is
negative, NaN or infinite, and all arithmetic is in `Double`, so the results never overflow.

### Phone-side numbers

A photo's file size says little about its memory use. Decoded for display, every pixel takes
four bytes:

```swift
ClientBudget.decodedImageBytes(width: 4_000, height: 3_000)   // 48,000,000 bytes
ClientBudget.pixelLength(points: 390, scale: 3)                // 1,170 pixels
ClientBudget.imagesFitting(memoryBudget: 100_000_000, width: 1_170, height: 1_170) // 18
```

A 12-megapixel photo takes 48 MB decoded; the same photo decoded at the 1,170-pixel width of a
full-width cell takes under 6 MB. That is why image pipelines download a size close to the
display size and downsample before caching, and why an image cache's cost is the decoded size,
not the file size.

The functions use overflow-checked integer arithmetic and return `nil` for negative sizes or
products that do not fit in an `Int`, instead of trapping.

### Present the estimate

In a design document, show the inputs next to the results and say which inputs are
assumptions. A reviewer who disagrees with "40 requests per user per day" can change one
number and see every consequence. The `Estimator` lab of the example app does this
interactively.
