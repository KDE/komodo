#include "Todo.h"
#include <QDebug>
#include <QFile>
#include <QRegularExpression>
#include <QString>

Todo::Todo(const QString &description)
{
    m_description = description;
}

bool Todo::completed() const
{
    return m_completed;
}
QString Todo::priority() const
{
    return m_priority;
}
QString Todo::completionDate() const
{
    return m_completionDate;
}
QString Todo::creationDate() const
{
    return m_creationDate;
}
QString Todo::description() const
{
    return m_description;
}
QStringList Todo::contexts() const
{
    return m_contexts;
}
QStringList Todo::projects() const
{
    return m_projects;
}
QStringList Todo::keyValuePairs() const
{
    return m_keyValuePairs;
}

QString Todo::prettyDescription() const
{
    return m_prettyDescription;
}

void Todo::setCompleted(bool completed)
{
    m_completed = completed;
}
void Todo::setPriority(const QString &priority)
{
    m_priority = priority;
}
void Todo::setCompletionDate(const QString &completionDate)
{
    m_completionDate = completionDate;
}
void Todo::setCreationDate(const QString &creationDate)
{
    m_creationDate = creationDate;
}
void Todo::setDescription(const QString &description)
{
    m_description = description;
}
void Todo::addContext(const QString &context)
{
    m_contexts.append(context);
}
void Todo::addProject(const QString &project)
{
    m_projects.append(project);
}
void Todo::addKeyValuePair(const QString &keyValuePair)
{
    m_keyValuePairs.append(keyValuePair);
}

void Todo::setPrettyDescription(const QString &prettyDescription)
{
    m_prettyDescription = prettyDescription;
}