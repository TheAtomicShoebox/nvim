if vim.g.vscode then

else
    --[[
        if the flag isn't operating properly, then this will break the installation -- intentionally
        this also allows me to ensure the eventual rebase of this onto the main branch will continue to operate
        this can also potentially allow me to create 2 separate streams: normal config and vs config, within whatever package manager I use
        Thus, checking the flag this early is a pleasant setup
    ]]
    require ('config.lazy') 
end