<!--
    SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
    SPDX-License-Identifier: CC0-1.0
-->

# KomoDo

<a href='https://flathub.org/apps/org.kde.komodo'><img width='240' alt='Get it on Flathub' src='https://flathub.org/api/badge?locale=en&light'/></a>

Work on [todo.txt](http://todotxt.org/) files!

KomoDo is a todo manager that uses [todo.txt specification](https://github.com/todotxt/todo.txt/blob/master/README.md). 
It parses any compliant todo.txt files and turns them into easy to use list of tasks.

KomoDo has built-in help for the todo.txt specification, so it's suitable for newcomers too!

![Screenshot of KomoDo](https://invent.kde.org/websites/product-screenshots/-/raw/master/komodo/screenshot.png?ref_type=heads)

KomoDo can be used to:
- Add, delete and edit tasks
- Create new todo.txt files
- Filter and search tasks

For example, a task is declared like this:
```
(A) 2024-10-23 Do this task for +KomoDoApp @Akademy due:2025-12-10 link:https://kde.org
```

KomoDo then will parse these task and showcase it in easy-to-read
"card" form.

See the built-in help for more information.

## Matrix chat

We have a [Matrix](https://community.kde.org/Matrix) chat where you can join and 
chat about contributions and using the app: [#komodo:kde.org](https://matrix.to/#/#komodo:kde.org)

## How to get it

You can install KomoDo from [Flathub](https://flathub.org/apps/org.kde.komodo).

### Building

You can use [kde-builder](https://kde-builder.kde.org/en/) to build KomoDo.

Install it, and then in terminal just run `kde-builder komodo`.
