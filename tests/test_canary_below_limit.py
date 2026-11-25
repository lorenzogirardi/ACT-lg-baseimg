from scripts.canary import CANARY_LIMIT, below_limit, within_limit


def test_below_the_limit_is_below():
    assert below_limit(CANARY_LIMIT - 1)


def test_the_limit_itself_is_not_below():
    assert not below_limit(CANARY_LIMIT)


def test_above_the_limit_is_not_below():
    assert not below_limit(CANARY_LIMIT + 1)


def test_within_limit_allows_the_limit_and_below_limit_does_not():
    assert within_limit(CANARY_LIMIT) is True
    assert within_limit(CANARY_LIMIT + 1) is False
    assert below_limit(CANARY_LIMIT) is False
    assert below_limit(CANARY_LIMIT - 1) is True
