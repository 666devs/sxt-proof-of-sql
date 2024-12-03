#![allow(clippy::cast_possible_wrap)]
use super::OptionalRandBound;
use proof_of_sql::base::database::ColumnType;

const SINGLE_COLUMN_FILTER_TITLE: &str = "Single Column Filter";
const SINGLE_COLUMN_FILTER_SQL: &str = "SELECT b FROM table WHERE a = 0";
const SINGLE_COLUMN_FILTER_COLUMNS: &[(&str, ColumnType, OptionalRandBound)] = &[
    (
        "a",
        ColumnType::BigInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    ("b", ColumnType::VarChar, None),
];
const MULTI_COLUMN_FILTER_TITLE: &str = "Multi Column Filter";
const MULTI_COLUMN_FILTER_SQL: &str =
    "SELECT * FROM table WHERE ((a = 0) or (b = 1)) and (not (c = 'a'))";
const MULTI_COLUMN_FILTER_COLUMNS: &[(&str, ColumnType, OptionalRandBound)] = &[
    (
        "a",
        ColumnType::BigInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    (
        "b",
        ColumnType::BigInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    ("c", ColumnType::VarChar, None),
];
const ARITHMETIC_TITLE: &str = "Arithmetic";
const ARITHMETIC_SQL: &str =
    "SELECT a + b as r0, a * b - 2 as r1, c FROM table WHERE a <= b AND a >= 0";
const ARITHMETIC_COLUMNS: &[(&str, ColumnType, OptionalRandBound)] = &[
    (
        "a",
        ColumnType::BigInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    (
        "b",
        ColumnType::TinyInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    ("c", ColumnType::VarChar, None),
];
const GROUPBY_TITLE: &str = "Group By";
const GROUPBY_SQL: &str =
    "SELECT a, COUNT(*) FROM table WHERE (c = TRUE) and (a <= b) and (a > 0) GROUP BY a";
const GROUPBY_COLUMNS: &[(&str, ColumnType, OptionalRandBound)] = &[
    (
        "a",
        ColumnType::Int128,
        Some(|size| (size / 10).max(10) as i64),
    ),
    (
        "b",
        ColumnType::TinyInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    ("c", ColumnType::Boolean, None),
];
const AGGREGATE_TITLE: &str = "Aggregate";
const AGGREGATE_SQL: &str = "SELECT SUM(a) FROM table WHERE b = a OR c = 'ab'";
const AGGREGATE_COLUMNS: &[(&str, ColumnType, OptionalRandBound)] = &[
    (
        "a",
        ColumnType::BigInt,
        Some(|size| (size / 10).max(10) as i64),
    ),
    (
        "b",
        ColumnType::Int,
        Some(|size| (size / 10).max(10) as i64),
    ),
    ("c", ColumnType::VarChar, None),
];

#[allow(clippy::type_complexity)]
pub const QUERIES: &[(&str, &str, &[(&str, ColumnType, OptionalRandBound)])] = &[
    (
        SINGLE_COLUMN_FILTER_TITLE,
        SINGLE_COLUMN_FILTER_SQL,
        SINGLE_COLUMN_FILTER_COLUMNS,
    ),
    (
        MULTI_COLUMN_FILTER_TITLE,
        MULTI_COLUMN_FILTER_SQL,
        MULTI_COLUMN_FILTER_COLUMNS,
    ),
    (ARITHMETIC_TITLE, ARITHMETIC_SQL, ARITHMETIC_COLUMNS),
    (GROUPBY_TITLE, GROUPBY_SQL, GROUPBY_COLUMNS),
    (AGGREGATE_TITLE, AGGREGATE_SQL, AGGREGATE_COLUMNS),
];
