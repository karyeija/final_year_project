bool isXequaltoY(List<List<double>> points) {
  const epsilon = 1e-9; // Small tolerance for floating-point comparison
  for (var point in points) {
    if ((point[0] - point[1]).abs() < epsilon) {
      return true; // Return true if x == y for any point
    }
  }
  return false; // Return false if no points have x == y
}

///The input is a list of lists, where each inner list represents a point, with two values: the x-coordinate (point[0]) and the y-coordinate (point[1]).
///The loop iterates over each point in the list.
///If for any point, point[0] (x-coordinate) is equal to point[1] (y-coordinate), the function returns true immediately.
///If no such point is found, the function returns false after the loop finishes.
bool duplicateRows(List<List<double>> points) {
  var uniqueRows = <List<double>>[];
  for (var row in points) {
    if (uniqueRows
        .any((existing) => existing[0] == row[0] && existing[1] == row[1])) {
      return true;
    }
    uniqueRows.add(row);
  }
  return false;
}

bool columnDuplicates(
    List<List<double>> values, int columnIndex, int targetRepetitions) {
  var countMap = <double, int>{};
  for (var row in values) {
    countMap[row[columnIndex]] = (countMap[row[columnIndex]] ?? 0) + 1;
  }
  return countMap.values.any((count) => count == targetRepetitions);
}

bool isColumnOrdered(List<List<double>> points, int columnIndex) {
  for (int i = 0; i < points.length - 1; i++) {
    if (points[i][columnIndex] > points[i + 1][columnIndex]) {
      return false;
    }
  }
  return true;
}
