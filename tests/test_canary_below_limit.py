from scripts.canary import CANARY_LIMIT, below_limit


def test_the_limit_itself_is_not_below_the_limit():
    assert not below_limit(CANARY_LIMIT)


def test_below_the_limit_is_below():
    assert below_limit(CANARY_LIMIT - 1)
