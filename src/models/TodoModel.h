// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "Todo.h"
#include "komodo_config.h"
#include <QAbstractListModel>
#include <QDebug>
#include <QFileSystemWatcher>
#include <QMap>
#include <QQmlEngine>
#include <QRegularExpression>
#include <QString>
#include <QUrl>

class TodoModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QUrl filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
public:
    // https://github.com/todotxt/todo.txt/blob/master/description.svg
    enum Roles {
        DescriptionRole = Qt::UserRole,
        CompletionRole,
        PriorityRole,
        CompletionDateRole,
        CreationDateRole,
        ContextsRole,
        ProjectsRole,
        KeyValuePairsRole,
        PrettyDescriptionRole,
        DueDateRole
    };
    Q_ENUMS(Roles)

    explicit TodoModel(QObject *parent = nullptr);

    Todo parseTodoFromDescription(const QString &description);

    QRegularExpression parserPattern;

    QList<Todo> todos();

    int rowCount(const QModelIndex &) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE void addTodo(const QString &description);
    Q_INVOKABLE void deleteTodo(const QModelIndex &index);

    QUrl filePath();
    void setFilePath(const QUrl &newFilePath);
    Q_SIGNAL void filePathChanged();
    Q_SIGNAL void fileChanged();

    Q_INVOKABLE bool loadFile();
    Q_INVOKABLE bool saveFile();

private:
    void updateCompletionStatus(Todo &todo, const bool completed);
    QString prettyPrintDescription(const Todo &todo);

    QUrl m_filePath;
    QList<Todo> m_todos;
    KomodoConfig *m_config;
    QFileSystemWatcher *m_fileWatcher;
};
