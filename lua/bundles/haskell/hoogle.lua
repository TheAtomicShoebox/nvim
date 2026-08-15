---Local Hoogle via Snacks. haskell-tools' `auto` mode only uses a local DB
---when telescope.nvim is installed; this config uses Snacks instead.

local M = {}

local function format_html(html)
  return html and html:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&") or ""
end

---@param item string
---@return string
local function type_sig(item)
  local name = item:match("<span class=name><s0>(.*)</s0></span>")
  local sig = item:match(":: (.*)")
  if name and sig then
    return (name .. " :: " .. format_html(sig)):gsub("%s+", " ")
  end
  return item
end

---@param term string
function M.search(term)
  if term == nil or term == "" then
    vim.notify("Hoogle: empty search", vim.log.levels.INFO)
    return
  end
  if vim.fn.executable("hoogle") ~= 1 then
    vim.notify(
      "Hoogle executable not found. Install it and run `hoogle generate` for a local database.",
      vim.log.levels.WARN,
      { title = "haskell-tools" }
    )
    return
  end

  vim.system({ "hoogle", "--json", "--count=50", term }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 or not obj.stdout or obj.stdout == "" then
        vim.notify("Hoogle search failed (exit " .. tostring(obj.code) .. ")", vim.log.levels.ERROR)
        return
      end
      local ok, results = pcall(vim.json.decode, obj.stdout)
      if not ok or type(results) ~= "table" or #results == 0 then
        vim.notify("Hoogle: no results for " .. term, vim.log.levels.INFO)
        return
      end

      local items = {}
      for _, row in ipairs(results) do
        local module_name = row.module and row.module.name or ""
        local sig = row.item and type_sig(row.item) or ""
        items[#items + 1] = {
          text = (module_name ~= "" and (module_name .. "  ") or "") .. sig,
          type_sig = sig,
          url = row.url,
          preview = { text = format_html(row.docs or sig), ft = "markdown" },
        }
      end

      Snacks.picker.pick({
        title = "Hoogle: " .. term,
        items = items,
        format = "text",
        preview = "preview",
        confirm = function(picker, item)
          if item and item.type_sig then
            local reg = vim.o.clipboard == "unnamedplus" and "+" or '"'
            vim.fn.setreg(reg, item.type_sig)
          end
          picker:close()
        end,
      })
    end)
  end)
end

---Signature under the cursor (HLS hover when attached, else <cword>).
function M.signature()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "haskell-tools.nvim" })
  if #clients == 0 then
    M.search(vim.fn.expand("<cword>"))
    return
  end
  local client = clients[1]
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  vim.lsp.buf_request(0, vim.lsp.protocol.Methods.textDocument_hover, params, function(_, result)
    local cword = vim.fn.expand("<cword>")
    if not (result and result.contents) then
      M.search(cword)
      return
    end
    local value = type(result.contents) == "table" and result.contents.value or result.contents
    local ok, HtParser = pcall(require, "haskell-tools.parser")
    local term = ok and HtParser.try_get_signatures_from_markdown(cword, value) or cword
    M.search(term ~= "" and term or cword)
  end)
end

return M
