from datetime import date, datetime
from typing import Optional


def calculate_age(
    date_of_birth: Optional[date],
    reference_date: Optional[date] = None
) -> Optional[int]:
    """
    Calculate age on a specific reference date.

    Returns None when date of birth is unavailable.
    Raises ValueError when date of birth is in the future.
    """

    if date_of_birth is None:
        return None

    if isinstance(date_of_birth, datetime):
        date_of_birth = date_of_birth.date()

    if reference_date is None:
        reference_date = date.today()

    if isinstance(reference_date, datetime):
        reference_date = reference_date.date()

    if date_of_birth > reference_date:
        raise ValueError(
            "Date of birth cannot be in the future"
        )

    age = reference_date.year - date_of_birth.year

    birthday_not_reached = (
        reference_date.month,
        reference_date.day
    ) < (
        date_of_birth.month,
        date_of_birth.day
    )

    if birthday_not_reached:
        age -= 1

    return age