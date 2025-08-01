// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QString>
#include <QStringList>
#include <QUuid>

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
    QString dueDate() const;
    QUuid uuid() const;

    void setCompleted(bool completed);
    void setPriority(const QString &priority);
    void setCompletionDate(const QString &completionDate);
    void setCreationDate(const QString &creationDate);
    void setDescription(const QString &description);
    void addContext(const QString &context);
    void addProject(const QString &project);
    void addKeyValuePair(const QString &keyValuePair);
    void setPrettyDescription(const QString &prettyDescription);
    void setDueDate(const QString &dueDate);

private:
    QUuid m_uuid;
    bool m_completed;
    QString m_priority;
    QString m_completionDate;
    QString m_creationDate;
    QString m_description;
    QStringList m_contexts;
    QStringList m_projects;
    QStringList m_keyValuePairs;
    QString m_prettyDescription;
    QString m_dueDate;
};
