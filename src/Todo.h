#pragma once

#include <QAbstractListModel>
#include <QDebug>
#include <QMap>
#include <QRegularExpression>
#include <QString>

class Todo
{
public:
    // https://github.com/todotxt/todo.txt/blob/master/description.svg

    // Todo.txt format:
    // x marks completion
    // (A) is priority
    // first date is completion date
    // second date is creation date
    // x (A) 2025-01-01 2024-01-01 description +project @context key:value
    Todo(const QString &description);

    bool completed() const;
    QString priority() const;
    QString completionDate() const;
    QString creationDate() const;
    QString description() const;
    QStringList contexts() const;
    QStringList projects() const;
    QStringList keyValuePairs() const;
    QString prettyDescription() const;

    void setCompleted(bool completed);
    void setPriority(const QString &priority);
    void setCompletionDate(const QString &completionDate);
    void setCreationDate(const QString &creationDate);
    void setDescription(const QString &description);
    void addContext(const QString &context);
    void addProject(const QString &project);
    void addKeyValuePair(const QString &keyValuePair);
    void setPrettyDescription(const QString &prettyDescription);

private:
    bool m_completed;
    QString m_priority;
    QString m_completionDate;
    QString m_creationDate;
    QString m_description;
    QStringList m_contexts;
    QStringList m_projects;
    QStringList m_keyValuePairs;
    QString m_prettyDescription;
};
