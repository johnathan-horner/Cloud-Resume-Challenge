"""Unit tests for the visitor counter Lambda (infra/lambda/func.py). No AWS calls."""

import importlib.util
import os
from pathlib import Path

import pytest

FUNC = Path(__file__).resolve().parent.parent / "infra" / "lambda" / "func.py"


class FakeTable:
    def __init__(self, item=None):
        self.item = item
        self.puts = []

    def get_item(self, Key):
        assert Key == {"id": "1"}
        return {"Item": dict(self.item)} if self.item is not None else {}

    def put_item(self, Item):
        self.puts.append(Item)
        self.item = Item
        return {}


@pytest.fixture
def func(monkeypatch):
    monkeypatch.setenv("AWS_DEFAULT_REGION", os.environ.get("AWS_DEFAULT_REGION", "us-east-1"))
    spec = importlib.util.spec_from_file_location("func", FUNC)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)  # creating the boto3 resource makes no network call
    return module


def test_increments_and_stores_the_count(func):
    func.table = FakeTable({"id": "1", "views": 41})
    assert func.lambda_handler({}, None) == 42
    assert func.table.puts == [{"id": "1", "views": 42}]


def test_counts_up_on_every_call(func):
    func.table = FakeTable({"id": "1", "views": 0})
    results = [func.lambda_handler({}, None) for _ in range(3)]
    assert results == [1, 2, 3]
    assert func.table.item["views"] == 3


def test_missing_item_returns_one(func):
    func.table = FakeTable(None)
    assert func.lambda_handler({}, None) == 1
