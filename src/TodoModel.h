#pragma once

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
    struct ParsedTodo {
        bool completed;
        QString priority;
        QString completionDate;
        QString creationDate;
        QString description;
        QStringList contexts;
        QStringList projects;
        QStringList keyValuePairs;
    };

    enum Roles {
        DescriptionRole = Qt::UserRole,
        CompletionRole,
        PriorityRole,
        CompletionDateRole,
        CreationDateRole,
        ContextsRole,
        ProjectsRole,
        KeyValuePairsRole
    };

    TodoModel();

    ParsedTodo parseLine(const QString &description);

    QRegularExpression parserPattern;

    QList<ParsedTodo> parsedTodos();

    int rowCount(const QModelIndex &) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE void addTodo(const QString &description);
    Q_INVOKABLE void deleteTodo(const QModelIndex &index);

private:
    QList<ParsedTodo> m_parsedTodos;
};
