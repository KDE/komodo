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
    m_completionRegexp = QRegularExpression(QStringLiteral("^[ \\t]*x"));
    m_priorityRegexp = QRegularExpression(QStringLiteral("^[ x\\t]*\\(([A-Z])\\)"));
    m_keyValuePriorityRegexp = QRegularExpression(QStringLiteral("pri:([A-Z])"));
    m_dateRegexp = QRegularExpression(QStringLiteral("\\d{4}-\\d\\d-\\d\\d"));
    m_keyValuePairRegexp = QRegularExpression(QStringLiteral("[a-zA-Z]+:[\\S]+"));

    m_fileWatcher = new KDirWatch(this);
    connect(this, &TodoModel::filePathChanged, this, &TodoModel::loadFile);
    connect(this, &TodoModel::dataChanged, this, &TodoModel::saveFile);
    m_config = KomodoConfig::self();
    m_config->load();
    m_filterIndex = m_config->filterIndex();
    m_autoInsertCreationDate = m_config->autoInsertCreationDate();
    if (!m_config->todoFilePath().isEmpty()) {
        m_filePath = QUrl::fromLocalFile(m_config->todoFilePath());
        if (!fileExists()) {
            m_filePath = QUrl();
            m_config->setTodoFilePath(QString());
            m_config->save();
        } else {
            loadFile();
        }
    }
    connect(m_fileWatcher, &KDirWatch::dirty, this, &TodoModel::fileModified);
    connect(m_fileWatcher, &KDirWatch::deleted, this, &TodoModel::fileModified);
    connect(m_fileWatcher, &KDirWatch::created, this, &TodoModel::fileModified);
}

Todo TodoModel::parseTodoFromDescription(const QString &description) const
{
    // read description from the file and turn it into task
    Todo todo(description);
    if (description.isEmpty()) {
        return todo;
    }
    auto splitDescription = description.split(QStringLiteral(" "));
    bool completionStatus = false;
    if (splitDescription.first() == QStringLiteral("x")) {
        completionStatus = true;
        splitDescription.removeFirst();
    }
    todo.setCompleted(completionStatus);

    if (splitDescription.first().contains(m_priorityRegexp)) {
        todo.setPriority(splitDescription.first());
        splitDescription.removeFirst();
    }

    if (splitDescription.first().contains(m_dateRegexp)) {
        if (completionStatus) {
            todo.setCompletionDate(splitDescription.first());
        } else {
            todo.setCreationDate(splitDescription.first());
        }
        splitDescription.removeFirst();
    }

    if (completionStatus) {
        if (splitDescription.first().contains(m_dateRegexp)) {
            todo.setCreationDate(splitDescription.first());
        }
        splitDescription.removeFirst();
    }

    QString descr;
    for (const auto &item : splitDescription) {
        descr.append(item);
        descr.append(QStringLiteral(" "));
        if (item.length() > 1) {
            if (item.startsWith(QStringLiteral("+"))) {
                todo.addProject(item);
                continue;
            } else if (item.startsWith(QStringLiteral("@"))) {
                todo.addContext(item);
                continue;
            } else if (item.contains(m_keyValuePairRegexp)) {
                if (!item.startsWith(QStringLiteral("http"))) {
                    todo.addKeyValuePair(item);
                }
                continue;
            }
        }
    }

    todo.setPrettyDescription(prettyPrintDescription(todo));
    const auto pairs = todo.keyValuePairs();
    for (const QString &keyval : pairs) {
        if (keyval.startsWith(QStringLiteral("due:"))) {
            todo.setDueDate(keyval.split(QStringLiteral(":")).last());
            break;
        }
    }
    return todo;
}

QString TodoModel::prettyPrintDescription(const Todo &todo) const
{
    // For some reason the string replacer does not work for the last item?
    // This just adds extra character at the end so we replace the last item.
    auto prettyDescr = QStringLiteral("%1 ").arg(todo.description());
    prettyDescr.replace(m_completionRegexp, QString());
    prettyDescr.replace(todo.creationDate(), QString());
    prettyDescr.replace(todo.completionDate(), QString());
    const auto keyValuePairs = todo.keyValuePairs();
    const auto projects = todo.projects();
    const auto contexts = todo.contexts();
    for (const auto &pair : keyValuePairs) {
        prettyDescr.replace(pair, QString());
    }
    prettyDescr.replace(m_priorityRegexp, QString());

    // There's probably better way to do this but hey as long as it works.
    // TODO: look into making custom theme for KSyntaxHighlighting at runtime and use that instead.
    const auto textColor = KColorScheme().foreground().color();
    const auto projectColor = KColorUtils::mix(KColorScheme().foreground(KColorScheme::ActiveText).color(), textColor);
    const auto contextColor = KColorUtils::mix(KColorScheme().foreground(KColorScheme::PositiveText).color(), textColor);
    for (const auto &project : projects) {
        const auto re = QRegularExpression(QStringLiteral("%1(?=\\s)").arg(QRegularExpression::escape(project)));
        prettyDescr.replace(re, QStringLiteral("<b><span style='color:%2'>%1</span></b>").arg(project, projectColor.name()));
    }
    for (const auto &context : contexts) {
        const auto re = QRegularExpression(QStringLiteral("%1(?=\\s)").arg(QRegularExpression::escape(context)));
        prettyDescr.replace(re, QStringLiteral("<i><span style='color:%2'>%1</span></i>").arg(context, contextColor.name()));
    }

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
            {DueDateRole, "dueDate"},
            {UUIDRole, "uuidRole"}};
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, CheckIndexOption::IndexIsValid));

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
    case UUIDRole:
        return todo.uuid();
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

        auto prio = m_keyValuePriorityRegexp.match(newDescription);
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
        Q_EMIT dataChanged(index, index, {CompletionRole});
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

    Q_EMIT dataChanged(index, index, {role});

    return true;
}

QUuid TodoModel::addTodo(const QString &description)
{
    beginInsertRows(QModelIndex(), m_todos.count(), m_todos.count());
    const auto newTodo = parseTodoFromDescription(description);
    m_todos.append(newTodo);
    endInsertRows();

    saveFile();
    return newTodo.uuid();
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

bool TodoModel::autoInsertCreationDate() const
{
    return m_autoInsertCreationDate;
}

void TodoModel::setAutoInsertCreationDate(bool enabled)
{
    m_autoInsertCreationDate = enabled;
    m_config->setAutoInsertCreationDate(m_autoInsertCreationDate);
    m_config->save();
    Q_EMIT autoInsertCreationDateChanged();
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

QModelIndex TodoModel::indexFromQUuid(const QUuid &uuid) const
{
    for (int i = 0; i < todos().count(); i++) {
        const auto id = index(i, 0);
        const auto indexUuid = data(id, UUIDRole).toUuid();
        if (indexUuid == uuid) {
            return id;
        }
    }
    return QModelIndex();
}
