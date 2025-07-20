<!--
    SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
    SPDX-License-Identifier: CC0-1.0
-->

# KomoDo

Kirigami GUI frontend for [todo.txt](http://todotxt.org/) files.

![Screenshot of KomoDo](https://cdn.kde.org/screenshots/komodo/screenshot.png)

KomoDo can be used to:
- Add, delete and edit tasks
- Create new todo.txt files
- Filter and search tasks

KomoDo follows the rules of [todo.txt](https://github.com/todotxt/todo.txt/blob/master/README.md) specification.

For example, a task is declared like this:
```
(A) 2024-10-23 Do this task for +KomoDoApp @Akademy due:2025-12-10 link:https://kde.org
```

KomoDo then will parse these task and showcase it in easy-to-read
"card" form.

See the built-in help for more information.

## How to get it

For now you will have to build it on your own.

Flathub link hopefully coming soon.

### Building

You can use [kde-builder](https://kde-builder.kde.org/en/) to build KomoDo.

For now, you will need to add this in your `kde-builder.yaml` configuration file:

```yaml
project komodo:
  repository: git@invent.kde.org:akselmo/komodo.git
```

Then you can run `kde-builder komodo`.
