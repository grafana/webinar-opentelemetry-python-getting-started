import sqlite3
from random import randint

from flask import Flask, request
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DB_PATH = "dice.db"


def get_db():
    return sqlite3.connect(DB_PATH)


def init_db():
    with get_db() as conn:
        # Use conn.cursor() explicitly instead of the conn.execute() shortcut:
        # the OpenTelemetry sqlite3 instrumentation wraps Connection.cursor(),
        # so cursors created through the shortcut bypass tracing.
        conn.cursor().execute(
            """
            CREATE TABLE IF NOT EXISTS rolls (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                player TEXT,
                result INTEGER NOT NULL
            )
            """
        )


@app.route("/rolldice")
def roll_dice():
    player = request.args.get('player', default=None, type=str)
    result = roll()
    if player:
        logger.warning("%s is rolling the dice: %s", player, result)
    else:
        logger.warning("Anonymous player is rolling the dice: %s", result)

    with get_db() as conn:
        conn.cursor().execute(
            "INSERT INTO rolls (player, result) VALUES (?, ?)",
            (player, result),
        )

    return str(result)


@app.route("/stats")
def stats():
    with get_db() as conn:
        rows = conn.cursor().execute(
            """
            SELECT COALESCE(player, 'anonymous') AS player,
                   COUNT(*) AS rolls,
                   AVG(result) AS avg_result
            FROM rolls
            GROUP BY player
            ORDER BY rolls DESC
            """
        ).fetchall()

    return {
        "stats": [
            {"player": player, "rolls": count, "avg_result": round(avg, 2)}
            for player, count, avg in rows
        ]
    }


def roll():
    return randint(1, 6)


init_db()
