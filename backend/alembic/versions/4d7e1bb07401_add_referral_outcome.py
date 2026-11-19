"""add referral outcome

Revision ID: 4d7e1bb07401
Revises: adcd85c6aa68
"""

from alembic import op
import sqlalchemy as sa


revision = "4d7e1bb07401"
down_revision = "adcd85c6aa68"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "referrals",
        sa.Column("outcome", sa.Text(), nullable=True)
    )


def downgrade() -> None:
    op.drop_column("referrals", "outcome")