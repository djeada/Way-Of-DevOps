# Canary releases

A canary release exposes a change to a small part of production traffic before expanding it. Comparing that group with the stable version helps detect problems while limiting their initial impact.

## Choose how to expose the change

- Route a small share of requests to instances running the new version.
- Upgrade a selected customer, region, or tenant first.
- Use a feature flag to enable new behavior for a selected cohort.

A feature flag controls behavior inside deployed code; a traffic-based canary controls which version handles requests. They can be used together. Keep a user's cohort stable when switching between versions would disrupt a session or produce inconsistent behavior.

## Plan the rollout

Before starting, choose the stable baseline, the initial cohort, the measurements, the observation window, and the stopping rules. An illustrative progression is 1%, 5%, 25%, then 100%, but the percentages and timing depend on traffic volume and risk.

Compare error rate, latency, resource use, and a meaningful product signal such as successful checkout. Account for differences between cohorts: internal staff or one region may not represent all users. Low-volume services need a longer observation window or additional synthetic checks.

Stop expansion when agreed limits are exceeded, investigate, and return traffic to the stable version when appropriate. Keep enough stable capacity to receive that traffic. Confirm that both versions can use the same database and messages during the transition.

## Example with a feature flag

```python
def checkout(request, flags):
    if flags.enabled("new-checkout", subject=request.user_id):
        return new_checkout(request)
    return existing_checkout(request)
```

This is illustrative pseudocode; `flags` represents a flag service or application configuration. Log the flag and version identifiers needed for diagnosis without exposing personal data. Restrict who can change production flags and remove obsolete branches after the rollout.

A canary reduces exposure while evidence is collected. It cannot guarantee safety for rare failures, destructive data changes, or background jobs that bypass the traffic split.

Related: [CI/CD](ci_cd.md) and [observability](observability.md). Reference: [Canary Release](https://martinfowler.com/bliki/CanaryRelease.html).
