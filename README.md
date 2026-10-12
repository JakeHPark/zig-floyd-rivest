# zig-floyd-rivest

The Floyd-Rivest selection algorithm in Zig.

## Usage

```zig
var items = [_]i64{ 5, 2, 1, 8, 4, 2, 9, 3, 1, 6, 30, 3, 2, 16, 7, 3, -32, -5 };
//This should set items[3] to 1, the fourth lowest value in the array.
//items[0..3] should only contain values lower than or equal to 1.
floyd_rivest.select(i64, &items, 3, {}, std.sort.asc(i64));
//This should set items[0..4] to { -32, -5, 1, 1 }.
//This works by running the Floyd-Rivest selection algorithm followed by an insertion sort
//on items[0..4].
//For larger values of k, a full unstable sort or other selection algorithms may be faster.
floyd_rivest.partialSort(i64, &items, 3, {}, std.sort.asc(i64));
```
