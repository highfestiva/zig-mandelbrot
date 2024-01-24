const std = @import("std");
const print = std.debug.print;

fn mandelbrot(cReal: f64, cImag: f64, maxIter: u32) u32 {
    var zReal: f64 = 0.0;
    var zImag: f64 = 0.0;
    var n: u32 = 0;
    
    while (n < maxIter and zReal * zReal + zImag * zImag < 4.0) : (n += 1) {
        var nextZReal: f64 = zReal * zReal - zImag * zImag + cReal;
        var nextZImag: f64 = 2.0 * zReal * zImag + cImag;
        zReal = nextZReal;
        zImag = nextZImag;
    }
    
    return n;
}

fn printMandelbrot(width: u32, height: u32, minX: f64, minY: f64, maxX: f64, maxY: f64, maxIter: u32) void {
    const dx: f64 = (maxX - minX) / @as(f64, @floatFromInt(width));
    const dy: f64 = (maxY - minY) / @as(f64, @floatFromInt(height));
    
    print("P2\n{d} {d}\n255\n", .{width, height});
    
    for (0..height) |y| {
        for (0..width) |x| {
            const cReal: f64 = minX + @as(f64, @floatFromInt(x)) * dx;
            const cImag: f64 = minY + @as(f64, @floatFromInt(y)) * dy;
            
            const iter: u32 = mandelbrot(cReal, cImag, maxIter);
            //const value: u8 = @truncate(iter);
            
            print("{d}\n", .{iter});
        }
    }
}

pub fn main() !void {
    const width = try get_n();
    
    const minX: f64 = -3.0;
    const minY: f64 = -2.0;
    const maxX: f64 = 1.0;
    const maxY: f64 = 2.0;
    
    const maxIter: u32 = 255;
    
    printMandelbrot(width, width, minX, minY, maxX, maxY, maxIter);
}

fn get_n() !u32 {
    var arg_it = std.process.args();
    _ = arg_it.skip();
    const arg = arg_it.next() orelse return 10;
    return try std.fmt.parseInt(u32, arg, 10);
}
