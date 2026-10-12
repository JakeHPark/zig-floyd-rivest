const std = @import("std");

///Ensures that every element at index i in [0, k] in items is the (i + 1)-th order statistic.
pub fn partialSort(
    comptime T: type,
    items: []T,
    k: usize,
    context: anytype,
    comptime lessThanFn: fn (@TypeOf(context), lhs: T, rhs: T) bool,
) void {
    select(T, items, k, context, lessThanFn);
    //Selection only guarantees that the prefix contains the k + 1 smallest
    //elements. Sort that prefix rather than doing unnecessary work on the
    //remainder of the input.
    std.sort.insertion(T, items[0 .. k + 1], context, lessThanFn);
}

///Ensures that the element at index k of items is the (k + 1)-th order statistic.
///All elements to the left of k will be smaller than the element at index k.
pub fn select(
    comptime T: type,
    items: []T,
    k: usize,
    context: anytype,
    comptime lessThanFn: fn (@TypeOf(context), lhs: T, rhs: T) bool,
) void {
    selectLoop(T, items, 0, items.len - 1, k, context, lessThanFn);
}

fn selectLoop(
    comptime T: type,
    items: []T,
    left_index: usize,
    right_index: usize,
    k: usize,
    context: anytype,
    comptime lessThanFn: fn (@TypeOf(context), lhs: T, rhs: T) bool,
) void {
    var left = left_index;
    var right = right_index;

    while (right > left) {
        //Recursively select a smaller set of size s.
        //The arbitrary constants 600 and 0.5 are used to minimize execution time.
        if (right - left > 600) {
            const n: f32 = @floatFromInt(right - left + 1);
            const i: f32 = @floatFromInt(k - left + 1);
            const z = @log(n);
            const s = 0.5 * @exp(2.0 * z / 3.0);
            const sd = 0.5 * @sqrt(z * s * (n - s) / n) * std.math.sign(i - n / 2.0);

            const l: f32 = @floatFromInt(left);
            const r: f32 = @floatFromInt(right);
            const kf: f32 = @floatFromInt(k);

            const new_left: usize = @intFromFloat(@max(l, kf - i * s / n + sd));
            const new_right: usize = @intFromFloat(@min(r, kf + (n - i) * s / n + sd));
            selectLoop(T, items, new_left, new_right, k, context, lessThanFn);
        }

        //Partition the elements between left and right around t.
        const t = items[k];
        var i = left;
        var j = right;

        std.mem.swap(T, &items[left], &items[k]);

        if (lessThanFn(context, t, items[right])) {
            std.mem.swap(T, &items[right], &items[left]);
        }

        while (i < j) {
            std.mem.swap(T, &items[i], &items[j]);

            i += 1;
            j -= 1;

            while (lessThanFn(context, items[i], t)) {
                i += 1;
            }

            while (lessThanFn(context, t, items[j])) {
                j -= 1;
            }
        }

        if (items[left] == t) {
            std.mem.swap(T, &items[left], &items[j]);
        } else {
            j += 1;
            std.mem.swap(T, &items[j], &items[right]);
        }

        //Adjust left and right toward the boundaries of the subset containing the
        //(k - left - 1)th smallest element.
        if (j <= k) {
            left = j + 1;
        }

        if (k <= j) {
            if (j == 0) {
                break;
            }

            right = j - 1;
        }
    }
}

test {
    const items = [_]i64{ 5, 2, 1, 8, 4, 2, 9, 3, 1, 6, 30, 3, 2, 16, 7, 3, -32, -5 };

    var pdq_asc = items;
    std.sort.pdq(i64, &pdq_asc, {}, std.sort.asc(i64));
    var pdq_desc = items;
    std.sort.pdq(i64, &pdq_desc, {}, std.sort.desc(i64));

    var select_asc = items;
    select(i64, &select_asc, 6, {}, std.sort.asc(i64));
    try std.testing.expectEqual(pdq_asc[6], select_asc[6]);

    var select_desc = items;
    select(i64, &select_desc, 6, {}, std.sort.desc(i64));
    try std.testing.expectEqual(pdq_desc[6], select_desc[6]);

    var partial_sort_asc = items;
    partialSort(i64, &partial_sort_asc, 6, {}, std.sort.asc(i64));
    try std.testing.expectEqualSlices(i64, pdq_asc[0..7], partial_sort_asc[0..7]);

    var partial_sort_desc = items;
    partialSort(i64, &partial_sort_desc, 6, {}, std.sort.desc(i64));
    try std.testing.expectEqualSlices(i64, pdq_desc[0..7], partial_sort_desc[0..7]);
}
