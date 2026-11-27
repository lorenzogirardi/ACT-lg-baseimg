from scripts.canary import CANARY_LIMIT, below_limit


def test_below_the_limit_is_below():
    assert below_limit(CANARY_LIMIT - 1)


def test_the_limit_itself_is_not_below():
    assert not below_limit(CANARY_LIMIT)


def test_above_the_limit_is_not_below():
    assert not below_limit(CANARY_LIMIT + 1)
