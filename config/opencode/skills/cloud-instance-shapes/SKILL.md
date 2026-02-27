---
name: cloud-instance-shapes
description: Research and compare machine shapes across major clouds and neo-clouds using normalized fields
---

## Purpose

Compare compute instance shapes across providers with consistent fields, starting from fast aggregators and validating with provider sources.

## Primary source

- https://instances.vantage.sh/

Use this first for broad discovery and filtering.

## Secondary sources (validate and fill gaps)

- Official provider docs/pricing pages for AWS, GCP, Azure
- Neo-cloud docs/pricing pages (for example: Runpod, Lambda, CoreWeave, Vast)
- Provider CLI or API docs when shape metadata is unclear

## Normalized fields

For each candidate shape, capture:

- provider
- instance_type
- region
- vcpu
- memory_gib
- gpu_count
- gpu_model
- local_nvme_gib
- network_bandwidth_gbps
- on_demand_price_hour_usd
- spot_or_preemptible_price_hour_usd
- source_url
- source_timestamp

If a field is unknown, set `N/A` and note why.

## Workflow

1. Clarify constraints (workload type, GPU/CPU needs, min memory, region, budget).
2. Pull broad candidates from `instances.vantage.sh`.
3. Validate top candidates against provider docs for accuracy.
4. Return a compact comparison table plus recommendations.
5. Highlight tradeoffs (price vs performance vs availability risk).

## Output format

- Short recommendation summary (top 2-4 picks)
- Comparison table using normalized fields
- Notes section for caveats and missing data
- Source links for every recommendation

## Rules

- Do not infer missing numeric values; mark unknowns explicitly.
- Prefer current provider docs when aggregator and provider values differ.
- Call out region-specific constraints and stock/availability risk.
- Keep output concise and decision-oriented.
