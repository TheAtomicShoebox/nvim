if vim.g.vscode then
    local vscode = require 'vscode'
    vim.notify = vscode.notify
    vim.notify('VS Code Enabled')
end
    require 'config.lazy'

Snacks.notifier.notify('VS Code Disabled')