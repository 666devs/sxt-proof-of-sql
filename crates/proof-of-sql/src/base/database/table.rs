use super::Column;
use crate::base::{map::IndexMap, scalar::Scalar};
use proof_of_sql_parser::Identifier;
use snafu::Snafu;

/// An error that occurs when working with tables.
#[derive(Snafu, Debug, PartialEq, Eq)]
pub enum TableError {
    /// The columns have different lengths.
    #[snafu(display("Columns have different lengths"))]
    ColumnLengthMismatch,
}
/// A table of data, with schema included. This is simply a map from `Identifier` to `Column`,
/// where columns order matters.
/// This is primarily used as an internal result that is used before
/// converting to the final result in either Arrow format or JSON.
/// This is the analog of an arrow [`RecordBatch`](arrow::record_batch::RecordBatch).
#[derive(Debug, Clone, Eq)]
pub struct Table<'a, S: Scalar> {
    table: IndexMap<Identifier, Column<'a, S>>,
    num_rows: usize,
}
impl<'a, S: Scalar> Table<'a, S> {
    /// Creates a new [`Table`].
    pub fn try_new(table: IndexMap<Identifier, Column<'a, S>>) -> Result<Self, TableError> {
        if table.is_empty() {
            return Ok(Self { table, num_rows: 0 });
        }
        let num_rows = table[0].len();
        if table.values().any(|column| column.len() != num_rows) {
            Err(TableError::ColumnLengthMismatch)
        } else {
            Ok(Self { table, num_rows })
        }
    }
    /// Creates a new [`Table`].
    pub fn try_from_iter<T: IntoIterator<Item = (Identifier, Column<'a, S>)>>(
        iter: T,
    ) -> Result<Self, TableError> {
        Self::try_new(IndexMap::from_iter(iter))
    }
    /// Number of columns in the table.
    #[must_use]
    pub fn num_columns(&self) -> usize {
        self.table.len()
    }
    /// Number of rows in the table.
    #[must_use]
    pub fn num_rows(&self) -> usize {
        self.num_rows
    }
    /// Whether the table has no columns.
    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.table.is_empty()
    }
    /// Returns the columns of this table as an `IndexMap`
    #[must_use]
    pub fn into_inner(self) -> IndexMap<Identifier, Column<'a, S>> {
        self.table
    }
    /// Returns the columns of this table as an `IndexMap`
    #[must_use]
    pub fn inner_table(&self) -> &IndexMap<Identifier, Column<'a, S>> {
        &self.table
    }
    /// Returns the columns of this table as an Iterator
    pub fn column_names(&self) -> impl Iterator<Item = &Identifier> {
        self.table.keys()
    }
}

// Note: we modify the default PartialEq for IndexMap to also check for column ordering.
// This is to align with the behaviour of a `RecordBatch`.
impl<S: Scalar> PartialEq for Table<'_, S> {
    fn eq(&self, other: &Self) -> bool {
        self.table == other.table
            && self
                .table
                .keys()
                .zip(other.table.keys())
                .all(|(a, b)| a == b)
    }
}

#[cfg(test)]
impl<'a, S: Scalar> core::ops::Index<&str> for Table<'a, S> {
    type Output = Column<'a, S>;
    fn index(&self, index: &str) -> &Self::Output {
        self.table
            .get(&index.parse::<Identifier>().unwrap())
            .unwrap()
    }
}
