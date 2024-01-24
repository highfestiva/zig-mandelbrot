const std = @import("std");
const simd = @import("std").simd;

fn mandelbrot(cReal: [8]f64, cImag: [8]f64, maxIter: u32) [8]u32 {
    var zReal: [8]f64 = undefined;
    var zImag: [8]f64 = undefined;
    var n: [8]u32 = undefined;

    zReal = simd.set(f64, 0.0);
    zImag = simd.set(f64, 0.0);
    n = simd.splat(u32, 0);

    var iter: [8]u32 = simd.splat(u32, 0);
    var mask: [8]bool = simd.splat(bool, true);
    var count: u32 = 0;

    while (count < maxIter) : (count += 1) {
        var nextZReal: [8]f64 = simd.mul(zReal, zReal);
        var nextZImag: [8]f64 = simd.mul(zImag, zImag);
        nextZReal = simd.sub(nextZReal, nextZImag);
        nextZReal = simd.add(nextZReal, cReal);
        nextZImag = simd.mul(zReal, zImag);
        nextZImag = simd.add(nextZImag, nextZImag);
        nextZImag = simd.add(nextZImag, cImag);
        zReal = nextZReal;
        zImag = nextZImag;

        iter = simd.add(iter, simd.masked(mask, n));
        //mask = simd.and(mask, simd.cmplt(f64, simd.add(nextZReal, nextZImag), 4.0));
        n = simd.add(n, simd.splat(u32, 1));
    }

    return iter;
}

fn printMandelbrot(width: u32, height: u32, minX: f64, minY: f64, maxX: f64, maxY: f64, maxIter: u32) void {
    const dx: f64 = (maxX - minX) / @as(f64, @floatFromInt(width - 1));
    const dy: f64 = (maxY - minY) / @as(f64, @floatFromInt(height - 1));

    std.debug.print("P2\n{} {}\n255\n", .{width, height});

    var cReal: [8]f64 = undefined;
    var cImag: [8]f64 = undefined;

    for (0..height) |y| {
        cImag = simd.set(f64, minY + @as(f64, @floatFromInt(y)) * dy);

        var x: u32 = 0;
        while (x < width) : (x += 8) {
            for (0..8) |i| {
                cReal[i] = minX + @as(f64, @floatFromInt(x + i)) * dx;
            }

            const iter: [8]u32 = mandelbrot(cReal, cImag, maxIter);

            for (0..8) |i| {
                const value: u8 = u8(iter[i] % 256);
                std.debug.print("{}\n", .{value});
            }
        }
    }
}

pub fn main() !void {
    const width = try get_n();

    const minX: f64 = -2.5;
    const minY: f64 = -1.0;
    const maxX: f64 = 1.0;
    const maxY: f64 = 1.0;

    const maxIter: u32 = 256;

    printMandelbrot(width, width, minX, minY, maxX, maxY, maxIter);
}

fn get_n() !u32 {
    var arg_it = std.process.args();
    _ = arg_it.skip();
    const arg = arg_it.next() orelse return 10;
    return try std.fmt.parseInt(u32, arg, 10);
}
