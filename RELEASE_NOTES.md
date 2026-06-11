# Release Notes

## Chart history and widget I/O optimization

- Reduced widget disk writes by throttling persisted widget activity and network totals.
- Switched line and network chart history to shared in-memory buffers where chart views represent the same metric.
- Increased chart precision with 5-second in-memory sampling while keeping the default visible history at 10 minutes.
- Kept per-disk popup chart history isolated by disk key so external drives and multiple disks do not share samples.
- Fixed line-chart preview data generation so settings previews fill the configured sample window.
