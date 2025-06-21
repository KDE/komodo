#include "TodoParser.h"
#include <QDebug>
#include <QFile>
#include <QRegularExpression>
#include <QString>

TodoParser::TodoParser(const QString &filePath) {

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

  qWarning() << "filePath" << filePath;
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    qWarning() << "could not open file" << filePath;
    return;
  }

  // TODO: turn these into a model that can be read in qml
  QTextStream in(&file);
  while (!in.atEnd()) {
    QString line = in.readLine();
    qWarning() << "=== TASK START ===";
    auto task = parseLine(line);
    qWarning() << "Result = " << task.completed << task.completionDate
               << task.creationDate << task.contexts << task.priority
               << task.projects << task.keyValuePairs;
    qWarning() << "=== TASK END ===";
  }
}

TodoParser::ParsedTask TodoParser::parseLine(const QString &description) {
  // read description from the file and turn it into task
  QRegularExpressionMatchIterator iter = parserPattern.globalMatch(description);
  ParsedTask task;
  task.description = description;
  qWarning() << "Description " << task.description;
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
      keyVals.append(match.captured("KeyValuePairs"));
    }
  }

  for (const auto &keyval : keyVals) {
    auto splits = keyval.split(QStringLiteral(":"));
    const auto key = splits.first();
    splits.removeFirst();
    for (const auto &value : splits) {
      qWarning() << splits;
      task.keyValuePairs[key] += value;
    }
  }
  task.completed = completionStatus;
  return task;
}