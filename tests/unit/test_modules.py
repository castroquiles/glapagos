"""Unit tests for GLAPAGOS source modules."""

import src.api
import src.cli
import src.core
import src.sdk


def test_sdk_version():
    assert src.sdk.__version__ == "0.1.0"


def test_api_importable():
    assert src.api is not None


def test_cli_importable():
    assert src.cli is not None


def test_core_importable():
    assert src.core is not None


def test_sdk_importable():
    assert src.sdk is not None
