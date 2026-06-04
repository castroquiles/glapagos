# GLAPAGOS Python SDK

The GLAPAGOS Python SDK provides a Python client for the GLAPAGOS
platform API.

## Installation

    pip install glapagos

## Quick Start

    from glapagos import Client

    client = Client(base_url="https://api.glapagos.ai")

    # List available benchmarks
    benchmarks = client.benchmarks.list()

    # Submit a model to the registry
    client.registry.publish_model(
        name="my-multilingual-model",
        version="1.0.0",
        languages=["es", "pt", "qu"],
        license="apache-2.0",
        model_card_path="./model_card.md"
    )

    # Run a benchmark
    results = client.benchmarks.run(
        benchmark_id="amer-lang-v1",
        model_id="my-multilingual-model:1.0.0"
    )
    print(results.summary())

## Documentation

Full documentation is available at https://www.glapagos.ai/docs/sdk
