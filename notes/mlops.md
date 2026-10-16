# MLOps fundamentals

MLOps applies repeatable delivery and operations practices to machine-learning systems. Model behavior depends on code, data, features, and training configuration, so a source revision alone is not enough to reproduce a release.

## Reproduce the model

Record the training code revision, dataset version or immutable reference, feature transformations, parameters, dependencies, random seeds, and evaluation results. Store model artifacts with their metadata and a clear promotion history.

Validate data schemas and quality before training. Separate training, validation, and test data to avoid leakage. Record evaluation slices that matter to the application, since an average score can hide poor performance for a particular group or scenario.

A repeatable pipeline can prepare data, train, evaluate, register an artifact, and deploy an approved model. Automatic retraining and automatic production promotion are separate decisions; a new model still needs evidence that it meets the required quality and operating constraints.

## Observe the running system

Monitor ordinary service health first: availability, error rate, request latency, inference latency, throughput, resource use, and cost. Centralize operational logs and identify the model version associated with each prediction or batch.

Then monitor behavior specific to ML:

- Data quality: missing fields, invalid values, stale features, and changed schemas.
- Training-serving skew: differences between feature processing during training and inference.
- Data drift: changes in the distribution of inputs.
- Concept drift: changes in the relationship between inputs and the intended outcome.
- Model quality: appropriate accuracy, calibration, or error measures when ground-truth outcomes become available.
- Product outcomes: the result the model is meant to improve, such as successful recommendations or reduced review time.

Input drift can be a warning, but does not prove that predictions have become worse. Ground truth may arrive late or be incomplete. Plan how predictions and later outcomes will be joined and evaluated without exposing unnecessary personal data.

## Logs, analysis, and feedback

Operational logs explain errors. Analytical events can record model identifiers, selected features, prediction summaries, and later outcomes. Apply access controls, redaction, sampling, and retention to this data; raw inputs can contain sensitive information.

A simple system may periodically write events to object storage and run batch analysis. Streaming through a broker and stream processor is useful only when the required reaction time justifies the extra components. Metrics, logs, and analytical data have different storage and query needs.

## Release and recover

Compare a candidate against the current model before promotion. Shadow traffic can reveal serving behavior without affecting user decisions; a controlled experiment can measure product impact. Both need care around load, privacy, and interpretation.

Retain a known-good artifact together with compatible feature code and schema expectations. Model rollback may require rolling back more than the weights. Define a fallback when inference is unavailable, input validation fails, or output quality becomes unacceptable.

Reference: [Google Cloud's MLOps guide](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning). Related: [CI/CD](ci_cd.md) and [observability](observability.md).
