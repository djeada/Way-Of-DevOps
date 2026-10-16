# Observability and incidents

Observability helps explain what a running system is doing and why a user-visible result occurred. Collect enough evidence to detect a problem, locate its cause, and verify a repair without overwhelming the people or systems that use it.

## Metrics, logs, and traces

Metrics summarize measurements over time, such as request counts or latency distributions. Logs describe individual events with context. Traces connect operations across a request's path through several components.

Use timestamps, service names, environment identifiers, and release versions consistently. Correlation identifiers can connect related events. Avoid secrets and unnecessary personal data. Limit retention, sampling, and access according to the information's purpose.

A possible stack uses Prometheus for metrics, Grafana for dashboards, a centralized log backend, and OpenTelemetry instrumentation for telemetry collection. Choose the smallest setup that answers the service's operational questions; these products are examples, not required layers.

## Measure what users experience

Start with latency, traffic, errors, and saturation, then add the dependencies that explain changes in those signals. Separate successful and failed request latency. Percentiles reveal slow tails that an average can hide, but require appropriate measurement and aggregation.

Keep metric labels bounded. A user ID or arbitrary request path can create too many time series. Put detailed per-request context in restricted logs or traces instead.

A service-level indicator (SLI) measures a result, such as the fraction of valid requests that succeed. A service-level objective (SLO) sets its target and time window. For a 99.9% request-success target over 30 days, 1,000 failures out of 1,000,000 eligible requests consume the whole error budget. Define what counts as eligible and successful before calculating it.

## Alerts that lead to action

Page someone when timely action is needed for a significant service impact. Use tickets or scheduled review for slower capacity and maintenance issues. Route each alert to an owner and link a short runbook with the signal, likely checks, and a safe mitigation.

Test that alerts reach the intended destination and recover when the condition clears. Repeated false alarms should lead to a change in the signal or response plan.

## A small incident workflow

1. Confirm the impact and identify the affected service, users, and start time.
2. Assign coordination and investigation responsibilities, even if one person initially holds both.
3. Mitigate with a known action, such as stopping a rollout, reducing load, or restoring a dependency.
4. Verify recovery using user-facing evidence and communicate the current state.
5. Record a timeline and follow-up actions that reduce recurrence or recovery time.

Preserve useful evidence and avoid changing several unrelated things at once. Review the system conditions and decisions that allowed the incident, then track improvements with owners. See [backup and recovery](backup_and_recovery.md) for incidents involving data loss.

References: [Google SRE monitoring](https://sre.google/sre-book/monitoring-distributed-systems/) and [service-level objectives](https://sre.google/sre-book/service-level-objectives/).
