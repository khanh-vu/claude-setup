# MLflow + LangGraph Observability Patterns

Reference for wiring MLflow experiment tracking into LangGraph-based agent projects. Adapted from the danai/Terminus CLAUDE.md.

## Why MLflow here

LangGraph runs are graphs of stateful nodes that call LLMs and tools. Without tracing you can't answer "why did this answer cite the wrong doc" or "which prompt changed the response". MLflow + LangChain autologging captures the full trace automatically — no manual instrumentation per node.

## Per-agent experiments

Each agent sets its own experiment name **before** invoking the graph. This keeps runs organized and lets you compare variants of the same agent over time.

```python
import mlflow
from src.agents.oracle import oracle_astream

# set before graph.astream() is called
mlflow.set_experiment("oracle-agent")

async for chunk_type, chunk_data in oracle_astream(params):
    # ... handle chunks
```

Suggested naming: `<agent-name>-agent` (e.g., `oracle-agent`, `book-digestor-agent`, `podcast-digestor-agent`).

## LangChain autologging

```python
import mlflow

mlflow.langchain.autolog()   # once, at app startup
```

This captures every LangChain call the graph makes — LLM invocations, tool calls, chain composition — and attaches them to the active run. You do not wrap nodes or add decorators.

## Environment

```bash
MLFLOW_TRACKING_ENABLED=true
MLFLOW_TRACKING_URI=http://localhost:5001       # local
# or
MLFLOW_TRACKING_URI=https://mlflow.yourdomain.com   # staging/prod
```

When `MLFLOW_TRACKING_ENABLED=false`, code should early-return from the autolog setup — no-op for test environments.

## Deployment

### Local

```bash
mlflow server \
  --host 0.0.0.0 \
  --port 5001 \
  --backend-store-uri sqlite:///mlflow.db \
  --default-artifact-root ./mlruns
```

Accessed at http://localhost:5001.

### Staging / Production

- Deploy the MLflow server as a separate Cloud Run service via Terraform (`terraform/modules/mlflow/`).
- Backend store: Postgres on a shared Cloud SQL instance, separate database (`mlflow`).
- Artifact root: a dedicated GCS bucket with lifecycle rules (7-day retention on dev, 90-day on prod).
- Auth: IAP in front of the Cloud Run service; service accounts for agent-side writes.

### Docker

```dockerfile
# Dockerfile.mlflow
FROM python:3.12-slim
RUN pip install mlflow psycopg2-binary google-cloud-storage
EXPOSE 5001
CMD ["mlflow", "server", \
     "--host", "0.0.0.0", \
     "--port", "5001", \
     "--backend-store-uri", "${MLFLOW_DB_URI}", \
     "--default-artifact-root", "${MLFLOW_ARTIFACT_ROOT}"]
```

## Patterns

### Tag runs with graph metadata

```python
with mlflow.start_run(run_name=f"conversation-{conversation_id}"):
    mlflow.set_tag("agent", "oracle")
    mlflow.set_tag("user_id", user_id)
    mlflow.set_tag("model_profile", "smart")
    result = await oracle_astream(params)
```

### Log per-node latency

LangChain autologging captures this automatically via span timing. Don't add manual `time.time()` wrappers.

### Compare experiments

```bash
# In the MLflow UI: filter by experiment, group by tag
# CLI:
mlflow experiments search --view-type all
mlflow runs list --experiment-id <id>
```

## What NOT to do

- **Don't wrap every node in `@mlflow.trace`.** Autolog already does it.
- **Don't log prompts/responses manually.** They're in the trace.
- **Don't use a single experiment for all agents.** Split by agent so experiments have tight semantic meaning.
- **Don't enable tracking in tests without `TESTING=True` isolation.** Test runs pollute the experiment list.

## Interop with LLM Registry

- The registry (`llm-registry-expert` agent's pattern) emits LLM calls through LangChain — autologging picks them up automatically.
- If you migrate a node off the registry to a raw SDK call, you lose MLflow coverage for that node. Don't.

## Debugging a bad agent run

1. Open MLflow UI, filter by the failing `conversation_id` tag.
2. Drill into the span tree: find the node where latency spiked or the prompt diverged.
3. Copy the exact LLM input from the trace; replay in a notebook with the same model profile.
4. If the issue is a prompt template, fix in code and rerun — autologging will capture the new run for A/B comparison.

## References

- MLflow LangChain autolog: https://mlflow.org/docs/latest/llms/langchain/autologging.html
- Pattern origin: gitlab.com/vokoban/danai, `CLAUDE.md` → MLflow Tracking Integration section.
- Our project template using this pattern: `templates/fastapi-langgraph.CLAUDE.md`.
