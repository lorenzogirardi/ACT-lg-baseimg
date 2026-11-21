from scripts.canary import CANARY_LIMIT, within_limit


def test_the_limit_itself_is_allowed():
    assert within_limit(CANARY_LIMIT)


def test_above_the_limit_is_not():
    assert not within_limit(CANARY_LIMIT + 1)
