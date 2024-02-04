# Macros

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/alexjercan/macros.nvim/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A plugin to compute the macros for different types of food.

## Quickstart

The food items have to be in the following format `<food item name>
<amount><unit>`. For example "chicken breast 100g". The supported measuring
units are grams (g, gr, gram, grams) and pieces (p, pc, pcs, piece, pieces).

The order of the macros are protein, carbs, fats

Place the cursor on the line that contains the food item that you want to track
and then use the `:Macros` command.

For example this is one transformation

```
chicken breast 100g
:Macros
chicken breast 100g,31,0,3.6
```

## Config

You can specify the food items to add in two ways. First you can create a csv
file and put all the data inside and then in setup pass the path to the file in
the `file` optional argument. Or you can pass them line by line in the `items`
table.

Complete example of config using lazy

```lua
return {
    dir = "/home/alex/personal/macros.nvim/",
    config = function ()
        require("macros").setup({
            file = "/path/to/the/csv/file.csv",
            items = {
                "chicken breast 100g,31,0,3.6",
                "apple 1p,0.3,25,0.2",
            }
        })
    end
}
```

and the csv file should be like

```csv
chicken breast 100g,31,0,3.6
apple 1p,0.3,25,0.2
```
