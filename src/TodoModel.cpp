#include "TodoModel.h"
#include "Todo.h"
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
        if (!line.isEmpty()) {
            auto task = parseLine(line);
            m_todos.append(task);
        }
    }
}

Todo TodoModel::parseLine(const QString &description)
{
    // read description from the file and turn it into task
    QRegularExpressionMatchIterator iter = parserPattern.globalMatch(description);
    Todo todo(description);
    todo.setDescription(description);
    QStringList keyVals;
    bool completionStatus = false;
    while (iter.hasNext()) {
        const auto match = iter.next();
        if (!match.captured("Completion").isEmpty()) {
            completionStatus = true;
        }

        if (!match.captured("Priority").isEmpty()) {
            todo.setPriority(match.captured("Priority"));
        }

        if (!match.captured("CompletionDate").isEmpty()) {
            todo.setCompletionDate(match.captured("CompletionDate"));
        }

        if (!match.captured("CreationDate").isEmpty()) {
            todo.setCreationDate(match.captured("CreationDate"));
        }

        if (!match.captured("Projects").isEmpty()) {
            todo.addProject(match.captured("Projects"));
        }

        if (!match.captured("Contexts").isEmpty()) {
            todo.addContext(match.captured("Contexts"));
        }

        if (!match.captured("KeyValuePairs").isEmpty()) {
            todo.addKeyValuePair(match.captured("KeyValuePairs"));
        }
    }

    todo.setCompleted(completionStatus);
    return todo;
}

int TodoModel::rowCount(const QModelIndex &) const
{
    return m_todos.size();
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
    if (!index.isValid() || index.row() < 0 || index.row() >= m_todos.count()) {
        return {};
    }

    auto todo = m_todos.at(index.row());

    switch (role) {
    case CompletionRole:
        return todo.completed();
    case PriorityRole:
        return todo.priority();
    case CompletionDateRole:
        return todo.completionDate();
    case CreationDateRole:
        return todo.creationDate();
    case DescriptionRole:
        return todo.description();
    case ContextsRole:
        return todo.contexts();
    case ProjectsRole:
        return todo.projects();
    case KeyValuePairsRole:
        return todo.keyValuePairs();
    default:
        return {};
    }
}

void TodoModel::updateCompletionStatus(Todo &todo, const bool completed)
{
    auto newDescription = todo.description();
    todo.setCompleted(completed);
    if (todo.completed()) {
        todo.setDescription(newDescription.prepend(QStringLiteral("x")));
        // TODO: add pri:Priority keyval pair, remove the (P) item
    } else {
        // TODO: if there is pri:keyval pair, add that as a (P) item and remove the keyval
        newDescription.replace(QRegularExpression(QStringLiteral("^[ \\t]*x")), QStringLiteral(""));
        todo.setDescription(newDescription);
    }
}

bool TodoModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= m_todos.count()) {
        return false;
    }

    auto &todo = m_todos[index.row()];
    auto descr = todo.description();

    switch (role) {
    case CompletionRole:
        updateCompletionStatus(todo, value.toBool());
        break;
    case PriorityRole:
        todo.setPriority(value.toString());
        break;
    case CompletionDateRole:
        todo.setCompletionDate(value.toString());
        break;
    case CreationDateRole:
        todo.setCreationDate(value.toString());
        break;
    case DescriptionRole:
        todo.setDescription(value.toString());
        break;
    case ContextsRole:
        todo.addContext(value.toString());
        break;
    case ProjectsRole:
        todo.addProject(value.toString());
        break;
    case KeyValuePairsRole:
        todo.addKeyValuePair(value.toString());
        break;
    default:
        return false;
    }

    Q_EMIT dataChanged(index, index, {role});

    return true;
}

void TodoModel::addTodo(const QString &description)
{
    beginInsertRows(QModelIndex(), m_todos.count(), m_todos.count());
    m_todos.append(parseLine(description));
    endInsertRows();

    // TODO: save todo file
}

void TodoModel::deleteTodo(const QModelIndex &index)
{
    const int row = index.row();
    if (row < 0 || row > m_todos.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_todos.removeAt(row);
    endRemoveRows();

    // TODO: save todo file
}

QList<Todo> TodoModel::todos()
{
    return m_todos;
}
