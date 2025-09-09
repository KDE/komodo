// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "Todo.h"
#include "komodo_config.h"
#include <KDirWatch>
#include <QAbstractItemModel>
#include <QRegularExpression>

class TodoModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QUrl filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(int filterIndex READ filterIndex WRITE setFilterIndex NOTIFY filterIndexChanged)
    Q_PROPERTY(bool autoInsertCreationDate READ autoInsertCreationDate WRITE setAutoInsertCreationDate NOTIFY autoInsertCreationDateChanged)
    Q_PROPERTY(QString startupSearchText READ startupSearchText)

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
        DueDateRole,
        UUIDRole
    };
    Q_ENUM(Roles)

    explicit TodoModel(QObject *parent = nullptr);

    Todo parseTodoFromDescription(const QString &description) const;
    QList<Todo> todos() const;

    int rowCount(const QModelIndex &) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE QUuid addTodo(const QString &description);
    Q_INVOKABLE void deleteTodo(const QModelIndex &index);

    QUrl filePath() const;
    void setFilePath(const QUrl &newFilePath);
    Q_SIGNAL void filePathChanged();

    Q_SIGNAL void fileChanged();

    int filterIndex() const;
    void setFilterIndex(const int &newFilterIndex);
    Q_SIGNAL void filterIndexChanged();

    bool autoInsertCreationDate() const;
    void setAutoInsertCreationDate(bool enabled);
    Q_SIGNAL void autoInsertCreationDateChanged();

    QString startupSearchText();

    Q_INVOKABLE bool loadFile();
    Q_INVOKABLE bool saveFile();
    Q_INVOKABLE bool fileExists() const;

    Q_SLOT void fileModified();

    Q_INVOKABLE QModelIndex indexFromQUuid(const QUuid &uuid) const;

private:
    void updateCompletionStatus(Todo &todo, const bool completed);
    QString prettyPrintDescription(const Todo &todo) const;

    QUrl m_filePath;
    QList<Todo> m_todos;
    KomodoConfig *m_config;
    KDirWatch *m_fileWatcher;
    int m_filterIndex = 0;
    bool m_autoInsertCreationDate = false;
    bool fileModifiedFromApp = false;

    // Regexp for the completion status: x
    QRegularExpression m_completionRegexp;
    // Regexp for the priority: (A-Z)
    QRegularExpression m_priorityRegexp;
    // Regexp for priority keyval pair: pri:A
    QRegularExpression m_keyValuePriorityRegexp;
    // Regexp for date yyyy-mm-dd
    QRegularExpression m_dateRegexp;
    // Regexp for keyvalue-pair
    QRegularExpression m_keyValuePairRegexp;
};
