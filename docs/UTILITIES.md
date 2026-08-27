# Utilities

## ObjectPool

Generic reuse for tables or Instances. Supply a factory, optional reset callback, and optional destroy callback. Use `Acquire`, then always return the object with `Release`. `Warm` preallocates expected capacity. Double release is rejected.

## RateLimiter

A token-bucket limiter keyed by any value, normally `Player`. `Allow` consumes a token, `Remove` clears one player, and `Clear` resets the limiter. It smooths bursts without creating one delayed task per request.

## TableUtil

`DeepCopy` protects nested service state at API boundaries. `Count` counts dictionary entries without relying on the array length operator.

## NumberUtil

`IsFinite` rejects NaN and infinities before values reach calculations or persistence. `RoundTo` provides consistent UI-friendly rounding.

## Trove convention

Create one service/controller Trove for long-lived connections. Create child or per-player Troves for temporary work. Add connections, callback disconnectors, threads, and Instances immediately after creating them, then destroy the owning Trove at the end of its lifecycle.
