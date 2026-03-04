# ADR 019: AI Genesis Engine Architecture

## Status
Proposed

## Context
The AI Genesis Engine is intended to automate quiz creation. We need a "free" or low-cost solution that is production-ready. 
Options evaluated include:
1. **Google Gemini (Free Tier)**: High capability, 1M token context, cloud-dependent.
2. **Groq (Free Tier)**: Ultra-fast inference, high rate limits, cloud-dependent.
3. **Local LLM (Mediapipe + Gemma 2B)**: Offline, true privacy, zero API cost at scale, but heavy on device hardware and model quality varies.
4. **Hugging Face / OpenRouter**: Aggregators, but often complex to manage free keys.

## Why not Local (Gemma 2B) as Primary?

While "Local Sovereignty" is attractive for privacy and cost, it is unsuitable as a *primary* enterprise solution for three reasons:

1.  **Context Capacity Gap**: Gemma 2B has an **8K token limit**, whereas Gemini 1.5 Flash supports **1M tokens**. In production, a user uploading a 20-page PDF or a long YouTube transcript would cause Gemma to crash or produce fragmented, low-quality results.
2.  **Hardware Inclusivity**: Running Gemma 2B requires **4GB+ of dedicated RAM** and an NPU/High-end GPU. This would exclude approximately 40-60% of our potential user base who use mid-range or older devices.
3.  **UX Fatigue (Battery/Thermal)**: Local inference for a full 20-question quiz causes significant thermal spikes and can drain battery **10x faster** than a cloud API call. For a "quick" quiz creation tool, forcing the device to heat up is a poor user experience.

## Decision
We will adopt a **Hybrid AI Provider Strategy**.
*   **Primary**: Google Gemini (Cloud) - For complex, high-quality, large-context generation.
*   **Secondary**: Local Gemma (On-Device) - For basic "Topic-to-Quiz" offline fallback.

## Comparison Table

| Metric | Google Gemini | Groq (Llama 3) | Local (Gemma 2B) |
| :--- | :--- | :--- | :--- |
| **Complexity** | High (1M tokens) | Medium (8k-32k) | Low (Basic) |
| **Latency** | 1-3s | <1s | Device Dependent |
| **Cost** | Free Tier (RPM limited) | Free Tier (High limits) | Zero (Device power) |
| **Offline** | No | No | **Yes** |
| **Production Fit** | Best for Docs | Best for Speed | Best for Privacy/Basic |

## Consequences
*   **Positive**: Zero vendor lock-in. If Google changes Gemini terms, we switch to Groq or Local with one line of code.
*   **Positive**: High reliability (cloud power + local fallback).
*   **Negative**: Initial development overhead to implement multiple providers.
*   **Negative**: Larger app size (~200MB-500MB) if local model weights are bundled.
