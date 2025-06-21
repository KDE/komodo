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

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        auto task = parseLine(line);

        m_parsedTodos.append(task);
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
    return m_parsedTodos.size();
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    return {
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
    if (!index.isValid() || index.row() < 0 || index.row() >= m_parsedTodos.count()) {
        return {};
    }

    auto todo = m_parsedTodos.at(index.row());

    switch (role) {
    case CompletionRole:
        return todo.completed;
    case PriorityRole:
        return todo.priority;
    case CompletionDateRole:
        return todo.completionDate;
    case CreationDateRole:
        return todo.creationDate;
    case DescriptionRole:
        return todo.description;
    case ContextsRole:
        return todo.contexts;
    case ProjectsRole:
        return todo.projects;
    case KeyValuePairsRole:
        return todo.keyValuePairs;
    default:
        return {};
    }
}

bool TodoModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= m_parsedTodos.count()) {
        return false;
    }

    auto &todo = m_parsedTodos[index.row()];

    switch (role) {
    case CompletionRole:
        todo.completed = value.toBool();
        break;
    case PriorityRole:
        todo.priority = value.toString();
        break;
    case CompletionDateRole:
        todo.completionDate = value.toString();
        break;
    case CreationDateRole:
        todo.creationDate = value.toString();
        break;
    case DescriptionRole:
        todo.description = value.toString();
        break;
    case ContextsRole:
        todo.contexts = value.toStringList();
        break;
    case ProjectsRole:
        todo.projects = value.toStringList();
        break;
    case KeyValuePairsRole:
        todo.keyValuePairs = value.toStringList();
        break;
    default:
        return false;
    }

    Q_EMIT dataChanged(index, index, {role});

    return true;
}

void TodoModel::addTodo(const QString &description)
{
    beginInsertRows(QModelIndex(), m_parsedTodos.count(), m_parsedTodos.count());
    m_parsedTodos.append(parseLine(description));
    endInsertRows();

    // TODO: save todo file
}

void TodoModel::deleteTodo(const QModelIndex &index)
{
    const int row = index.row();
    if (row < 0 || row > m_parsedTodos.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_parsedTodos.removeAt(row);
    endRemoveRows();

    // TODO: save todo file
}

QList<TodoModel::ParsedTodo> TodoModel::parsedTodos()
{
    return m_parsedTodos;
}
