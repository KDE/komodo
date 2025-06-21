#pragma once

#include <QMap>
#include <QRegularExpression>
#include <QString>

class TodoParser {
public:
  // https://github.com/todotxt/todo.txt/blob/master/description.svg
  struct ParsedTask {
    bool completed;
    QString priority;
    QString completionDate;
    QString creationDate;
    QString description;
    QStringList contexts;
    QStringList projects;
    QMap<QString, QString> keyValuePairs;
  };

  TodoParser(const QString &filePath);

  ParsedTask parseLine(const QString &description);

  QRegularExpression parserPattern;
};