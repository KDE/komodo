#include "TodoModel.h"
#include <QDebug>
#include <QFile>
#include <QRegularExpression>
#include <QString>

TodoModel::TodoModel()
{
    const QString pattern = QStringLiteral(
        "(?:^[ "
        "\\t]*(?P<Completion>x))|(?P<Priority>\\([A-Z]\\))|(?:(?P<CompletionDate>"
        "\\d{4}-\\d\\d-\\d\\d)[ "
        "\\t]*(?P<CreationDate>\\d{4}-\\d\\d-\\d\\d)?)|(?P<Projects>\\+\\w+)|(?P<"
        "Contexts>(?<=\\s)@[^\\s]+)|(?P<KeyValuePairs>[a-zA-Z]+:[\\w:/.%-]*)");

    parserPattern = QRegularExpression(pattern);
    qWarning() << parserPattern.isValid() << parserPattern.errorString();
    if (!parserPattern.isValid()) {
        return;
    }

    QString filePath = QStringLiteral("todo.txt");
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "could not open file" << filePath;
        return;
    }

    int currentLine = 0;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        auto task = parseLine(line);

        m_parsedTasks[currentLine] = task;
        currentLine++;
    }
}

TodoModel::ParsedTodo TodoModel::parseLine(const QString &description)
{
    // read description from the file and turn it into task
    QRegularExpressionMatchIterator iter = parserPattern.globalMatch(description);
    ParsedTodo task;
    task.description = description;
    QStringList keyVals;
    bool completionStatus = false;
    while (iter.hasNext()) {
        const auto match = iter.next();
        if (!match.captured("Completion").isEmpty()) {
            completionStatus = true;
        }

        if (!match.captured("Priority").isEmpty()) {
            task.priority = match.captured("Priority");
        }

        if (!match.captured("CompletionDate").isEmpty()) {
            task.completionDate = match.captured("CompletionDate");
        }

        if (!match.captured("CreationDate").isEmpty()) {
            task.creationDate = match.captured("CreationDate");
        }

        if (!match.captured("Projects").isEmpty()) {
            task.projects.append(match.captured("Projects"));
        }

        if (!match.captured("Contexts").isEmpty()) {
            task.contexts.append(match.captured("Contexts"));
        }

        if (!match.captured("KeyValuePairs").isEmpty()) {
            task.keyValuePairs.append(match.captured("KeyValuePairs"));
        }
    }

    task.completed = completionStatus;
    return task;
}

int TodoModel::rowCount(const QModelIndex &) const
{
    return m_parsedTasks.count();
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    return {
        {LineRole, "lineNumber"},
        {CompletionRole, "completion"},
        {PriorityRole, "priority"},
        {CompletionDateRole, "completionDate"},
        {CreationDateRole, "creationDate"},
        {DescriptionRole, "description"},
        {ContextsRole, "contexts"},
        {ProjectsRole, "projects"},
        {KeyValuePairsRole, "keyValuePairs"},
    };
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    const auto it = m_parsedTasks.begin() + index.row();

    switch (role) {
    case LineRole:
        return it.key();
    case CompletionRole:
        return it.value().completed;
    case PriorityRole:
        return it.value().priority;
    case CompletionDateRole:
        return it.value().completionDate;
    case CreationDateRole:
        return it.value().creationDate;
    case DescriptionRole:
        return it.value().description;
    case ContextsRole:
        return it.value().contexts;
    case ProjectsRole:
        return it.value().projects;
    case KeyValuePairsRole:
        return it.value().keyValuePairs;
    default:
        return {};
    }
}

bool TodoModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!value.canConvert<QString>() && role != Qt::EditRole) {
        return false;
    }

    auto it = m_parsedTasks.begin() + index.row();
    QString newDescription = value.toString();

    m_parsedTasks[it.key()] = parseLine(newDescription);
    Q_EMIT dataChanged(index, index);

    return true;
}

void TodoModel::addTodo(const QString &description)
{
    beginInsertRows(QModelIndex(), m_parsedTasks.size(), m_parsedTasks.size());
    m_parsedTasks.insert(m_parsedTasks.count() + 1, parseLine(description));
    endInsertRows();
    Q_EMIT dataChanged(index(0), index(m_parsedTasks.size()));
}

void TodoModel::deleteTodo(const int line, const int &rowIndex)
{
    beginRemoveRows(QModelIndex(), rowIndex, rowIndex);
    m_parsedTasks.remove(line);
    endRemoveRows();
    Q_EMIT dataChanged(index(0), index(m_parsedTasks.size()));
}

QMap<int, TodoModel::ParsedTodo> TodoModel::parsedTasks()
{
    return m_parsedTasks;
}
