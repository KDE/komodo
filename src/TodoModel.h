#pragma once

#include "Todo.h"
#include <QAbstractListModel>
#include <QDebug>
#include <QMap>
#include <QRegularExpression>
#include <QString>

class TodoModel : public QAbstractListModel
{
    Q_OBJECT
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
        PrettyDescriptionRole
    };

    TodoModel();

    Todo parseTodoFromDescription(const QString &description);

    QRegularExpression parserPattern;

    QList<Todo> todos();

    int rowCount(const QModelIndex &) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE void addTodo(const QString &description);
    Q_INVOKABLE void deleteTodo(const QModelIndex &index);

private:
    void updateCompletionStatus(Todo &todo, const bool completed);
    QString prettyPrintDescription(const Todo &todo);

    QList<Todo> m_todos;
};
