// SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "TodoModel.h"
#include <KColorScheme>
#include <KColorUtils>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QString>
#include <QUrl>

TodoModel::TodoModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // Regexp for the whole todo line, with grouped items
    parserPattern =
        QRegularExpression(QStringLiteral("(?:^[ "
                                          "\\t]*(?P<Completion>x))|(?P<Priority>\\([A-Z]\\))|(?:(?P<FirstDate>"
                                          "\\d{4}-\\d\\d-\\d\\d)[ "
                                          "\\t]*(?P<SecondDate>\\d{4}-\\d\\d-\\d\\d)?)|(?P<Projects>\\+\\w+)|(?P<"
                                          "Contexts>(?<=\\s)@[^\\s]+)|(?P<KeyValuePairs>[a-zA-Z]+:[\\w:/.%-]*)"));
    if (!parserPattern.isValid()) {
        qWarning() << "Regular expression pattern for parsing is not valid!";
        return;
    }

    m_completionRegexp = QRegularExpression(QStringLiteral("^[ \\t]*x"));
    m_priorityRegexp = QRegularExpression(QStringLiteral("^[ x\\t]*\\(([A-Z])\\)"));
    m_keyValuePriority = QRegularExpression(QStringLiteral("pri:([A-Z])"));

    m_fileWatcher = new KDirWatch(this);
    connect(this, &TodoModel::filePathChanged, this, &TodoModel::loadFile);
    connect(this, &TodoModel::dataChanged, this, &TodoModel::saveFile);
    m_config = KomodoConfig::self();
    m_config->load();
    m_filterIndex = m_config->filterIndex();
    if (!m_config->todoFilePath().isEmpty()) {
        m_filePath = QUrl::fromLocalFile(m_config->todoFilePath());
        loadFile();
    }
    connect(m_fileWatcher, &KDirWatch::dirty, this, &TodoModel::fileModified);
    connect(m_fileWatcher, &KDirWatch::deleted, this, &TodoModel::fileModified);
    connect(m_fileWatcher, &KDirWatch::created, this, &TodoModel::fileModified);
}

Todo TodoModel::parseTodoFromDescription(const QString &description) const
{
    // read description from the file and turn it into task
    QRegularExpressionMatchIterator iter = parserPattern.globalMatch(description);
    Todo todo(description);
    bool completionStatus = false;
    while (iter.hasNext()) {
        const auto match = iter.next();
        if (!match.captured("Completion").isEmpty()) {
            completionStatus = true;
        }

        if (!match.captured("Priority").isEmpty()) {
            todo.setPriority(match.captured("Priority"));
        }

        if (!match.captured("FirstDate").isEmpty()) {
            // Set the first date as creation date if the item is not completed
            if (completionStatus) {
                todo.setCompletionDate(match.captured("FirstDate"));
            } else {
                todo.setCreationDate(match.captured("FirstDate"));
            }
        }

        if (!match.captured("SecondDate").isEmpty()) {
            if (completionStatus) {
                todo.setCreationDate(match.captured("SecondDate"));
            }
        }

        if (!match.captured("Projects").isEmpty()) {
            todo.addProject(match.captured("Projects"));
        }

        if (!match.captured("Contexts").isEmpty()) {
            todo.addContext(match.captured("Contexts"));
        }

        if (!match.captured("KeyValuePairs").isEmpty()) {
            auto pair = match.captured("KeyValuePairs");
            // Ignore web URLs
            if (!pair.startsWith(QStringLiteral("http"))) {
                todo.addKeyValuePair(match.captured("KeyValuePairs"));
            }
        }
    }

    todo.setCompleted(completionStatus);
    todo.setPrettyDescription(prettyPrintDescription(todo));
    const auto pairs = todo.keyValuePairs();
    for (const QString &keyval : pairs) {
        if (keyval.startsWith(QStringLiteral("due:"))) {
            todo.setDueDate(keyval.split(QStringLiteral(":")).last());
        }
    }
    return todo;
}

QString TodoModel::prettyPrintDescription(const Todo &todo) const
{
    auto prettyDescr = todo.description();
    prettyDescr.replace(m_completionRegexp, QString());
    prettyDescr.replace(todo.creationDate(), QString());
    prettyDescr.replace(todo.completionDate(), QString());
    const auto keyValuePairs = todo.keyValuePairs();
    const auto projects = todo.projects();
    const auto contexts = todo.contexts();
    for (const auto &pair : keyValuePairs) {
        prettyDescr.replace(pair, QString());
    }
    // There's probably better way to do this but hey as long as it works.
    const auto textColor = KColorScheme().foreground().color();
    const auto projectColor = KColorUtils::mix(KColorScheme().foreground(KColorScheme::ActiveText).color(), textColor);
    const auto contextColor = KColorUtils::mix(KColorScheme().foreground(KColorScheme::PositiveText).color(), textColor);
    for (const auto &project : projects) {
        const auto re = QRegularExpression(QStringLiteral("\\B\\%1\\b").arg(project));
        prettyDescr.replace(re, QStringLiteral("<b><span style='color:%2'>%1</span></b>").arg(project, projectColor.name()));
    }
    for (const auto &context : contexts) {
        const auto re = QRegularExpression(QStringLiteral("\\B\\%1\\b").arg(context));
        prettyDescr.replace(re, QStringLiteral("<i><span style='color:%2'>%1</span></i>").arg(context, contextColor.name()));
    }

    prettyDescr.replace(m_priorityRegexp, QString());
    return prettyDescr.simplified();
}

