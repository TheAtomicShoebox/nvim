---Bundle loader. Each lua/bundles/<name>/init.lua returns a Bundle spec
---(cheap: no vim.pack.add, no setup). bootstrap() discovers them, runs
---eager ones, and merges the rest onto shared autocmds. ensure() is a
---three-color DFS keyed by module table identity: white → gray → black
---at most once per process; setup() is post-order so deps run first.

---@alias Bundle.Load
---| "eager"
---| string
---| Bundle.LoadSpec

---@class Bundle.LoadSpec
---@field event string|string[]
---@field pattern? string|string[]
---@field once? boolean

---@class Bundle
---@field name? string set from the directory name if omitted
---@field load Bundle.Load
---@field deps fun(): Bundle[]
---@field setup fun()

---@class Bundle.Status
---@field name string
---@field loaded boolean
---@field load Bundle.Load

local M = {}

local WHITE, GRAY, BLACK = 0, 1, 2

---@type Bundle[]
local discovered = {}

---@type table<Bundle, integer>
local color = {}

---@param bundle Bundle
---@param where string
local function assert_bundle(bundle, where)
  if type(bundle) ~= "table" then
    error(("%s: expected a Bundle table, got %s"):format(where, type(bundle)), 2)
  end
  if type(bundle.deps) ~= "function" then
    error(("%s: Bundle.deps must be a function"):format(where), 2)
  end
  if type(bundle.setup) ~= "function" then
    error(("%s: Bundle.setup must be a function"):format(where), 2)
  end
  if bundle.load == nil then
    error(("%s: Bundle.load is required"):format(where), 2)
  end
end

---@param bundle Bundle
local function ensure(bundle)
  local c = color[bundle] or WHITE
  if c == BLACK then
    return
  end
  if c == GRAY then
    error(("cycle in bundle deps involving %s"):format(bundle.name or "?"))
  end

  color[bundle] = GRAY
  for i, dep in ipairs(bundle.deps()) do
    assert_bundle(dep, ("%s.deps()[%d]"):format(bundle.name or "?", i))
    ensure(dep)
  end
  bundle.setup()
  color[bundle] = BLACK
end

---@param load Bundle.Load
---@param name string
---@return { eager: true }|{ event: string[], pattern: string|string[]|nil, once: boolean }
local function normalize_load(load, name)
  if load == "eager" then
    return { eager = true }
  end
  if type(load) == "string" then
    return { event = { load }, pattern = nil, once = true }
  end
  if type(load) ~= "table" or load.event == nil then
    error(("bundle %s: load must be \"eager\", an event string, or { event = ... }"):format(name))
  end
  local event = load.event
  if type(event) == "string" then
    event = { event }
  end
  return {
    event = event,
    pattern = load.pattern,
    once = load.once ~= false,
  }
end

---@param pattern string|string[]|nil
---@return string
local function pattern_key(pattern)
  if pattern == nil then
    return "*"
  end
  if type(pattern) == "string" then
    return pattern
  end
  return table.concat(pattern, ",")
end

local function discover()
  discovered = {}
  color = {}
  local dir = vim.fn.stdpath("config") .. "/lua/bundles"
  local names = {} ---@type string[]
  for name, ty in vim.fs.dir(dir) do
    if ty == "directory" then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  for _, name in ipairs(names) do
    local ok, mod = pcall(require, "bundles." .. name)
    if not ok then
      error(("bundle %s failed to load: %s"):format(name, mod))
    end
    assert_bundle(mod, "bundles." .. name)
    mod.name = mod.name or name
    discovered[#discovered + 1] = mod
  end
end

---Discover specs, run eager bundles, register merged autocmds for the rest.
function M.bootstrap()
  discover()

  ---@type table<string, { event: string, pattern: string|string[]|nil, once: boolean, bundles: Bundle[] }>
  local groups = {}
  local eager = {} ---@type Bundle[]

  for _, bundle in ipairs(discovered) do
    local spec = normalize_load(bundle.load, bundle.name --[[@as string]])
    if spec.eager then
      eager[#eager + 1] = bundle
    else
      for _, event in ipairs(spec.event) do
        local key = event .. "\0" .. pattern_key(spec.pattern) .. "\0" .. tostring(spec.once)
        local group = groups[key]
        if not group then
          group = {
            event = event,
            pattern = spec.pattern,
            once = spec.once,
            bundles = {},
          }
          groups[key] = group
        end
        group.bundles[#group.bundles + 1] = bundle
      end
    end
  end

  for _, bundle in ipairs(eager) do
    ensure(bundle)
  end

  local augroup = vim.api.nvim_create_augroup("UserBundles", { clear = true })
  for _, group in pairs(groups) do
    vim.api.nvim_create_autocmd(group.event, {
      group = augroup,
      pattern = group.pattern,
      once = group.once,
      callback = function(ev)
        -- An empty scratch buffer can fire FileType with match "". If this
        -- autocmd is once=true, that would consume it and never load the
        -- bundle for a real file. Skip empties; ensure() is idempotent so
        -- once=false FileType groups stay cheap after the first real file.
        if group.event == "FileType" and (ev.match == nil or ev.match == "") then
          return
        end
        for _, bundle in ipairs(group.bundles) do
          ensure(bundle)
        end
      end,
    })
  end
end

---Force-load a bundle (and its deps) outside of its autocmd. Idempotent.
---@param bundle Bundle
function M.ensure(bundle)
  assert_bundle(bundle, "bundles.ensure")
  ensure(bundle)
end

---@return Bundle.Status[]
function M.status()
  local out = {} ---@type Bundle.Status[]
  for _, bundle in ipairs(discovered) do
    out[#out + 1] = {
      name = bundle.name or "?",
      loaded = (color[bundle] or WHITE) == BLACK,
      load = bundle.load,
    }
  end
  return out
end

---Names of bundles whose setup() has run (for :checkhealth Config).
---@return string[]
function M.loaded()
  local names = {} ---@type string[]
  for _, s in ipairs(M.status()) do
    if s.loaded then
      names[#names + 1] = s.name
    end
  end
  return names
end

return M
