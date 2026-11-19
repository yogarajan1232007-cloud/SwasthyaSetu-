import os
import sys
from logging.config import fileConfig

from alembic import context

# Add backend directory to Python path
sys.path.insert(
    0,
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from app.database.session import Base, engine

# Import all models
import app.models

# Alembic configuration
config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Metadata for automatic migrations
target_metadata = Base.metadata


# OFFLINE MIGRATIONS
def run_migrations_offline():

    context.configure(
        url=str(engine.url),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


# ONLINE MIGRATIONS
def run_migrations_online():

    with engine.connect() as connection:

        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with context.begin_transaction():
            context.run_migrations()


# EXECUTE MIGRATIONS
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()