int TodoModel::rowCount(const QModelIndex &) const
{
    return m_todos.size();
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    return {{CompletionRole, "completion"},
            {PriorityRole, "priority"},
            {CompletionDateRole, "completionDate"},
            {CreationDateRole, "creationDate"},
            {DescriptionRole, "description"},
            {ContextsRole, "contexts"},
            {ProjectsRole, "projects"},
            {KeyValuePairsRole, "keyValuePairs"},
            {PrettyDescriptionRole, "prettyDescription"},
            {DueDateRole, "dueDate"}};
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));
    if (index.row() < 0 || index.row() >= m_todos.count()) {
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
    case PrettyDescriptionRole:
        return todo.prettyDescription();
    case DueDateRole:
        return todo.dueDate();
    default:
        return {};
    }
}

void TodoModel::updateCompletionStatus(Todo &todo, const bool completed)
{
    auto newDescription = todo.description();
    todo.setCompleted(completed);
    if (todo.completed()) {
        // When todo is set completed, remove the priority and add it as pri:A in the end
        auto prio = m_priorityRegexp.match(newDescription);
        if (prio.hasCaptured(1)) {
            newDescription.append(QStringLiteral(" pri:%1").arg(prio.captured(1)));
            newDescription.replace(m_priorityRegexp, QString());
        }

        // Add completion date
        auto today = QDateTime::currentDateTime().date().toString(QStringLiteral("yyyy-MM-dd"));

        todo = parseTodoFromDescription(newDescription.simplified().prepend(QStringLiteral("x %1 ").arg(today)));
    } else {
        // When todo is set uncompleted, check for pri:A and set that as the priority (A) at the start
        newDescription.replace(m_completionRegexp, QString());
        // Remove completion date
        newDescription.replace(todo.completionDate(), QString());

        auto prio = m_keyValuePriority.match(newDescription);
        if (prio.hasCaptured(1)) {
            newDescription.replace(QStringLiteral("pri:%1").arg(prio.captured(1)), QString());
            newDescription.prepend(QStringLiteral("(%1)").arg(prio.captured(1)));
        }

        todo = parseTodoFromDescription(newDescription.simplified());
    }
}

bool TodoModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= m_todos.count()) {
        return false;
    }

    auto &todo = m_todos[index.row()];

    switch (role) {
    case CompletionRole:
        // We change the whole todo during this operation, so return early
        updateCompletionStatus(todo, value.toBool());
        Q_EMIT dataChanged(index, index);
        return true;
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
        // When description is changed, everything changes
        todo = parseTodoFromDescription(value.toString());
        Q_EMIT dataChanged(index, index);
        return true;
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
    case PrettyDescriptionRole:
        todo.setPrettyDescription(value.toString());
    case DueDateRole:
        todo.setDueDate(value.toString());
    default:
        return false;
    }

    Q_EMIT dataChanged(index, index);

    return true;
}

void TodoModel::addTodo(const QString &description)
{
    beginInsertRows(QModelIndex(), m_todos.count(), m_todos.count());
    m_todos.append(parseTodoFromDescription(description));
    endInsertRows();

    saveFile();
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

    saveFile();
}

QList<Todo> TodoModel::todos() const
{
    return m_todos;
}

QUrl TodoModel::filePath() const
{
    return m_filePath;
}

void TodoModel::setFilePath(const QUrl &newFilePath)
{
    m_filePath = newFilePath;
    m_config->setTodoFilePath(m_filePath.toLocalFile());
    m_config->save();
    Q_EMIT filePathChanged();
}

int TodoModel::filterIndex() const
{
    return m_filterIndex;
}

void TodoModel::setFilterIndex(const int &newFilterIndex)
{
    m_filterIndex = newFilterIndex;
    m_config->setFilterIndex(m_filterIndex);
    m_config->save();
    Q_EMIT filterIndexChanged();
}

bool TodoModel::loadFile()
{
    QFile file(m_filePath.toLocalFile());
    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qWarning() << "Could not open file:" << m_filePath << " - " << file.errorString();
        return false;
    }

    beginResetModel();
    m_todos.clear();
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (!line.isEmpty()) {
            auto task = parseTodoFromDescription(line);
            m_todos.append(task);
        }
    }
    endResetModel();
    m_fileWatcher->addFile(m_filePath.toLocalFile());
    return true;
}

bool TodoModel::saveFile()
{
    fileModifiedFromApp = true;
    QFileInfo fileInfo(filePath().toLocalFile());
    const QString backupFileName = fileInfo.absolutePath() + QDir::separator() + QStringLiteral(".%1.bak").arg(fileInfo.fileName());
    QFile saveFile(filePath().toLocalFile());
    QTextStream stream(&saveFile);
    QFile backupFile(backupFileName);
    if (backupFile.exists()) {
        backupFile.remove();
    }
    saveFile.copy(backupFileName);
    if (!saveFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to write todo list to disk";
        fileModifiedFromApp = true;
        return false;
    }
    QStringList sortedList;
    const auto todos = m_todos;
    for (const auto &todo : todos) {
        sortedList.append(todo.description());
    }
    std::sort(sortedList.begin(), sortedList.end());
    for (const auto &descr : sortedList) {
        stream << descr << "\n";
    }
    saveFile.close();

    return true;
}

bool TodoModel::fileExists() const
{
    QFileInfo fi(m_filePath.toLocalFile());
    return fi.exists();
}

void TodoModel::fileModified()
{
    if (fileModifiedFromApp) {
        fileModifiedFromApp = false;
        return;
    }
    Q_EMIT fileChanged();
}

QModelIndex TodoModel::indexFromDescription(const QString &description) const
{
    for (int i = 0; i < todos().count(); i++) {
        auto indexDescription = data(index(i, 0), DescriptionRole).toString();
        if (indexDescription == description) {
            return index(i, 0);
        }
    }
    return QModelIndex();
}
