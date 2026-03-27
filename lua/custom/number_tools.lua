local M = {}

local ffi_ok, ffi = pcall(require, "ffi")

if ffi_ok then
  ffi.cdef[[
    typedef union { float f; uint8_t b[4]; } NumberToolsFloat32;
    typedef union { double d; uint8_t b[8]; } NumberToolsFloat64;
  ]]
end

local function strip_leading_zeros(text)
  local stripped = text:gsub("^0+", "")
  if stripped == "" then
    return "0"
  end

  return stripped
end

local function decimal_divmod_small(text, divisor)
  local quotient = {}
  local remainder = 0

  for i = 1, #text do
    local digit = tonumber(text:sub(i, i), 10)
    local value = remainder * 10 + digit
    local q = math.floor(value / divisor)
    remainder = value % divisor
    if #quotient > 0 or q ~= 0 then
      quotient[#quotient + 1] = tostring(q)
    end
  end

  if #quotient == 0 then
    return "0", remainder
  end

  return table.concat(quotient), remainder
end

local function decimal_mul_small(text, multiplier)
  local carry = 0
  local out = {}

  for i = #text, 1, -1 do
    local digit = tonumber(text:sub(i, i), 10)
    local value = digit * multiplier + carry
    out[#out + 1] = tostring(value % 10)
    carry = math.floor(value / 10)
  end

  while carry > 0 do
    out[#out + 1] = tostring(carry % 10)
    carry = math.floor(carry / 10)
  end

  return table.concat(vim.iter(out):rev():totable())
end

local function decimal_add_small(text, addend)
  local carry = addend
  local out = {}

  for i = #text, 1, -1 do
    local digit = tonumber(text:sub(i, i), 10)
    local value = digit + carry
    out[#out + 1] = tostring(value % 10)
    carry = math.floor(value / 10)
  end

  while carry > 0 do
    out[#out + 1] = tostring(carry % 10)
    carry = math.floor(carry / 10)
  end

  return table.concat(vim.iter(out):rev():totable())
end

local function unsigned_decimal_to_bits(text)
  local value = strip_leading_zeros(text)
  if value == "0" then
    return "0"
  end

  local bits = {}
  while value ~= "0" do
    value, remainder = decimal_divmod_small(value, 2)
    bits[#bits + 1] = tostring(remainder)
  end

  return table.concat(vim.iter(bits):rev():totable())
end

local function unsigned_bits_to_decimal(bits)
  local value = "0"
  for i = 1, #bits do
    value = decimal_mul_small(value, 2)
    if bits:sub(i, i) == "1" then
      value = decimal_add_small(value, 1)
    end
  end

  return strip_leading_zeros(value)
end

local function normalize_bits_to_width(bits, width)
  if #bits > width then
    return bits:sub(#bits - width + 1)
  end

  if #bits < width then
    return string.rep("0", width - #bits) .. bits
  end

  return bits
end

local function twos_complement_magnitude(bits)
  local inverted = bits:gsub("[01]", { ["0"] = "1", ["1"] = "0" })
  local out = {}
  local carry = 1

  for i = #inverted, 1, -1 do
    local bit = tonumber(inverted:sub(i, i), 10)
    local value = bit + carry
    out[#out + 1] = tostring(value % 2)
    carry = math.floor(value / 2)
  end

  return strip_leading_zeros(table.concat(vim.iter(out):rev():totable()))
end

local function signed_bits_to_decimal(bits)
  local normalized = bits
  if normalized:sub(1, 1) == "0" then
    return unsigned_bits_to_decimal(normalized)
  end

  return "-" .. unsigned_bits_to_decimal(twos_complement_magnitude(normalized))
end

local function bit_count_from_signed_decimal(value)
  if value >= -(2 ^ 7) then
    return 8
  end

  if value >= -(2 ^ 15) then
    return 16
  end

  if value >= -(2 ^ 31) then
    return 32
  end

  return 64
end

local function format_padded_binary_from_bits(bits)
  local padded = bits
  local remainder = #padded % 4
  if remainder ~= 0 then
    padded = string.rep("0", 4 - remainder) .. padded
  end

  return "0b" .. padded
end

local function format_grouped_binary_bits(bits)
  local padded = bits
  local remainder = #padded % 4
  if remainder ~= 0 then
    padded = string.rep("0", 4 - remainder) .. padded
  end

  return "0b" .. padded:gsub("(%d%d%d%d)", "%1'"):gsub("'$", "")
end

local function format_hex_from_bits(bits)
  local padded = bits
  local remainder = #padded % 4
  if remainder ~= 0 then
    padded = string.rep("0", 4 - remainder) .. padded
  end

  return "0x" .. padded:gsub("....", function(chunk)
    return tostring(vim.fn.printf("%X", tonumber(chunk, 2)))
  end)
end

local function base_name(base)
  return ({
    [2] = "binary",
    [8] = "octal",
    [10] = "decimal",
    [16] = "hex",
  })[base] or "unknown"
end

local function wrap_unsigned(value, bits)
  local modulo = 2 ^ bits
  return value % modulo
end

local function wrap_signed(value, bits)
  local unsigned = wrap_unsigned(value, bits)
  local sign_bit = 2 ^ (bits - 1)
  if unsigned >= sign_bit then
    return unsigned - (2 ^ bits)
  end

  return unsigned
end

local function float_bits_from_bytes(bytes, byte_count)
  local chunks = {}
  for i = byte_count - 1, 0, -1 do
    chunks[#chunks + 1] = tostring(vim.fn.printf("%08b", bytes[i]))
  end

  return table.concat(chunks)
end

local function bytes_from_bit_string(bits, width)
  local normalized = normalize_bits_to_width(bits, width)
  local bytes = {}
  for i = 1, width, 8 do
    bytes[#bytes + 1] = tonumber(normalized:sub(i, i + 7), 2)
  end

  return bytes
end

local function represent_as_float32(value)
  if not ffi_ok then
    return "unavailable", nil
  end

  local float_union = ffi.new("NumberToolsFloat32")
  float_union.f = tonumber(value)
  return tostring(float_union.f), float_bits_from_bytes(float_union.b, 4)
end

local function represent_as_float64(value)
  if not ffi_ok then
    return "unavailable", nil
  end

  local float_union = ffi.new("NumberToolsFloat64")
  float_union.d = tonumber(value)
  return tostring(float_union.d), float_bits_from_bytes(float_union.b, 8)
end

local function format_float_decimal(approximation, original)
  if approximation == "unavailable" then
    return approximation
  end

  return string.format("%s ~= %s", approximation, original)
end

local function interpret_bits_as_float32(bits)
  if not ffi_ok or not bits then
    return "unavailable"
  end

  local bytes = bytes_from_bit_string(bits, 32)
  local float_union = ffi.new("NumberToolsFloat32")
  for i = 1, #bytes do
    float_union.b[#bytes - i] = bytes[i]
  end

  return tostring(float_union.f)
end

local function interpret_bits_as_float64(bits)
  if not ffi_ok or not bits then
    return "unavailable"
  end

  local bytes = bytes_from_bit_string(bits, 64)
  local float_union = ffi.new("NumberToolsFloat64")
  for i = 1, #bytes do
    float_union.b[#bytes - i] = bytes[i]
  end

  return tostring(float_union.d)
end

local function format_float_parts(bits, exponent_bits, mantissa_bits, bias)
  if not bits then
    return "unavailable"
  end

  local sign = bits:sub(1, 1)
  local exponent = bits:sub(2, 1 + exponent_bits)
  local mantissa = bits:sub(2 + exponent_bits, 1 + exponent_bits + mantissa_bits)
  local exponent_raw = tonumber(exponent, 2)
  local mantissa_raw = tonumber(mantissa, 2)
  local max_exponent = (2 ^ exponent_bits) - 1
  local exponent_value

  if exponent_raw == 0 then
    if mantissa_raw == 0 then
      exponent_value = "zero"
    else
      exponent_value = tostring(1 - bias) .. " sub"
    end
  elseif exponent_raw == max_exponent then
    if mantissa_raw == 0 then
      exponent_value = "inf"
    else
      exponent_value = "nan"
    end
  else
    exponent_value = tostring(exponent_raw - bias)
  end

  return string.format(
    "s:%s e:%s (%s) m:%s",
    sign,
    exponent,
    exponent_value,
    mantissa:gsub("(%d%d%d%d)", "%1'"):gsub("'$", "")
  )
end

local function parse_text(text)
  local trimmed = vim.trim(text)
  local lowered = trimmed:lower()

  local binary_digits = lowered:match("^0b([01][01'_ ]*)$")
  if binary_digits then
    local bits = binary_digits:gsub("[ '_]", "")
    return {
      base = 2,
      value = tonumber(bits, 2),
      input_bits = bits,
      explicit_bits = true,
      trimmed = trimmed,
    }
  end

  local octal_digits = lowered:match("^0o([0-7]+)$")
  if octal_digits then
    local bits = octal_digits:gsub(".", function(digit)
      return tostring(vim.fn.printf("%03b", tonumber(digit, 8)))
    end)
    return {
      base = 8,
      value = tonumber(octal_digits, 8),
      input_bits = bits,
      explicit_bits = true,
      trimmed = trimmed,
    }
  end

  local hex_digits = lowered:match("^0x([%da-f]+)$")
  if hex_digits then
    local bits = hex_digits:gsub(".", function(digit)
      return tostring(vim.fn.printf("%04b", tonumber(digit, 16)))
    end)
    return {
      base = 16,
      value = tonumber(hex_digits, 16),
      input_bits = bits,
      explicit_bits = true,
      trimmed = trimmed,
    }
  end

  if lowered:match("^%-?%d+$") then
    local value = tonumber(lowered, 10)
    local sign = lowered:sub(1, 1) == "-" and -1 or 1
    local digits = sign == -1 and lowered:sub(2) or lowered
    local bits = sign == 1 and unsigned_decimal_to_bits(digits) or nil
    return {
      base = 10,
      value = value,
      input_bits = bits,
      explicit_bits = false,
      trimmed = trimmed,
      decimal_digits = digits,
      negative_decimal = sign == -1,
    }
  end

  local has_float_marker = lowered:find("%.") or lowered:find("[eE]")
  local float_value = tonumber(lowered)
  if has_float_marker and float_value ~= nil then
    return {
      base = 10,
      value = float_value,
      input_bits = nil,
      explicit_bits = false,
      trimmed = trimmed,
      is_float = true,
    }
  end

  return nil
end

function M.is_number_token_char(char)
  return char:match("[%w_'%.-]") ~= nil
end

function M.convert_number_base(text, target_base)
  local parsed = parse_text(text)
  if not parsed then
    return nil
  end

  if parsed.input_bits then
    if target_base == 2 then
      return format_padded_binary_from_bits(parsed.input_bits)
    end

    if target_base == 16 then
      return format_hex_from_bits(parsed.input_bits)
    end

    if target_base == 10 then
      if parsed.base == 10 then
        return parsed.trimmed
      end

      return unsigned_bits_to_decimal(parsed.input_bits)
    end
  end

  if parsed.value == nil then
    return nil
  end

  if target_base == 2 then
    local bits = tostring(vim.fn.printf("%b", parsed.value))
    local remainder = #bits % 4
    if remainder ~= 0 then
      bits = string.rep("0", 4 - remainder) .. bits
    end

    return "0b" .. bits
  end

  if target_base == 10 then
    return tostring(parsed.value)
  end

  return "0x" .. tostring(vim.fn.printf("%X", parsed.value))
end

function M.build_number_preview_lines(text)
  local parsed = parse_text(text)
  if not parsed then
    return nil
  end

  if parsed.is_float then
    local float32_value, float32_bits = represent_as_float32(parsed.value)
    local float64_value, float64_bits = represent_as_float64(parsed.value)

    return {
      string.format("Input: %s", parsed.trimmed),
      "Detected: float",
      string.format("Decimal: %s", parsed.trimmed),
      "",
      string.format("float32: %s", format_float_decimal(float32_value, parsed.trimmed)),
      string.format("f32bits: %s", format_float_parts(float32_bits, 8, 23, 127)),
      string.format("float64: %s", format_float_decimal(float64_value, parsed.trimmed)),
      string.format("f64bits: %s", format_float_parts(float64_bits, 11, 52, 1023)),
    }
  end

  local bit_count
  if parsed.input_bits then
    bit_count = #parsed.input_bits
  elseif parsed.value and parsed.value < 0 then
    bit_count = bit_count_from_signed_decimal(parsed.value)
  else
    bit_count = #tostring(vim.fn.printf("%b", parsed.value))
  end

  local float32_value, float32_bits = represent_as_float32(parsed.value)
  local float64_value, float64_bits = represent_as_float64(parsed.value)

  if parsed.explicit_bits then
    float32_value = interpret_bits_as_float32(parsed.input_bits)
    if #parsed.input_bits <= 32 then
      float64_value = float32_value
    else
      float64_value = interpret_bits_as_float64(parsed.input_bits)
    end
  end

  local binary_display
  local decimal_display
  local hex_display
  local uint8_display
  local int8_display
  local uint16_display
  local int16_display
  local uint32_display
  local int32_display
  local uint64_display
  local int64_display

  if parsed.input_bits then
    binary_display = format_grouped_binary_bits(parsed.input_bits)
    decimal_display = parsed.base == 10 and parsed.trimmed or unsigned_bits_to_decimal(parsed.input_bits)
    hex_display = format_hex_from_bits(parsed.input_bits)
    uint8_display = unsigned_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 8))
    int8_display = signed_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 8))
    uint16_display = unsigned_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 16))
    int16_display = signed_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 16))
    uint32_display = unsigned_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 32))
    int32_display = signed_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 32))
    uint64_display = unsigned_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 64))
    int64_display = signed_bits_to_decimal(normalize_bits_to_width(parsed.input_bits, 64))
  else
    local bits = tostring(vim.fn.printf("%b", parsed.value))
    local remainder = #bits % 4
    if remainder ~= 0 then
      bits = string.rep("0", 4 - remainder) .. bits
    end

    binary_display = "0b" .. bits:gsub("(%d%d%d%d)", "%1'"):gsub("'$", "")
    decimal_display = tostring(parsed.value)
    hex_display = "0x" .. tostring(vim.fn.printf("%X", parsed.value))
    uint8_display = tostring(wrap_unsigned(parsed.value, 8))
    int8_display = tostring(wrap_signed(parsed.value, 8))
    uint16_display = tostring(wrap_unsigned(parsed.value, 16))
    int16_display = tostring(wrap_signed(parsed.value, 16))
    uint32_display = tostring(wrap_unsigned(parsed.value, 32))
    int32_display = tostring(wrap_signed(parsed.value, 32))
    uint64_display = tostring(wrap_unsigned(parsed.value, 64))
    int64_display = tostring(wrap_signed(parsed.value, 64))
  end

  return {
    string.format("Input: %s", parsed.trimmed),
    string.format("Detected: %s", base_name(parsed.base)),
    string.format("Bits:    %d", bit_count),
    string.format("Bytes:   %d", math.max(1, math.ceil(bit_count / 8))),
    "",
    string.format("Binary:  %s", binary_display),
    string.format("Decimal: %s", decimal_display),
    string.format("Hex:     %s", hex_display),
    "",
    string.format("uint8:   %s", uint8_display),
    string.format("int8:    %s", int8_display),
    string.format("uint16:  %s", uint16_display),
    string.format("int16:   %s", int16_display),
    string.format("uint32:  %s", uint32_display),
    string.format("int32:   %s", int32_display),
    string.format("uint64:  %s", uint64_display),
    string.format("int64:   %s", int64_display),
    string.format("float32: %s", float32_value),
    string.format("f32bits: %s", format_float_parts(float32_bits, 8, 23, 127)),
    string.format("float64: %s", float64_value),
    string.format("f64bits: %s", format_float_parts(float64_bits, 11, 52, 1023)),
  }
end

return M
