package.path = package.path .. ";" .. vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua"

local number_tools = require("custom.number_tools")

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s\nexpected: %s\nactual:   %s", label, expected, actual))
  end
end

local function assert_contains(lines, expected, label)
  for _, line in ipairs(lines) do
    if line == expected then
      return
    end
  end

  error(string.format("%s\nmissing line: %s", label, expected))
end

assert_equal(
  number_tools.convert_number_base("0xAF", 2),
  "0b10101111",
  "hex to binary should pad to nibble boundaries"
)

assert_equal(
  number_tools.convert_number_base("0b1010'1111", 16),
  "0xAF",
  "grouped binary should convert to hex"
)

assert_equal(
  number_tools.convert_number_base("18446744073709545887", 16),
  "0xFFFFFFFFFFFFE99F",
  "large decimal should convert to exact hex"
)

assert_equal(
  number_tools.convert_number_base("18446744073709545887", 2),
  "0b1111111111111111111111111111111111111111111111111110100110011111",
  "large decimal should convert to exact binary"
)

local negative_preview = number_tools.build_number_preview_lines("-1")
assert_contains(negative_preview, "Bits:    8", "negative decimal should use minimal signed width")
assert_contains(negative_preview, "Bytes:   1", "negative decimal byte count should follow signed width")

local grouped_binary_preview = number_tools.build_number_preview_lines("0b010000001011")
assert_contains(grouped_binary_preview, "Bits:    12", "binary preview should preserve leading zero width")
assert_contains(grouped_binary_preview, "Bytes:   2", "binary preview byte count should preserve original width")

local explicit_float_preview = number_tools.build_number_preview_lines("0b11111111100000000000000000000000")
assert_contains(explicit_float_preview, "float32: -inf", "explicit 32-bit pattern should decode float32")
assert_contains(
  explicit_float_preview,
  "f32bits: s:0 e:10011110 (31) m:1111'1111'0000'0000'0000'000",
  "f32bits should encode the numeric value, not reinterpret the original bits"
)

local decimal_float_preview = number_tools.build_number_preview_lines("0.1")
assert_contains(decimal_float_preview, "Detected: float", "decimal float should be previewable")
assert_contains(decimal_float_preview, "float32: 0.10000000149012 ~= 0.1", "float32 row should show approximation and source")
assert_contains(decimal_float_preview, "float64: 0.1 ~= 0.1", "float64 row should show approximation and source")

print("number_tools tests passed")
